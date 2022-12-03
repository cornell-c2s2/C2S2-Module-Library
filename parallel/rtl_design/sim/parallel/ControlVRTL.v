module ControlVRTL 
#(
    parameter dib = 1,
    parameter dobreg = 1'b1 << dib
)(
    input   logic vin, rin, RESET, CLK,
    output  logic vout, rout, EN,
    output logic [dib-1:0] dsel
);
    logic [dobreg-1'b1:0] i;
    assign i = 0;
    always @(posedge CLK) begin 
        if (~RESET & vin & rin) begin 
            dsel <= i;
            EN <= 1'b1;
            rout <= 1'b1;
            if (i == dobreg) begin 
                vout <= 1'b1;
            end 
            else begin
                vout <= 1'b0;
            end
            i <= i + 1;  
        end
        else begin
            EN <= 1'b0; 
        end
    end
endmodule

