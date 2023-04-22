`include "ConfigRegVRTL.v"

// iverilog -g2012 -o ConfigRegVRTLTest ConfigRegVRTLTest.v

module top;
  parameter addr_size = 4;
  parameter payload_size = 8;

  logic clk = 1;
  always #5 clk = ~clk;

  logic reset;
  logic [addr_size + payload_size:0] rec_msg;
  logic [addr_size + payload_size:0] send_msg;

  ConfigRegVRTL config_reg
  (
    .clk(clk),
    .reset(reset),
    .rec_msg(rec_msg),
    .send_msg(send_msg)
  );

  initial begin
    $dumpfile("ConfigRegVRTLTest.vcd");
    $dumpvars;
  
  reset = 1'b1;
  rec_msg = 13'b0000111111111;
  #11;      
  $display( " TEST 1 (reset): rec_msg = %b,  send_msg= %b", rec_msg, send_msg);

  reset = 1'b0;
  rec_msg = 13'b0000101010101;
  #10;
  $display( " TEST 2 (addr matches, write): rec_msg = %b,  send_msg= %b", rec_msg, send_msg);

  reset = 1'b0;
  rec_msg = 13'b0000001010101;
  #10;
  $display( " TEST 3 (addr matches, no write): rec_msg = %b,  send_msg= %b", rec_msg, send_msg);

  reset = 1'b0;
  rec_msg = 13'b0101101010101;
  #10;
  $display( " TEST 4 (addr doesn't match, write): rec_msg = %b,  send_msg= %b", rec_msg, send_msg);
  
  reset = 1'b0;
  rec_msg = 13'b0101001010101;
  #10;
  $display( " TEST 5 (addr doesn't match, no write): rec_msg = %b,  send_msg= %b", rec_msg, send_msg);


  $finish;
  end


endmodule