/*
==========================================================================
SPIMasterValRdyVRTL.v
==========================================================================
SPIMaster module for sending messages over SPI.
Supports SPI mode 0.

Author : Kyle Infantino
  Date : April 26, 2022

*/

/*
Note for C2S2 future development:
We can add support for different frequencies. Currently, SPI Master
runs at 1/2 of the system clock. However, we can add cycles to lower the
frequency. We will need a modified FSM and input from chip so that we 
can dynamically lower or raise the SPI frequency.
*/

/*
Notes 3/11/2023
Adding an extra state that will serve to divide frequency. Using a 
variable called freq_div_count, we will check if we need to add 
additional cycles to make the system 1/2 slower (keep in mind that the 
SPI Master is alread 1/2 of the master system clock). freq_div_count 
will obtain its value from a configuration register that is outside the 
SPI Master files. 

-Austin
*/

/*
Notes 3/12/2023
We need to consider when the FSM enters CS_LOW_WAIT. Because we are 
following the set frequency, there is the need for the CS_LOW_HOLD 
state to assess if it needs to go to the CS_LOW_WAIT state.

I added some logic to allow for frequency counter to be refilled
after countdown complete. Will refill value after the 

-Austin
*/
`ifndef SPI_V3_COMPONENTS_SPIMASTER_V
`define SPI_V3_COMPONENTS_SPIMASTER_V

`include "ShiftReg.v"
`include "regs.v"

