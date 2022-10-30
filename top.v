`ifndef spi_master
`define spi_master
`endif

`include "spi_master.v"
`include "shiftreg.v"
`include "counter.v"

module top #(parameter nbits = 34) (
    // SPECIFY I/O HERE
    input reset,
    input clk,

    input logic packet_size_ifc_val, 
    output logic packet_size_ifc_rdy,
    input logic [$clog2(nbits)-1:0] packet_size_ifc_msg,    

    output logic send_val,
    input logic send_rdy,
    output logic recv_rdy,
    input logic recv_val,
    input [nbits-1:0] recv_msg, // since this is serial, why not 1 bit?
    output [nbits-1:0] send_msg, // same here

    output cs0,
    output sclk,
    output mosi,
    input miso
);
    
    logic recv_rdy_out;
    assign recv_rdy = recv_rdy_out;

    logic sclk_negedge;
    logic sclk_posedge;

    logic count_en;
    logic count_rst;
    logic count

    spi_master_ctrl fsm (
        //MAKE CONNECTIONS HERE
        .recv_rdy(rcv_rdy_out),
        .sclk_negedge(sclk_negedge),
        .count_increment(count_en),
        .count_reset(count_rst)
        .count(count)
    );

    counter count (
        .rst(count_rst),
        .clk(clk),
        .en(count_en),
        .out(count)
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
