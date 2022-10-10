`ifndef PROJECT_VALRDYQUEUE_V
`define PROJECT_VALRDYQUEUE_V

module ff #(parameter bitwidth = 32) (EN, CLK, IN, OUT, RESET);
    input logic CLK, EN, RESET;
    input logic [bitwidth-1:0] IN;
    output logic [bitwidth-1:0] OUT;

    always @(posedge CLK) begin
	if (RESET == 1'b1) begin
	    OUT <= 1'b0;
	end
	else if (EN == 1'b1) begin
	    OUT <= IN;
	end
	else begin
	    OUT <= OUT;
	end
    end
endmodule
    
