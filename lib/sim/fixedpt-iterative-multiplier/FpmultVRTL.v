`ifndef FIXED_POINT_ITERATIVE_MULTIPLIER
`define FIXED_POINT_ITERATIVE_MULTIPLIER

interface stateI #( parameter n, parameter d ) ();
  logic [n+d-1:0] acc; // this needs to be n+d bits because the decimal portion of the multiplication may overflow
  logic [$clog2(n+1)-1:0] counter;

  modport in ( input acc, input counter );
  modport out ( output acc, output counter );
  modport io ( inout acc, inout counter );
endinterface

module fpmulit_inner # (
  parameter n,
  parameter d,
  parameter sign
) (a, b, in, out, rdy);
  input logic [n-1:0] b;
  input logic [n+d-1:0] a;
  output logic rdy;
  stateI.in in;
  stateI.out out;

  reg [n+d-1:0] tmp;
  reg [2*n-1:0] tt;
  always @(*) begin
    tmp = 0;
    if (b[in.counter]) begin
      tmp = a << in.counter;
      if (sign & in.counter == n-1) begin// sign bit (if multiplier is signed)
        tt = { {(n-d){a[n+d-1]}}, a};
        tt = ((tt << n) - tt) << (n-1);
        tmp = tt[n+d-1:0];
      end
    end
    tmp = tmp + in.acc;     
    rdy = in.counter == n-1;
    out.acc = tmp;
    out.counter = in.counter + 1;
  end
endmodule

module FpmultVRTL
# (
  parameter n = 32, // bit width
  parameter d = 16, // number of decimal bits
  parameter sign = 1 // 1 if signed, 0 otherwise.
) (clk, reset, recv_val, recv_rdy, send_val, send_rdy, a, b, c);
  // performs the operation c = a*b
  // Equivalent to taking the integer representations of both numbers,
  // multiplying, and then shifting right
  input logic clk, reset;
  input logic recv_val, send_rdy;
  input logic [n-1:0] a, b;
  output logic [n-1:0] c;
  output logic send_val, recv_rdy;
  reg [n-1:0] hb, hc;
  reg [n+d-1:0] ha;
  reg rdy;
  stateI #(.n(n), .d(d)) cinI ();
  stateI #(.n(n), .d(d)) ctI ();

  fpmulit_inner #(.n(n), .d(d), .sign(sign)) mult (
    .a(ha),
    .b(hb),
    .in(cinI),
    .out(ctI),
    .rdy(rdy)
  );

  always @(posedge clk) begin
    if (reset) begin
      recv_rdy <= 1;
      send_val <= 0;
    end

    if (recv_val & recv_rdy) begin // we are ready to recieve data
      ha <= {{d{(sign != 0) & a[n-1]}}, a};
      hb <= b;
      recv_rdy <= 0;
      cinI.acc <= 0;
      cinI.counter <= 0;
      send_val <= 0;
    end

    if (~recv_rdy) begin
      cinI.acc <= ctI.acc;
      cinI.counter <= ctI.counter;
    end

    if (~recv_rdy & send_rdy & send_val) begin // reciever is ready for input
      recv_rdy <= 1;
    end

    if (rdy & ~recv_rdy & ~send_val) begin
      send_val <= 1;
      c <= ctI.acc[n+d-1:d];
    end
  end
endmodule
`endif
