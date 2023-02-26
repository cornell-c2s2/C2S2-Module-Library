module ControlVRTL 
#(
    parameter dib = 1,
    parameter dobreg = 1 << dib
)(
    input   logic vin,
    input   logic rin,
    input   logic reset,

    output  logic vout,
    output  logic rout,
    output  logic EN,
    output  logic [dib-1:0] dsel 
);
    logic [dobreg-1:0] count;
    always @(*) begin //vin, rin, count, Scurr
        if (reset ==1) begin 
            count = 0;
            EN = 1'b0;
            rout = 1'b1;
            vout = 1'b0;
            dsel = count;
        end
        else if ((vin == 1) & (count != dobreg) & (reset != 1)) begin //receiving
            EN = 1'b1;
            rout = 1'b1;
            vout = 1'b0;
            dsel = count; 
            count = count + 1;
        end 
        else if ((vin == 1) & (count == dobreg) & (reset != 1)) begin //send_val
            count = 0;
            EN = 1'b0;
            rout = 1'b0;
            vout = 1'b1;
            dsel = count;
        end
        else begin //base state
            count = count;
            EN = 1'b0;
            rout = 1'b1;
            vout = 1'b0;
            dsel = count;
        end 
    end
endmodule
