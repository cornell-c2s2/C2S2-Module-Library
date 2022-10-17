module counter #(parameter bitwidth = 32) (CLK, LD, EN, IN, OUT);
    input logic [bitwidth-1:0] IN;
    input logic CLK, LD, EN;
    output logic [bitwidth-1:0] OUT;

    logic [bitwidth-1:0] count;
    always @(posedge CLK) begin
        if (LD) begin
            count <= IN;
        end
        else begin
            if (EN) begin
                count <= count - 1;
            end
            else
                count <= count;
            end
        end
    end
    assign OUT = count;
endmodule
            
