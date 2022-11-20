`ifndef FIXED_POINT_ITERATIVE_COMPLEX_MULTIPLIER
`define FIXED_POINT_ITERATIVE_COMPLEX_MULTIPLIER
`include "../../../lib/sim/fixedpt-iterative-multiplier/FpmultVRTL.v"

module FpcmultVRTL
# (
	parameter n = 32, // bit width
	parameter d = 16 // number of decimal bits
) (clk, reset, recv_val, recv_rdy, send_val, send_rdy, ar, ac, br, bc, cr, cc);
	// performs c = a * b on complex a and b
  input logic clk, reset;
  input logic recv_val, send_rdy;
	input logic [n-1:0] ar, ac, br, bc;
  output logic send_val, recv_rdy;
	output logic [n-1:0] cr, cc;

	initial begin
		recv_rdy = 1;
	end

	// cr = (ar * br) - (ac * bc)
	// cc = (ar * bc) + (br * ac) = (ar + ac)(br + bc) - (ac * bc) - (ar * br)

	reg [n-1:0] arbr, acbc, ab; // temporary values
	reg [n-1:0] arbr_rdy, acbc_rdy, ab_rdy, sab_rdy;
	reg [n-1:0] a, b; // (ar + ac) and (br + bc)

	FpmultVRTL #(.n(n), .d(d), .sign(1)) m1 ( // ar * br
		.clk(clk),
		.reset(reset),
		.a(ar),
		.b(br),
		.c(arbr),
		.recv_val(recv_val),
		.send_val(arbr_rdy),
		.send_rdy(send_val),
		.recv_rdy()
	);

	FpmultVRTL #(.n(n), .d(d), .sign(1)) m2 ( // ac * bc
		.clk(clk),
		.reset(reset),
		.a(ac),
		.b(bc),
		.c(acbc),
		.recv_val(recv_val),
		.send_val(acbc_rdy),
		.send_rdy(send_val),
		.recv_rdy()
	);

	FpmultVRTL #(.n(n), .d(d), .sign(1)) m3 ( // (ar + ac) * (br + bc)
		.clk(clk),
		.reset(reset),
		.a(a),
		.b(b),
		.c(ab),
		.recv_val(sab_rdy),
		.send_val(ab_rdy),
		.send_rdy(send_val),
		.recv_rdy()
	);

	always @(posedge clk) begin
		if (recv_val & recv_rdy) begin 
			sab_rdy <= 1;
			a <= ar + ac;
			b <= br + bc;
		end

		if (sab_rdy) begin
			sab_rdy <= 0;
		end

		if (arbr_rdy & acbc_rdy & ab_rdy) begin // all multipliers are done!
			send_val <= 1;
			cr <= arbr - acbc;
			cc <= ab - arbr - acbc;
		end

		if (send_val & send_rdy) begin
			recv_rdy <= 1;
		end
	end
endmodule

`endif
