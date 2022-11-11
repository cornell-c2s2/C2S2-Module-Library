`ifndef FIXED_POINT_ITERATIVE_MULTIPLIER
`define FIXED_POINT_ITERATIVE_MULTIPLIER

`include "muxes.v"
`include "regs.v"


module FpmultVRTL
 #(
	parameter n = 32, // bit width
	parameter d = 16 // number of decimal bits
  ) 
  ( 
	input  logic 		       clk, 
	input  logic 		       reset,

	input  logic		       recv_val, //rcv_val, 
	output logic 		       recv_rdy, //rcv_rdy, 
	input  logic [2*n-1:0] recv_msg, //a and b

  output logic 		       send_val, //snd_val, 
	input  logic	         send_rdy, //snd_rdy,
	output logic [n-1:0]   send_msg //c
	);

	// performs the operation c = a*b
	// Equivalent to taking the integer representations of both numbers,
	// multiplying, and then shifting right
	logic [n-1:0] a, b;
	logic [n-1:0] c;

	assign a = recv_msg[2*n-1:n];
	assign b = recv_msg[n-1:0];
  assign send_msg = c;

  logic a_mux_sel;
  logic b_mux_sel;
  logic result_mux_sel;
  logic add_mux_sel;

  logic result_en;

  logic b_lsb;

  fpmulit_control #(n, d) ctrl
  (
  .clk(clk),
  .reset(reset),

  .recv_val(recv_val),
  .recv_rdy(recv_rdy),

  .send_val(send_val),
  .send_rdy(send_rdy),

  .a_mux_sel(a_mux_sel),
  .b_mux_sel(b_mux_sel),
  .result_mux_sel(result_mux_sel),
  .add_mux_sel(add_mux_sel),

  .result_en(result_en),

  .b_lsb(b_lsb)
  );

  fpmult_datapath #(n, d) dpath
  (
  .clk(clk),
  .reset(reset),

  .a(a),
  .b(b),
  .c(c),

  .a_mux_sel(a_mux_sel),
  .b_mux_sel(b_mux_sel),
  .result_mux_sel(result_mux_sel),
  .add_mux_sel(add_mux_sel),

  .result_en(result_en),

  .b_lsb(b_lsb)
  );

endmodule

module fpmult_datapath
 #(
  parameter n = 32, //bit width
  parameter d = 16
  )
  (
  input  logic         clk,
  input  logic         reset,

  input  logic [n-1:0] a,
  input  logic [n-1:0] b,
  output logic [n-1:0] c,

  input  logic         a_mux_sel,
  input  logic         b_mux_sel,
  input  logic         result_mux_sel,
  input  logic         add_mux_sel,

  input  logic         result_en,

  output logic         b_lsb
  );

  logic [n-1:0]     b_reg_in;
  logic [n-1:0]     a_reg_in;
  logic [(n+d)-1:0] result_reg_in;

  logic [n-1:0]     b_reg_out;
  logic [n-1:0]     a_reg_out;
  logic [(n+d)-1:0] result_reg_out;

  logic [(n+d)-1:0] add_mux_out;
  logic [(n+d)-1:0] adder_out;

  assign b_lsb     = b_reg_out[0];
  assign c         = result_reg_out[n-1:0];
  assign adder_out = result_reg_out + { {d{a_reg_out[n-1]}},a_reg_out[n-1:0]};;

  vc_Mux2 #(n)   a_mux      (.in0(a_reg_out << 1            ), .in1(a),              .sel(a_mux_sel),      .out(a_reg_in));
  vc_Mux2 #(n)   b_mux      (.in0(b_reg_out >> 1            ), .in1(b),              .sel(b_mux_sel),      .out(b_reg_in));
  vc_Mux2 #(n+d) result_mux (.in0(add_mux_out               ), .in1(0),              .sel(result_mux_sel), .out(result_reg_in));
  vc_Mux2 #(n+d) add_mux    (.in0(adder_out),                  .in1(result_reg_out), .sel(add_mux_sel),    .out(add_mux_out));

  vc_EnResetReg #(n,0)   a_reg      (.clk(clk), .reset(reset), .en(1'b1),      .d(a_reg_in),      .q(a_reg_out));
  vc_EnResetReg #(n,0)   b_reg      (.clk(clk), .reset(reset), .en(1'b1),      .d(b_reg_in),      .q(b_reg_out));
  vc_EnResetReg #(n+d,0) result_reg (.clk(clk), .reset(reset), .en(result_en), .d(result_reg_in), .q(result_reg_out));

endmodule


module fpmulit_control
 #(
  parameter n = 32,
  parameter d = 16
  )
  (
  input  clk,
  input  reset,

  input  logic recv_val,
  output logic recv_rdy,

  output logic send_val,
  input  logic send_rdy,

  output logic a_mux_sel,
  output logic b_mux_sel,
  output logic result_mux_sel,
  output logic add_mux_sel,

  output logic result_en,

  input logic b_lsb
  );

  localparam [1:0]
    IDLE = 2'd0,
    CALC = 2'd1,
    DONE = 2'd2;
  
  logic [2:0] next_state;
  logic [2:0] state;
  logic       count_en;
  logic [7:0] counter;
  logic       cnt_rst;

  always @(*) begin
    case(state)
      IDLE: begin
       if(recv_val) next_state = CALC;
       else            next_state = IDLE;
      end
      CALC: begin
       if(counter == n) next_state = DONE;
       else             next_state = CALC;
      end
      DONE: begin
        if(send_rdy) next_state = IDLE;
        else            next_state = DONE; 
      end 
      default: next_state = IDLE;
    endcase
  end


  always @(*) begin
    case(state)
      IDLE: begin
        a_mux_sel = 1; b_mux_sel = 1; result_mux_sel = 1; add_mux_sel = 0; result_en = 1; count_en = 0; cnt_rst =0; recv_rdy = 1; send_val = 0;
      end
      CALC: begin
        if(b_lsb) begin 
          a_mux_sel = 0; b_mux_sel = 0; result_mux_sel = 0; add_mux_sel = 0; result_en = 1; count_en = 1; cnt_rst =0; recv_rdy = 0; send_val = 0;
        end
        else begin 
          a_mux_sel = 0; b_mux_sel = 0; result_mux_sel = 0; add_mux_sel = 1; result_en = 1; count_en = 1; cnt_rst =0; recv_rdy = 0; send_val = 0;
        end
      end
      DONE: begin
        a_mux_sel = 0; b_mux_sel = 0; result_mux_sel = 0; add_mux_sel = 1; result_en = 0; count_en = 0; cnt_rst =1; recv_rdy = 0; send_val = 1;
      end
      default: begin
        a_mux_sel = 1; b_mux_sel = 1; result_mux_sel = 1; add_mux_sel = 0; result_en = 1; count_en = 0; cnt_rst =0; recv_rdy = 0; send_val = 0;
      end
    endcase
  end

  always @(posedge clk) begin
    if(reset) begin 
      state <= IDLE;
    end
    else begin     
      state <= next_state;
    end
  end

  always @(posedge clk) begin
    if(reset || cnt_rst) begin
      counter <= 0;
    end
    else if(count_en) counter <= counter + 1;
    else counter <= counter;
  end

endmodule

`endif
