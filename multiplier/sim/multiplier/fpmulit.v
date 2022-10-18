`ifndef FIXED_POINT_ITERATIVE_MULTIPLIER
`define FIXED_POINT_ITERATIVE_MULTIPLIER
`include "../../../lib/sim/nbitregister/RegisterV_Reset.v"

interface stateI #( parameter n, parameter d ) ();
	logic [n+d-1:0] acc; // this needs to be n+d bits because the decimal portion of the multiplication may overflow
	logic [$clog2(n+1)-1:0] counter;

	modport in ( input acc, input counter );
	modport out ( output acc, output counter );
	modport io ( inout acc, inout counter );
endinterface

module state #( parameter n, parameter d ) (clk, reset, w, dat, q);
	input clk, reset, w;
	stateI.in dat;
	stateI.out q;
	
	RegisterV_Reset #(.N(n+d)) acc (
		.clk(clk),
		.reset(reset),
		.w(w),
		.d(dat.acc),
		.q(q.acc)
	);
	RegisterV_Reset #(.N($clog2(n+1))) counter (
		.clk(clk),
		.reset(reset),
		.w(w),
		.d(dat.counter),
		.q(q.counter)
	);
endmodule

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
	always @(*) begin
		// $display("%b, %b\n", a, b);
		if (in.counter < d) begin // we are multiplying to the right of the decimal point
			tmp = in.acc;
			if (b[in.counter]) begin
				// $display("detected decimal bit\n");
				tmp = tmp + a;
			end
			tmp = tmp >>> 1;
		end else begin
			tmp = 0;
			if (b[in.counter]) begin
				// $display("detected bit\n");
				tmp = a << (in.counter - d);
			end
			if (sign & in.counter == n-1)// sign bit (if multiplier is signed)
				tmp = -tmp;
			tmp = tmp + in.acc;			
		end
		// $display("counter: %d/%d, tmp: %b\n", in.counter, n, tmp);
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
			c <= ctI.acc[n-1:0];
		end
	end
endmodule
`endif
