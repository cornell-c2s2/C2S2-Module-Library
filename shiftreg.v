`ifndef spi_master
`define spi_master
`endif

module shiftreg #(parameter bitwidth = 32) (clk, reset, in, load_data, load_en, shift_en, out);
    input logic [bitwidth-1:0] load_data;
    input logic reset;
    input logic load_en;
    input logic shift_en;
    input logic in;
    input logic [bitwidth-1:0] load_data;
    output logic out;

    logic [bitwidth-1:0] regval;
 
    always @(posedge clk) begin
        if (reset) regval <= {bitwidth{1'b0}};
        else if (load_en) regval <= load_data;
        else if (~load_en & shift_en) regval <= {regval[bitwidth-2:0],in};
        else regval <= regval;
    end
    assign out = regval[bitwidth-1];
endmodule
