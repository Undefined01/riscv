module clk_div
#(
	parameter div_num
) (
	input clk,
	input ena,
	input reset,
	output reg clk_out
);
	// 仅适用于偶数
	localparam bound = div_num / 2 - 1;
	localparam width = div_num >= 8 ? $clog2(bound) : 2;

	reg [width-1:0] counter = 0;
	
	always @ (posedge clk or posedge reset) begin
		if (reset) begin
			counter = 0;
			clk_out = 0;
		end
		else if (ena) begin
			if (counter == bound) begin
				counter = 0;
				clk_out = ~clk_out;
			end
			else counter = counter + 1'b1;
		end
	end
	
endmodule
	