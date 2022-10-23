`ifndef PROJECT_MUX41_V
`define PROJECT_MUX41_V


module MUX41VRTL(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c,
    input logic [31:0] d,
    input logic [1:0] se,
    output logic [31:0] o
);
    always @(*) begin
        if (se == 0)
            assign o = a;
        else if (se == 1)
            assign o = b;
        else if (se == 2)
            assign o = c;
        else
            assign o = d;
    end


endmodule

`endif