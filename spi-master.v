`ifndef spi_master
`define spi_master

module spi_fsm (

    //reg signals
    input  logic packet_size_reg;
    input  logic packet_size_ifc_val;
    output logic packet_size_reg_en;

    input  logic cs_addr_reg;
    input  logic cs_addr_ifc_val;
    output logic cs_reg_en;

    //send recv signals
    output logic send_val;
    input  logic send_rdy;
    output logic recv_rdy;
    input  logic recv_val;

    //sclk edges
    output logic sclk_posedge;
    output logic sclk_negedge;

    //peripheral signals
    output logic cs;
    output logic sclk;
);

typedef enum logic [2:0] {
    STATE_INIT,
    STATE_START0,
    STATE_START1,
    STATE_SCLK_HIGH,
    STATE_SCLK_LOW,
    STATE_CS_LOW_WAIT,
    STATE_DONE
} state_t;

state_t current_state;
state_t next_state;



always @(*) begin
    next_state = current_state;
    case (state_reg)
        STATE_INIT: (recv_val == 1) next_state = STATE_START0;
        STATE_START0: next_state = STATE_START1;
        STATE_START1: next_state = STATE_SCLK_HIGH;
        STATE_SCLK_HIGH: next_state = STATE_SCLK_LOW;
        STATE_SCLK_LOW: (sclk_counter == 0) ? next_state = STATE_CS_LOW_WAIT : next_state = STATE_SCLK_HIGH;
        STATE_CS_LOW_WAIT: next_state = STATE_DONE;
        STATE_DONE: (recv_val == 1) ? next_state = STATE_CS_LOW_WAIT : if(send_rdy == 1) next_state = STATE_INIT;
        //need to double check state_done
    endcase 

end

task cs
(
    input cs_packet_size_reg_en,
    input cs_cs_addr_reg_en,
    input cs_send_val,
    input cs_recv_rdy,
    input cs_sclk_negedge,
    input cs_sclk_posedge,
    input cs_sclk,
    input cs_cs,
);

begin
    packet_size_reg_en = cs_packet_size_reg_en;
    cs_addr_reg_en = cs_cs_addr_reg_en;
    send_val = cs_send_val;
    recv_rdy = cs_recv_rdy;
    sclk_negedge = cs_sclk_negedge;
    sclk_posedge = cs_sclk_posedge;
    sclk = cs_sclk;
    cs = cs_cs;

end
endtask

logic clk_cnt_not_done;

assign clk_cnt_not_done = (clk_count != 0);
assign packet_size

always @(*) begin
    case(state_reg)

//                             packet size           addr              send   recv   sclk     sclk    
//                             reg en                reg en            val    rdy    negedge  posedge             sclk  cs
// need to add more signals
        STATE_INIT:        cs( packet_size_ifc_val,  cs_addr_ifc_val,  0,     1,     0,       0,                  0,    1)
        STATE_START0:      cs( 0,                    0,                0,     0,     0,       0,                  0,    0)
        STATE_START1:      cs( 0,                    0,                0,     0,     0,       1,                  0,    0)
        STATE_SCLK_HIGH:   cs( 0,                    0,                0,     0,     1,       0,                  1,    0)
        STATE_SCLK_LOW:    cs( 0,                    0,                0,     0,     0,       clck_cnt_not_done,  0,    0)
        STATE_CS_LOW_WAIT: cs( 0,                    0,                0,     0,     0,       0,                  0,    0)
        STATE_DONE:        cs( 0,                    0,                1,     1,     0,       0,                  0,    1)
    endcase
end

endmodule
`endif 
