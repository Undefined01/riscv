`include "scancode.h"

module ps2_keyboard(
	input  wire	clk,
	input  wire	rst,
	input  wire	ps2_clk,
	input  wire	ps2_data,
	input  wire	nextdata_n,
	output wire	keyup,
	output wire	extend,
	output wire	[7:0] scancode,
	output reg	ready,
	output reg	overflow
);

	reg [9:0] fifo[7:0];
	reg [2:0] w_ptr, r_ptr;
	
	wire sampling;
	get_negedge ps2_negedge (clk, rst, ps2_clk, sampling);
	
	reg [3:0] count;
	reg [9:0] buffer;
	wire [7:0] new_scancode = buffer[8:1];
	reg keyup_reg, extend_reg;
	
	reg last_keyup, last_extend;
	reg [7:0] last_scancode;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			w_ptr <= 3'b0;
			r_ptr <= 3'b0;
			ready <= 1'b0;
			overflow <= 1'b0;
			
			count <= 4'b0;
			{keyup_reg, extend_reg} <= 2'b0;
			
			{last_keyup, last_extend} <= 2'b0;
			last_scancode <= 8'b0;
		end
		else begin : keyboard_handler
			reg sampled, parsed;
			{sampled, parsed} = 2'b0;
			
			if (ready & ~nextdata_n) begin
				r_ptr <= r_ptr + 1'b1;
				ready <= (r_ptr + 1'b1) != w_ptr;
			end
			
			if (sampling) begin
//				$display("Sampling %d: %x", count, ps2_data);
				if (count == 4'd10) begin
					// If it is a valid data frame
					if (buffer[0] == 0 && ps2_data && ^buffer[9:1]) begin
						sampled = 1'b1;
					end
					count <= 4'b0;
				end
				else begin
					buffer[count] <= ps2_data;
					count <= count + 1'b1;
				end
			end
			if (sampled) begin
				$display("Parsing %x", new_scancode);
				case (new_scancode)
				`KEYUP:
					keyup_reg <= 1'b1;
				`KEYEXTEND:
					extend_reg <= 1'b1;
				default: begin
					// If this is not the same event as previous
					if (last_keyup != keyup_reg || last_extend != extend_reg || last_scancode != new_scancode) begin
						$display("Ready %x", new_scancode);
						parsed = 1'b1;
					end
					{keyup_reg, extend_reg} <= 2'b0;
					last_keyup <= keyup_reg;
					last_extend <= extend_reg;
					last_scancode <= new_scancode;
				end
				endcase
			end
			if (parsed) begin
				fifo[w_ptr] <= {keyup_reg, extend_reg, new_scancode};
				ready <= 1'b1;
				w_ptr <= w_ptr + 1'b1;
				overflow <= overflow | (r_ptr == (w_ptr + 1'b1));
			end
		end
	end

	assign {keyup, extend, scancode} = fifo[r_ptr];
	
endmodule
