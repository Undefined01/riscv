module counter #(
	parameter bound = 2,
	parameter width = $clog2(bound)
) (
	input clk,
	input reset,
	input ena,
	output reg [width-1:0] num,
	output carry
);

	wire [63:0] w_zero  = 0;
	wire [63:0] w_bound = bound;

	assign carry = ena && (num == w_bound[width-1:0]);

	always @ (posedge clk or posedge reset)
		if (reset)
			num = 0;
		else if (ena)
			num = carry ? w_zero[width-1:0] : num + 1'b1;

endmodule
