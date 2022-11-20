`ifndef FIXED_POINT_ITERATIVE_COMPLEX_MULTIPLIER
`define FIXED_POINT_ITERATIVE_COMPLEX_MULTIPLIER
`include "../../../lib/sim/fixedpt-iterative-multiplier/fpmulit.v"

module fpcmulit
# (
	parameter n = 32, // bit width
	parameter d = 16 // number of decimal bits
) (clk, snd_val, snd_rdy, rcv_val, rcv_rdy, ar, ac, br, bc, cr, cc);
	// performs c = a * b on complex a and b
	input logic [n-1:0] ar, ac, br, bc;
	output logic [n-1:0] cr, cc;

	initial begin
		snd_rdy = 1;
	end

	// cr = (ar * br) - (ac * bc)
	// cc = (ar * bc) + (br * ac) = (ar + ac)(br + bc) - (ac * bc) - (ar * br)

	reg [n-1:0] arbr, acbc, ab; // temporary values
	reg [n-1:0] arbr_rdy, acbc_rdy, ab_rdy, sab_rdy;
	reg [n-1:0] a, b; // (ar + ac) and (br + bc)

	fpmulit #(.n(n), .d(d), .sign(1)) m1 ( // ar * br
		.a(ar),
		.b(br),
		.c(arbr),
		.snd_val(snd_val),
		.rcv_val(arbr_rdy),
		.rcv_rdy(rcv_val)
	);

	fpmulit #(.n(n), .d(d), .sign(1)) m2 ( // ac * bc
		.a(ac),
		.b(bc),
		.c(acbc),
		.snd_val(snd_val),
		.rcv_val(acbc_rdy),
		.rcv_rdy(rcv_val)
	);

	fpmulit #(.n(n), .d(d), .sign(1)) m3 (
		.a(a),
		.b(b),
		.c(ab),
		.snd_val(sab_rdy),
		.rcv_val(ab_rdy),
		.rcv_rdy(rcv_val)
	);

	always @(posedge clk) begin
		if (snd_val & snd_rdy) begin 
			sab_rdy <= 1;
			a <= ar + ac;
			b <= br + bc;
		end

		if (sab_rdy) begin
			sab_rdy <= 0;
		end

		if (arbr_rdy & acbc_rdy & ab_rdy) begin // all multipliers are done!
			rcv_val <= 1;
			cr <= arbr - acbc;
			cc <= ab - acbc - arbr;
		end

		if (rcv_val & rcv_rdy) begin
			snd_rdy <= 1;
		end
	end

`endif
