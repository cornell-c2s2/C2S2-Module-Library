module DecoderVRTL 
#(
	parameter m = 3,
	parameter n = 1'b1 << m  // n = 2 ** m
)(
`ifdef USE_POWER_PINS
	inout vccd1,
	inout vssd1,
`endif

	input enable,
	input  reg [m-1:0] x,
	output reg [n-1:0] y
);
	always @(*)
		if (!enable)
			y = {n {1'b0}};
		else
			y = {{n - 1 {1'b0}}, 1'b1} << x;
endmodule
