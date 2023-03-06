module ControlVRTL 
#(
    parameter dib = 1,
    parameter dobreg = 1'b1 << dib
)(
    input   logic vin,
    input   logic rin,
    input   logic reset,

    output  logic vout,
    output  logic rout,
    output  logic EN,
    output  logic [dib-1:0] dsel
);
    logic [dobreg-1'b1:0] count;
    always @(*) begin 
        if (reset == 1'b1)begin
            dsel  =  0;
            EN    =  1'b0; 
            vout  =  1'b0;//1'b0
            rout  =  1'b0;
            count =  0;
        end
        else if ((vin==1) & (rin==1))begin 
            dsel = count;
            EN = 1'b1;
            rout = 1'b1;
            if (dsel == (dobreg - 1))begin 
                vout = 1'b1;
            end 
            else begin
                vout = 1'b0;
            end
            count = count + 1;
        end
        else begin
            dsel = 0;
            EN   = 1'b0; 
            vout = 1'b0;
            rout = 1'b0;
            count = count;
        end
    end
endmodule

