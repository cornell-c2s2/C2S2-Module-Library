`ifndef CONFIG_REG_V
`define CONFIG_REG_V

module ConfigRegVRTL
#(
  // Parameters
  parameter addr_size = 4,
  parameter payload_size = 8,
  parameter set_config_address = 4'b0000
)(
  // I/O
  input logic clk,
  input logic reset,
  input logic [addr_size + payload_size:0] rec_msg,
  output logic [addr_size + payload_size:0] send_msg
);

// Local Variables
logic [addr_size - 1:0] config_addr = 4'b0000;;
logic [addr_size - 1:0] addr;
logic write;
logic success;
logic [payload_size - 1:0] payload;

// Register
always @(posedge clk) begin
  if (reset) begin
    send_msg <= '0;
  end
  else begin
    send_msg <= {addr, success, payload};
  end
end

// Control
always @(*) begin
  if(rec_msg[addr_size + payload_size: payload_size + 1] == config_addr && rec_msg[payload_size]) begin
    addr = rec_msg[addr_size + payload_size: payload_size + 1];
    success = 1'b1;
    payload = rec_msg[payload_size - 1:0]; 
  end
  else begin
    addr = '0;
    success = 1'b0;
    payload = '0; end
end

endmodule

`endif