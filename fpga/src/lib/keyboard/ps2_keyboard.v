module ps2_keyboard(
	input  wire	clk,
	input  wire	rst,
	input  wire	ps2_clk,
	input  wire	ps2_data,
	output reg	ready,
	output reg	[7:0] scancode
);

	reg [9:0] buffer;
	reg [3:0] count;

	reg [2:0] ps2_clk_sync;
	always @(posedge clk)
		ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};

	wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];


	always @(posedge clk)
		if (rst) begin
			count <= 0;
			ready <= 0;
		end
		else begin
			ready <= 1'b0;
			if (sampling) begin
				if (count == 4'd10) begin
					// If start code and stop code are detected, and parity check passed
					if (~buffer[0] && ps2_data && ^buffer[9:1]) begin
						ready <= 1'b1;
						scancode <= buffer[8:1];
					end
					count <= 0;
				end
				else begin
					buffer[count] <= ps2_data;
					count <= count + 1'b1;
				end
			end
		end

endmodule
