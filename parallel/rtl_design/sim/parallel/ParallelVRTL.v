module ParallelVRTL
#(
	parameter dib = 1, //decoder inputs
    parameter dobreg = 1'b1 << dib, //number of outputs to decoder/#of registers
	parameter N = 32
)(
	input logic clk, 
	input logic reset,
	input logic VIN, 
	input logic RIN, 
	input logic [N-1:0] dta,

	output logic EN, 
	output logic VOUT, 
	output logic ROUT,
	output logic [dobreg-1:0] DOUT,
	output logic [dib-1:0] DSEL,
	output logic [N-1:0] OUTPUTA, 
	output logic [N-1:0] OUTPUTB
);
    //body of code
	RegisterV #(.N(N)) a
		(
			.clk(clk),
			.reset(reset),
			.w(DOUT[0]),
			.d(dta),
			.q(OUTPUTA)
		);
	
	RegisterV #(.N(N)) b
		(
			.clk(clk),
			.reset(reset),
			.w(DOUT[1]),
			.d(dta),
			.q(OUTPUTB)
		);
	
	ControlVRTL c
		(
			.vin(VIN),
			.rin(RIN),
			.vout(VOUT),
			.rout(ROUT),
			.dsel(DSEL),
			.EN(EN),
			.RESET(reset),
			.CLK(clk)
		);

	DecoderVRTL #(.m(dib), .n(dobreg)) d
		(
			.enable(EN),
			.x(DSEL),
			.y(DOUT)
		);      
endmodule


	//generate block instantiation
	// mydesign #(.dob(dobreg)) e
	// 	(
	// 		.clk(CLK),
	// 		.reset(RESET),
	// 		.w(DOUT[dobreg-1]),
	// 		.d(DATA),
	// 		.q(OUTPUT)
	// 	);

//generate block for loop
// module my_design
// 	#(parameter dob=2)
// 	(input [dob-1:0] clk, reset, w, d
// 	 output [dob-1:0] q);

// 	genvar i;
// 	generate
// 		for(i=0; i<N; i=i+1) begin
// 			RegisterV u0(clk[i], rest[i], w[i], d[i], q[i]);
// 		end
// 	endgenerate
// endmodule hello