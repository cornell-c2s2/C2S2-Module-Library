`ifndef FIXED_POINT_ITERATIVE_MULTIPLIER
`define FIXED_POINT_ITERATIVE_MULTIPLIER

interface stateI #( parameter n, parameter d ) ();
	logic [n+d-1:0] acc; // this needs to be n+d bits because the decimal portion of the multiplication may overflow
	logic [$clog2(n+1)-1:0] counter;

	modport in ( input acc, input counter );
	modport out ( output acc, output counter );
	modport io ( inout acc, inout counter );
endinterface

module fpmulit_inner # (
	parameter n,
	parameter d,
	parameter sign
) (a, b, in, out, rdy);
	input logic [n-1:0] b;
	input logic [n+d-1:0] a;
	output logic rdy;
	stateI.in in;
	stateI.out out;

	reg [n+d-1:0] tmp;
	reg [2*n-1:0] tt;
	always @(*) begin
		tmp = 0;
		if (b[in.counter]) begin
			tmp = a << in.counter;
			if (sign & in.counter == n-1) begin// sign bit (if multiplier is signed)
				tt = { {(n-d){a[n+d-1]}}, a};
				tt = ((tt << n) - tt) << (n-1);
				tmp = tt[n+d-1:0];
			end
		end
		tmp = tmp + in.acc;			
		rdy = in.counter == n-1;
		out.acc = tmp;
		out.counter = in.counter + 1;
	end
endmodule

module fpmulit
# (
	parameter n = 32, // bit width
	parameter d = 16, // number of decimal bits
	parameter sign = 1 // 1 if signed, 0 otherwise.
) (clk, snd_val, snd_rdy, rcv_val, rcv_rdy, a, b, c);
	// performs the operation c = a*b
	// Equivalent to taking the integer representations of both numbers,
	// multiplying, and then shifting right
	input logic clk;
	input logic snd_val, rcv_rdy;
	input logic [n-1:0] a, b;
	output logic [n-1:0] c;
	output logic rcv_val, snd_rdy;
	reg [n-1:0] hb, hc;
	reg [n+d-1:0] ha;
	reg rdy;
	stateI #(.n(n), .d(d)) cinI, ctI;
	
	initial begin
		snd_rdy = 1;
	end

	fpmulit_inner #(.n(n), .d(d), .sign(sign)) mult (
		.a(ha),
		.b(hb),
		.in(cinI),
		.out(ctI),
		.rdy(rdy)
	);

	always @(posedge clk) begin
		if (snd_val & snd_rdy) begin // we are ready to recieve data
			ha <= {{d{(sign != 0) & a[n-1]}}, a};
			hb <= b;
			snd_rdy <= 0;
			cinI.acc <= 0;
			cinI.counter <= 0;
		end

		if (~snd_rdy) begin
			cinI.acc <= ctI.acc;
			cinI.counter <= ctI.counter;
		end

		if (rcv_rdy & rcv_val) begin // reciever is ready for input
			snd_rdy <= 1;
			rcv_val <= 0;
		end

		if (rdy & ~snd_rdy & ~rcv_val) begin
			rcv_val <= 1;
			c <= ctI.acc[n+d-1:d];
		end
	end
endmodule
`endif
