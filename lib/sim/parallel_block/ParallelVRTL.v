module ParallelVRTL
#(
	parameter dib = 1,					//decoder inputs
    parameter dobreg = 1'b1 << dib, 	//number of outputs to decoder/#of registers
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
	ControlVRTL c
		(
			.vin(VIN),
			.rin(RIN),
			.vout(VOUT),
			.rout(ROUT),
			.dsel(DSEL),
			.reset(reset),
			.EN(EN)
		);

	DecoderVRTL #(.m(dib), .n(dobreg)) d
		(
			.enable(EN),
			.x(DSEL),
			.y(DOUT)
		);      

	RegisterV #(.N(N)) a
		(
			.clk(clk),
			.reset(reset),
			.w((DOUT[0]) ? 0 : 1),
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
endmodule



module RegisterV
	#(parameter N = 32)
	(clk, reset, w, d, q);

	input logic clk;
	input logic reset;
	input  logic w;
	input logic [N-1:0] d;
	output logic [N-1:0] q;
	logic [N-1:0] regout;

	assign q = regout;

	always @(posedge clk) begin
		if (w == 1)
			regout <= d;
	end
endmodule

module DecoderVRTL 
#(
	parameter m = 3,
	parameter n = 1'b1 << m  // n = 2 ** m
)(
`ifdef USE_POWER_PINS
	inout vccd1,
	inout vssd1,
`endif

	input enable,
	input  reg [m-1:0] x,
	output reg [n-1:0] y
);
	always @(*)
		if (!enable)
			y = {n {1'b0}};
		else
			y = {{n - 1 {1'b0}}, 1'b1} << x;
endmodule


module ControlVRTL 
#(
    parameter dib = 1,
    parameter dobreg = 1'b1 << dib
)(
    input   logic vin,
    input   logic rin,
    input   logic reset,

    output  logic vout,
    output  logic rout,
    output  logic EN,
    output  logic [dib-1:0] dsel
);
    logic [dobreg-1'b1:0] count;
    always @(*) begin 
        if (reset == 1'b1)begin
            dsel  =  0;
            EN    =  1'b0; 
            vout  =  1'b0;//1'b0
            rout  =  1'b0;
            count =  0;
        end
        else if ((vin==1) & (rin==1))begin 
            dsel = count;
            EN = 1'b1;
            rout = 1'b1;
            if (dsel == (dobreg - 1))begin 
                vout = 1'b1;
            end 
            else begin
                vout = 1'b0;
            end
            count = count + 1;
        end
        else begin
            dsel = 0;
            EN   = 1'b0; 
            vout = 1'b0;
            rout = 1'b0;
            count = count;
        end
    end
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