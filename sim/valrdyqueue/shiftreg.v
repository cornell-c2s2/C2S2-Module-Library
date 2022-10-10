`ifndef PROJECT_VALRDYQUEUE_V
`define PROJECT_VALRDYQUEUE_V

module shiftreg #(bitwidth = 32,queue_size = 4) (EN, IN, CLK, OUT, RESET);
    input logic EN, CLK, RESET;
    input logic [bitwidth-1:0] IN;
    output logic [bitwidth-1:0] OUT;
    
    genvar i;
    generate
	for(i = 0; i < queue_size; i++) begin
	    wire [bitwidth-1:0] 
