`ifndef PROJECT_REGISTER_V
`define PROJECT_REGISTER_V

//Registered Incrementer in Verilog


module RegisterV(clk, reset, w, d, q);

	parameter n = 32;
	input logic clk;
	input logic reset;
	input  logic w;
	input logic [n-1:0] d;
	output logic [n-1:0] q;
	logic [n-1:0] regout;

	assign q = regout;

	always @(posedge clk) begin
		if (w)
			regout <= d;
	end
endmodule

`endif
