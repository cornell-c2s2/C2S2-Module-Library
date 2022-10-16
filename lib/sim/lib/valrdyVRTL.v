`ifndef PROJECT_VALRDY_V
`define PROJECT_VALRDY_V
`endif

`include "ff.v"

module valrdyVRTL #(parameter bitwidth = 32) (clk, reset, snd_val, snd_rdy, snd_msg, rcv_val, rcv_rdy, rcv_msg);
    input logic snd_val;
    input logic [bitwidth-1:0] snd_msg;
    input logic reset;
    input logic clk;
    input logic rcv_rdy;
    output logic snd_rdy;
    output logic [bitwidth-1:0] rcv_msg;
    output logic rcv_val;

    ff #(.bitwidth(bitwidth)) flop1 (
	.EN(rcv_rdy & snd_val),
	.CLK(clk),
	.IN(snd_msg),
	.OUT(rcv_msg),
	.RESET(reset)
    );
endmodule    
