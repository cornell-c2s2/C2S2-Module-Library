`ifndef FIXED_POINT_ITERATIVE_MULTIPLIER
`define FIXED_POINT_ITERATIVE_MULTIPLIER

interface state #( parameter n, parameter d ) ();
	logic [n+d-1:0] acc; // this needs to be n+d bits because the decimal portion of the multiplication may overflow
	logic [$clog2(n+1)-1:0] counter;

	modport in ( input acc, input counter );
	modport out ( output acc, output counter );
endinterface

module fpmulit_inner # (
	parameter n,
	parameter d,
	parameter sign
) (clk, a, b, in, out, rdy);
	input logic clk;
	input logic [n-1:0] b;
	input logic [n+d-1:0] a;
	output logic rdy;
	state.in in;
	state.out out;

	reg [n+d-1:0] tmp;
	always @(posedge clk) begin
		if (in.counter < d) begin // we are multiplying to the right of the decimal point
			tmp = in.acc >> 1;
			if (b[in.counter])
				tmp = tmp + a;
		end else begin
			tmp = 0;
			if (b[in.counter])
				tmp = a << (in.counter - d);
			if (sign & in.counter == n-1) begin// sign bit (if multiplier is signed)
				tmp = -tmp;
			end
			tmp = tmp + in.acc;			
		end
		rdy <= in.counter == n-1;
		out.acc <= tmp;
		out.counter <= in.counter + 1;
	end
endmodule

module fpmulit
# (
	parameter n = 32, // bit width
	parameter d = 16, // number of decimal bits
	parameter sign = 1 // 1 if signed, 0 otherwise.
) (clk, snd_val, snd_rdy, rcv_val, rcv_rdy, a, b, c);
	// performs the operation c = a*b
	
	input logic clk;
	input logic snd_val, rcv_rdy;
	input logic [n-1:0] a, b;
	output logic [n-1:0] c;
	output logic rcv_val, snd_rdy;
	reg [n-1:0] hb, hc;
	reg [n+d-1:0] ha;
	reg rdy;
	state #(.n(n), .d(d)) currin, currout;
	
	always @(posedge clk) begin
		if (snd_val & snd_rdy) begin // we are ready to recieve data
			currin.acc <= 0;
			currin.counter <= 0;
			ha <= {{d{a[n-1]}}, a};
			hb <= b;
			snd_rdy <= 0;
		end else
			currin.acc <= currout.acc;
			currin.counter <= currout.counter;
	end
		
	fpmulit_inner #(.n(n), .d(d), .sign(sign)) mult (
		.clk(clk & ~rcv_val),
		.a(ha),
		.b(hb),
		.in(currin),
		.out(currout),
		.rdy(rdy)
	);

	always @(posedge clk) begin
		if (rcv_rdy & rcv_val) begin // reciever is ready for input
			snd_rdy <= 1;
			rcv_val <= 0;
		end else if (rdy & ~rcv_val) begin
			rcv_val <= 1;
			c <= currout.acc;
		end

	end
endmodule
`endif
