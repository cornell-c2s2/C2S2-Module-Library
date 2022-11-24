`ifndef PROJECT_VALRDY_V
`define PROJECT_VALRDY_V
`endif
module shiftregSISOVRTL #(bitwidth = 32) (LOAD_EN, SHIFT_EN, IN, LOAD_DATA, clk, OUT, reset);
    input logic LOAD_EN;
    input logic SHIFT_EN;
    input logic clk;
    input logic reset;
    input logic IN;
    input logic [bitwidth-1:0] LOAD_DATA;
    output logic OUT;
    
    logic [bitwidth-1:0] regval;
    always @(posedge clk) begin
        if (reset) regval <= {bitwidth{1'b0}};
        else if (LOAD_EN) regval <= LOAD_DATA;
        else if (~LOAD_EN & SHIFT_EN) regval <= {regval[bitwidth-2:0],IN};
        else regval <= regval;
    end
    assign OUT = regval[bitwidth-1];
endmodule  
