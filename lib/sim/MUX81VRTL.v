`ifndef PROJECT_MUX81_V
`define PROJECT_MUX81_V


module MUX81VRTL(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c,
    input logic [31:0] d,
    input logic [31:0] e,
    input logic [31:0] f,
    input logic [31:0] g,
    input logic [31:0] h,
    input logic [2:0] se,
    output logic [31:0] o
);
    always @(*) begin
        if (se == 0 )
            assign o = a;
        else if (se == 1)
            assign o = b;
        else if (se == 2)
            assign o = c;
        else if (se == 3)
            assign o = d;
        else if (se == 4)
            assign o = e;
        else if (se == 5)
            assign o = f;
        else if (se == 6)
            assign o = g;
        else
            assign o = h;
    end

endmodule

`endif