module shiftreg #(parameter bitwidth = 32) (clk, in, load_data, load_en, shift_en, out);
    input logic [bitwidth-1:0] load_data;
    input logic clk, load_en, shift_en, in;
    output logic [bitwidth-1:0] out;
 
    always @(posedge clk) begin
        if (load_en) begin out <= load_data; end
        else begin
            if (shift_en) begin out <= {out[bitwidth-2:0], in}; end
            else begin out <= out; end
    end
endmodule
