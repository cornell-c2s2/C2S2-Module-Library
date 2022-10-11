`ifndef spi_master
`define spi_master

module spi_fsm (

    //reg signals
    input  logic packet_size_reg;
    output logic packet_size_reg_en;

    input  logic cs_addr_reg;
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
    end

endmodule
`endif spi_master
