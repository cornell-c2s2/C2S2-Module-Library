module synchronizer (
  input logic clk,
  input logic reset,
  input logic inp,
  output logic outp
);

// shift reg
  logic [2:0] value;

// shift things over every cycle
  always @(posedge clk) begin 
    if (reset) begin 
      value <= 3'd0;
    end else begin 
      value <= {value[2:0], inp};
    end
  end

  assign outp = value[1];
endmodule