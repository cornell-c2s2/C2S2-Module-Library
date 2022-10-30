`ifndef spi_master
`define spi_master

module spi_master_ctrl
(
    //counter signals
    input  logic [31:0] count,
    output logic        count_increment,
    output logic        count_reset,

    //reg signals
    input  logic        packet_size_reg,
    input  logic        packet_size_ifc_val,
    output logic        packet_size_reg_en,
       
    input  logic        cs_addr_reg,
    input  logic        cs_addr_ifc_val,
    output logic        cs_reg_en,
       
    //send recv signals
    output logic        send_val,
    input  logic        send_rdy,
    output logic        recv_rdy,
    input  logic        recv_val,

    //sclk edges
    output logic        sclk_posedge,
    output logic        sclk_negedge,

    //peripheral signals
    output logic        cs,
    output logic        sclk
);

typedef enum logic [2:0] 
{
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
        STATE_INIT: if (recv_val == 1) next_state = STATE_START0;
        STATE_START0: next_state = STATE_START1;
        STATE_START1: next_state = STATE_SCLK_HIGH;
        STATE_SCLK_HIGH: next_state = STATE_SCLK_LOW;
        STATE_SCLK_LOW: 
            if(sclk_counter == 0) begin
                next_state = STATE_CS_LOW_WAIT;
            end
            else begin
                next_state = STATE_SCLK_HIGH;
            end
        STATE_CS_LOW_WAIT: next_state = STATE_DONE;
        STATE_DONE: 
            if(recv_val == 1) begin
                next_state = STATE_CS_LOW_WAIT;
            end
            else begin
                if(send_rdy == 1) begin
                    next_state = STATE_INIT;
                end
            end

        //need to double check state_done
    endcase 

end

task control_signals
(
    input cs_packet_size_reg_en,
    input cs_cs_addr_reg_en,
    input cs_send_val,
    input cs_recv_rdy,
    input cs_sclk_negedge,
    input cs_sclk_posedge,
    input cs_sclk,
    input cs_cs,
    input cs_counter_increment,
    input cs_counter_reset
);

begin
    packet_size_reg_en = cs_packet_size_reg_en;
    cs_addr_reg_en     = cs_cs_addr_reg_en;
    send_val           = cs_send_val;
    recv_rdy           = cs_recv_rdy;
    sclk_negedge       = cs_sclk_negedge;
    sclk_posedge       = cs_sclk_posedge;
    sclk               = cs_sclk;
    cs                 = cs_cs;
    counter_increment  = cs_counter_increment;
    counter_reset      = cs_counter_reset;
end
endtask

logic clk_cnt_not_done;
assign clk_cnt_not_done = (count != packet_size_ifc_val);


always @(*) begin
    case(state_reg)

//                             packet size           addr              send   recv   sclk     sclk                           clk  clk
//                             reg en                reg en            val    rdy    negedge  posedge             sclk  cs   inc  res
// need to add more signals
        STATE_INIT:        cs( packet_size_ifc_val,  cs_addr_ifc_val,  0,     1,     0,       0,                  0,    1,   0,   0    );
        STATE_START0:      cs( 0,                    0,                0,     0,     0,       0,                  0,    0,   0,   1    );
        STATE_START1:      cs( 0,                    0,                0,     0,     0,       1,                  0,    0,   0,   0    );
        STATE_SCLK_HIGH:   cs( 0,                    0,                0,     0,     1,       0,                  1,    0,   1,   0    );
        STATE_SCLK_LOW:    cs( 0,                    0,                0,     0,     0,       clk_cnt_not_done,   0,    0,   0,   0    );
        STATE_CS_LOW_WAIT: cs( 0,                    0,                0,     0,     0,       0,                  0,    0,   0,   0    );
        STATE_DONE:        cs( 0,                    0,                1,     1,     0,       0,                  0,    1,   0,   0    );
    endcase
end

//Datapath
module spi_master_dpath
(
    input logic cs_addr_val;
    output logic cs_addr_rdy;
    input logic [31:0] cs_addr_msg;

    input logic packet_size_val;
    output logic packet_size_rdy;
    input logic [31:0] packet_size_msg;

    input logic recv_val;
    output logic recv_rdy;
    input logic [31:0] recv_msg;

    output logic send_val;
    input logic send_rdy;
    output logic [31:0] send_msg;

    output cs;
    output sclk;
    output mosi;
    input miso;
);




// shift register out
logic outbound_mosi;

shiftreg#() (
    .shift_en = (sclk_posedge),
    .in = (1'b0),
    .load_data = (recv_msg << (nbits - packet_size)), //adjust here
    .load_en = (recv_rdy && recv_val), //adjsut here
    .out = (outbound_mosi)

)

// shift register out

logic outbound_send_msg;

shiftreg#() (
    .shift_en = (sclk_negedge),
    .in = (miso),
    .load_data = (1'b0), //adjust here
    .load_en = (1'b0), //adjsut here
    .out = (outbound_send_msg)

)

// counter
counter#() (
    .en = (count_increment),
    .rst = (count_reset),
    .out = (count)
    
)


// register 

logic [5:0] packet_size_reg;

// register

logic [2:0] cs_addr_reg;

endmodule
`endif 