module SPIMasterValRdyVRTL
#(
  parameter nbits = 34, 
  parameter ncs = 1,
  parameter logBitsN = $clog2(nbits)+1,
  parameter logCSN = ncs > 1 ? $clog2(ncs) : 1
)
(
  input  logic                clk,
  input  logic                reset,

  output logic                spi_ifc_cs [0:ncs-1],
  input  logic                spi_ifc_miso,
  output logic                spi_ifc_mosi,
  output logic                spi_ifc_sclk,

  input  logic                recv_val,
  output logic                recv_rdy,
  input  logic [nbits-1:0]    recv_msg,

  output logic                send_val,
  input  logic                send_rdy,
  output logic [nbits-1:0]    send_msg,

  input  logic                packet_size_ifc_val,
  output logic                packet_size_ifc_rdy,
  input  logic [logBitsN-1:0] packet_size_ifc_msg,

  input  logic                cs_addr_ifc_val,
  output logic                cs_addr_ifc_rdy,
  input  logic [logCSN-1:0]   cs_addr_ifc_msg,

  input  logic                freq_ifc_val, //new 
  output logic                freq_ifc_rdy, //new 
  input  logic [2:0]          freq_ifc_msg //new
);

  logic [logBitsN-1:0] packet_size_reg_out;
  logic                packet_size_reg_en;
  logic [logCSN-1:0]   cs_addr_reg_out;
  logic                cs_addr_reg_en;
  logic [logBitsN-1:0] sclk_counter;
  logic                sclk_counter_en;
  logic [2:0]          freq_counter; //new
  logic                freq_counter_en; //new
  logic [2:0]          freq_reg_out; //new
  logic                freq_reg_en; //new
  logic [nbits-1:0]    shreg_in_out;
  logic [nbits-1:0]    shreg_out_out;
  logic                freq_refill;

  vc_EnResetReg #(logBitsN) packet_size_reg (
    .clk(clk),   
    .reset(reset), 
    .q(packet_size_reg_out),     
    .d(packet_size_ifc_msg),     
    .en(packet_size_reg_en)     
  );

  vc_EnResetReg #(logCSN) cs_addr_reg (
    .clk(clk),   
    .reset(reset), 
    .q(cs_addr_reg_out),     
    .d(cs_addr_ifc_msg),     
    .en(cs_addr_reg_en)     
  );

  vc_EnResetReg #(3) freq_reg (
    .clk(clk),   
    .reset(reset), 
    .q(freq_reg_out),     
    .d(freq_ifc_msg),     
    .en(freq_reg_en)     
  );

  assign packet_size_ifc_rdy = recv_rdy;
  assign cs_addr_ifc_rdy = recv_rdy;
  assign freq_ifc_rdy = recv_rdy; //new

  logic sclk_negedge;
  logic sclk_posedge;
  logic shreg_out_rst;

  typedef enum logic [3:0] {STATE_INIT, STATE_START0, STATE_START1, STATE_SCLK_HIGH, 
                            STATE_SCLK_LOW, STATE_SCLK_HIGH_HOLD, STATE_SCLK_LOW_HOLD, 
                            STATE_CS_LOW_WAIT, STATE_DONE} state_t;

  state_t state, next_state;

  //state transition logic
  always_ff @( posedge clk ) begin : up_state
    if (reset) state <= STATE_INIT;
    else state <= next_state; 
  end

  //next state logic
  always_comb begin : up_stateChange
    case(state)
      STATE_INIT : next_state = (recv_val) ? STATE_START0 : STATE_INIT;
      STATE_START0 : next_state = STATE_START1;
      STATE_START1 : next_state = STATE_SCLK_HIGH;
      STATE_SCLK_HIGH : 
        if (freq_counter == 0) next_state = STATE_SCLK_LOW;
        else next_state = STATE_SCLK_HIGH_HOLD;
      STATE_SCLK_LOW : 
        if (freq_counter == 0) next_state = (sclk_counter == 0) ? STATE_CS_LOW_WAIT : STATE_SCLK_HIGH;
        else next_state = STATE_SCLK_LOW_HOLD;
      STATE_SCLK_HIGH_HOLD : //new
        if (freq_counter == 0) next_state = STATE_SCLK_LOW;
        else next_state = STATE_SCLK_HIGH_HOLD;
      STATE_SCLK_LOW_HOLD : //new
        if (freq_counter == 0) next_state = (sclk_counter == 0) ? STATE_CS_LOW_WAIT : STATE_SCLK_HIGH;
        else next_state = STATE_SCLK_LOW_HOLD;
      STATE_CS_LOW_WAIT : next_state = STATE_DONE;
      STATE_DONE : begin
        if (recv_val) next_state = STATE_START0;
        else if (send_rdy) next_state = STATE_INIT;
        else next_state = STATE_DONE;
      end
      default : next_state = STATE_INIT;
    endcase
  end
    
  // state outputs
  always_comb begin : up_stateOutputs
    recv_rdy = 0;
    send_val = 0;
    spi_ifc_sclk = 0;
    packet_size_reg_en = 0;
    cs_addr_reg_en = 0;
    for (integer i=0; i < ncs; i++) begin
      spi_ifc_cs[i] = 1;
    end
    sclk_negedge = 0;
    sclk_posedge = 0;
    sclk_counter_en = 0;
    shreg_out_rst = 0;

    if (state == STATE_INIT) begin
      recv_rdy           = 1;
      packet_size_reg_en = packet_size_ifc_val;
      cs_addr_reg_en     = cs_addr_ifc_val;
      freq_reg_en        = freq_ifc_val;
    end else if (state == STATE_START0) begin
      spi_ifc_cs[cs_addr_reg_out] = 0;
      shreg_out_rst       = 1;
    end else if (state == STATE_START1) begin
      sclk_posedge        = 1;
      spi_ifc_cs[cs_addr_reg_out] = 0;
    end else if (state == STATE_SCLK_HIGH) begin
      spi_ifc_cs[cs_addr_reg_out] = 0;
      spi_ifc_sclk                = 1;
      sclk_negedge                 = 1;
      sclk_counter_en              = 1;
      freq_counter_en              = 0;
      freq_refill                  = 1;
    end else if (state == STATE_SCLK_LOW) begin
      sclk_posedge                = (sclk_counter != 0);
      spi_ifc_cs[cs_addr_reg_out] = 0;
      freq_counter_en             = 0;
      freq_refill                 = 1;
    end else if (state == STATE_SCLK_HIGH_HOLD) begin
      spi_ifc_cs[cs_addr_reg_out] = 0;
      spi_ifc_sclk                = 1;
      sclk_negedge                 = 1;
      freq_counter_en              = 1;
      freq_refill                  = 0;
    end else if (state == STATE_SCLK_LOW_HOLD) begin
      sclk_posedge                = (sclk_counter != 0);
      spi_ifc_cs[cs_addr_reg_out] = 0;
      freq_counter_en             = 1;
      freq_refill                 = 0;
    end else if (state == STATE_CS_LOW_WAIT) begin
      spi_ifc_cs[cs_addr_reg_out] = 0;
    end else if (state == STATE_DONE) begin
      recv_rdy           = 1;
      send_val           = 1;
      packet_size_reg_en = packet_size_ifc_val;
      cs_addr_reg_en     = cs_addr_ifc_val;
      freq_reg_en        = freq_ifc_val;
    end
  end

  //sclk counter logic
  always_ff @( posedge clk ) begin
    if (reset) sclk_counter <= 0;
    else if (recv_val & recv_rdy) sclk_counter <= packet_size_reg_out;
    else if (sclk_counter_en) sclk_counter <= sclk_counter - 1;
  end

  //freq counter logic
  always_ff @( posedge clk ) begin
    if (reset) freq_counter <= 0;
    else if ((recv_val & recv_rdy) | freq_refill) freq_counter <= freq_reg_out;
    else if (freq_counter_en) freq_counter <= freq_counter - 1;
  end

  //Datapath
  SPI_v3_components_ShiftReg #(nbits, 1'b0) shreg_in 
  (
    .clk(clk),
    .in_(spi_ifc_miso),
    .load_data(0),
    .load_en(0),
    .out(shreg_in_out),
    .reset(shreg_out_rst),
    .shift_en(sclk_posedge) 
  );

  SPI_v3_components_ShiftReg #(nbits, 1'b0) shreg_out 
  (
    .clk(clk),
    .in_(0),
    .load_data(recv_msg << (nbits-packet_size_reg_out)), // put message into most significant bits
    .load_en(recv_rdy & recv_val),
    .out(shreg_out_out),
    .reset(reset),
    .shift_en(sclk_negedge) 
  );

  assign spi_ifc_mosi = shreg_out_out[nbits-1];
  assign send_msg = shreg_in_out;

endmodule

`endif /*SPI_V3_COMPONENTS_SPIMASTER_V*/
