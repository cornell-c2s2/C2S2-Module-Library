`ifndef PROJECT_VALRDY_V
`define PROJECT_VALRDY_V

module shiftregSIPO #(bitwidth = 32) (LOAD_EN, SHIFT_EN, IN, LOAD_DATA, CLK, OUT, RESET);
    input logic LOAD_EN, SHIFT_EN, CLK, RESET, IN;
    input logic [bitwidth-1:0] LOAD_DATA;
    output logic [bitwidth-1:0] OUT;
    
    always @(posedge CLK) begin
        if (RESET) OUT <= {bitwidth{1'b0}};
        else if (LOAD_EN) OUT <= LOAD_DATA;
        else if (~LOAD_EN & SHIFT_EN) OUT <= {OUT[bitwidth-2:0],IN};
        else OUT <= OUT;
    end
endmodule  
