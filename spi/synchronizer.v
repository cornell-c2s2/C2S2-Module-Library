module synchronizer (
  input logic clk,
  input logic reset,
  input logic in,
  output logic out
);

// shift reg
  logic [2:0] value;

// shift things over every cycle
  always @(posedge clk) begin 
    if (reset) begin 
      value <= 3'd0;
    end else begin 
      value <= {value[2:0], in};
    end
  end

  assign out = value[1];
endmodule