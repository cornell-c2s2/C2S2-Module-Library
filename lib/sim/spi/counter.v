module counter #(parameter bitwidth = 32) (en, rst, out);
    input logic in;
    input logic CLK, LD, EN;
    output logic [bitwidth] out;

    logic [5:0] count;
    always @(posedge en) begin
        count = count + 1;
    end

    always @(posedge rst) begin
        count = 0;
    end
    
    assign out = count;
endmodule
            
