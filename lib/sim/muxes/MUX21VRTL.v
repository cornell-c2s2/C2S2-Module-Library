`ifndef PROJECT_MUX21_V
`define PROJECT_MUX21_V


module MUX21VRTL(
    input logic [31:0]  a,
    input logic [31:0]  b,
    input logic [0:0]     se,
    output logic [31:0] o
);
    always @(*) begin
        if (se == 0)
            assign o = a;
        else
            assign o = b;
    end


endmodule

`endif