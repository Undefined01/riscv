module ps2_keyboard(
	input clk,
	input clr_,
	input ps2_clk,
	input ps2_data,
	input nextdata_,
	output [7:0] data,
	output reg ready,
	output reg overflow
);

	reg [9:0] buffer;
	reg [7:0] fifo[7:0];
	reg [2:0] w_ptr, r_ptr;

	reg [3:0] count; // count ps2_data bits
	// detect falling edge of ps2_clk
	reg [2:0] ps2_clk_sync;

	always @(posedge clk) begin
		ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
	end

	wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

	always @(posedge clk) begin
		if (!clr_) begin
			count <= 0;
			w_ptr <= 0;
			r_ptr <= 0;
			ready <= 0;
			overflow <= 0;
		end
		else begin
			if (ready && !nextdata_) begin //read next data
				r_ptr <= r_ptr + 1'b1;
				ready <= w_ptr != (r_ptr + 1'b1);
			end
			if (sampling) begin
				if (count == 4'd10) begin
					// If start code and stop code are detected, and parity check passed
					if (buffer[0] == 0 && ps2_data && ^buffer[9:1]) begin
						fifo[w_ptr] <= buffer[8:1];
						w_ptr <= w_ptr + 1'b1;
						ready <= 1'b1;
						overflow <= overflow | (r_ptr == (w_ptr + 1'b1));
					end
					count <= 0;
				end
				else begin
					buffer[count] <= ps2_data;
					count <= count + 1'b1;
				end
			end
		end
	end
	assign data = fifo[r_ptr]; //always set output data

endmodule
