`ifndef spi_master
`define spi_master
`endif

`include "spi_master.v"
`include "shiftreg.v"

module top (
    // SPECIFY I/O HERE
    input reset,
    input clk,

    input logic packet_size_ifc, // bit width?
    input logic cs_addr_ifc,  // might exclude if we only use one cs
    output logic send_val,
    input logic send_rdy,
    output logic recv_rdy,
    input logic recv_val,
    input recv_msg, // bit width?
    output send_msg,
    output cs0,
    output sclk,
    output mosi,
    input miso
);
    
    wire recv_rdy_out;
    assign recv_rdy = recv_rdy_out;

    wire sclk_negedge;
    wire sclk_posedge;

    spi_master_ctrl fsm (
        //MAKE CONNECTIONS HERE
        .recv_rdy(rcv_rdy_out),
        .sclk_negedge(sclk_negedge)
    );

    shiftreg shregout (
        .clk(clk),
        .reset(reset),
        .load_en(recv_val & recv_rdy_out),
        .shift_en(sclk_negedge),
        .in(1'b0),
        .load_data(), //fill in
        .out(mosi) 
    );

    shiftreg shregin (
        .clk(clk),
        .reset(reset),
        .load_en(1'b0),
        .shift_en(sclk_posedge),
        .in(miso),
        .load_data(1'b0),
        .out(send_msg)
    );
