`ifndef PROJECT_REGISTER_V_RESET
`define PROJECT_REGISTER_V_RESET

//Registered Incrementer in Verilog


module RegisterV_Reset(clk, reset, w, d, q);
    parameter n = 32;
    input logic clk;
    input logic reset;
    input  logic w;
    input logic [n-1:0] d;
    output logic [n-1:0] q;
    logic [n-1:0] regout;

    assign q = regout;

    always @(posedge clk) begin
	if (reset)
	    regout <= 0;
	else if (w)
	    regout <= d;
    end
endmodule

`endif
