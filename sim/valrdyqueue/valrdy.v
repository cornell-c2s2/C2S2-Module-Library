`ifndef PROJECT_VALRDYQUEUE_V
`define PROJECT_VALRDYQUEUE_V

module valrdy #(parameter bitwidth = 32) (snd_val, snd_rdy, snd_data_msg, rcv_val, rcv_rdy, rcv_data_msg);
    input logic snd_val;
    input logic [bitwidth-1:0] snd_data_msg;
    input logic rcv_rdy;
    output logic snd_rdy;
    output logic [bitwidth-1:0] rcv_data_msg;
    output logic rcv_val;

    ff flipflop1 
    
