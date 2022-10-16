`ifndef PROJECT_BUTTERFLY_V
`define PROJECT_BUTTERFLY_V
module butterfly #(parameter bitwidth = 32) (aR, aC, bR, bC, cR, cC, dR, dD)
	/* performs the butterfly operation, equivalent to doing
		| 1  1 |   | a |   | c |
		| 1 -1 | * | b | = | d |
	*/

	input wire [bitwidth-1:0] aR, aC, bR, bC;
	output wire [bitwidth-1:0] cR, cC, dR, dC;


	assign cR = aR + bR;
	assign cC = aC + bC;

	assign dR = aR - bR;
	assign dC = aC - bC;

endmodule
`endif
