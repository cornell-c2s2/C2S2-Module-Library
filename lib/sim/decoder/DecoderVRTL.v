`ifndef PROJECT_DECODER_V
`define PROJECT_DECODER_V

//Registered Incrementer in Verilog


module DecoderVRTL
    #(  parameter m = 3, 
        parameter n = 2 ** m
    )(
        input  logic         enable, 
        input  logic [m-1:0] x, 
        output logic [n-1:0] y
    );

    ///////////////////////////////// design

    always @(*)begin
        if (!enable)begin
            y = {n{1'b0}};
        end
        else begin
            y = {{n-1{1'b0}},1'b1} << x; // << is a shift operator going left shift x positions
        end
    end
    /////////////////////////////////

endmodule

`endif



