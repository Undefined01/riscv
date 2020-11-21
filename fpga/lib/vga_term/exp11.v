`default_nettype none

module exp11(
	//////////// CLOCK //////////
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input CLOCK4_50,
	//////////// KEY //////////
	// 按钮，按下为低电平
	input [3:0] KEY,
//	//////////// SW //////////
//	input [9:0] SW,
//	//////////// LED //////////
	output [9:0] LEDR,
//	//////////// Seg7 //////////
//	output [6:0] HEX0,
//	output [6:0] HEX1,
//	output [6:0] HEX2,
//	output [6:0] HEX3,
//	output [6:0] HEX4,
//	output [6:0] HEX5,
	//////////// PS2 //////////
	inout PS2_CLK,
	inout PS2_DAT,
	//////////// VGA //////////
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_CLK,
	output VGA_HS,
	output VGA_VS,
	output VGA_SYNC_N,
	output VGA_BLANK_N
);

	parameter char_w = 9;
	parameter char_h = 16;
	parameter term_w = 70;
	parameter term_h = 30;
	
	wire reset = ~KEY[0];
	
	
	wire clk_500ms;
	clk_div #(25_000_000) clk500ms (CLOCK_50, 1'b1, reset, clk_500ms);
	
	(* ram_init_file = "null.mif" *) reg [7:0] term[term_w*term_h-1:0];
	
	wire [11:0] charidx;
	reg [7:0] char, display_char;
	always @(posedge CLOCK_50) begin
		char <= term[charidx];
		if (charidx == cursor_idx)		// 光标
			display_char <= clk_500ms ? 8'h5F : 8'h00;
		else
			display_char <= char;
	end
	
	vga_terminal vga_term (
		CLOCK_50, reset,
		charidx, display_char,
		VGA_R, VGA_G, VGA_B,
		VGA_CLK, VGA_HS, VGA_VS, VGA_SYNC_N, VGA_BLANK_N
	);
	
	reg nextdata_n;
	wire keyup, extend;
	wire [7:0] scancode;
	wire ready, overflow;
	ps2_keyboard_driver kbd(
		CLOCK_50, ~reset, PS2_CLK, PS2_DAT, nextdata_n, keyup, extend, scancode, ready, overflow
	);
	
	reg shift;
	(* ram_init_file = "scancode2ascii.mif" *) reg [7:0] ascii_table[511:0];
	reg [7:0] ascii;
	always @(negedge CLOCK_50)
		ascii <= ascii_table[{shift, scancode}];
	
	
	`include "scancode.h"
	reg [7:0] line_length[term_h-1:0];
	reg [7:0] cursor_row, cursor_col;
	wire [11:0] cursor_base = cursor_row * term_w;
	wire [11:0] cursor_last = cursor_base + line_length[cursor_row - 1'b1];
	wire [11:0] cursor_idx = cursor_base + cursor_col;
	
	always @(posedge CLOCK_50 or posedge reset)
		if (reset) begin
			cursor_row <= 8'b0;
			cursor_col <= 8'b0;
		end
		else begin
			nextdata_n <= 1'b1;
			if (ready && nextdata_n) begin
				nextdata_n <= 1'b0;
				if (scancode == `KEY_LSHIFT || scancode == `KEY_RSHIFT)
					shift <= keyup ^ 1'b1;
				if (!keyup) begin
					case (scancode)
					`KEY_ENTER: begin
						line_length[cursor_row] <= cursor_col;
						cursor_col <= 8'b0;
						cursor_row <= cursor_row + 1'b1;
					end
					`KEY_BACK: begin
						if (cursor_col == 8'b0) begin
							cursor_col <= line_length[cursor_row - 1'b1];
							cursor_row <= cursor_row - 1'b1;
							term[cursor_idx - 1'b1] <= 8'h00;
						end
						else begin
							cursor_col <= cursor_col - 1'b1;
							term[cursor_idx - 1'b1] <= 8'h00;
						end
					end
					`KEY_LEFT: begin
						if (cursor_col != 8'b0)
							cursor_col <= cursor_col - 1'b1;
					end
					`KEY_RIGHT: begin
						if (cursor_col != term_w - 1)
							cursor_col <= cursor_col + 1'b1;
					end
					`KEY_UP: begin
						if (cursor_row != 8'b0)
							cursor_row <= cursor_row - 1'b1;
					end
					`KEY_DOWN: begin
						if (cursor_row != term_h - 1)
							cursor_row <= cursor_row + 1'b1;
					end
					default: begin
						if (ascii != 8'b0) begin
							term[cursor_idx] <= ascii;
							if (cursor_col == term_w - 1) begin
								line_length[cursor_row] <= cursor_col;
								cursor_col <= 8'b0;
								cursor_row <= cursor_row + 1'b1;
							end
							else
								cursor_col <= cursor_col + 1'b1;
						end
					end
					endcase
				end
			end
			else begin
				cursor_row <= cursor_row;
				cursor_col <= cursor_col;
			end
		end
		
	assign LEDR[9] = shift;
		
endmodule

module vga_terminal
#(
	parameter char_w = 9,
	parameter char_h = 16,
	parameter term_w = 70,
	parameter term_h = 30
) (
	input clk_50M,
	input reset,
	output [11:0] charidx,
	input [7:0] char,
	//////////// VGA //////////
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_CLK,
	output VGA_HS,
	output VGA_VS,
	output VGA_SYNC_N,
	output VGA_BLANK_N
);
	
	clk_div #(2) clk_div_25M (clk_50M, 1'b1, reset, VGA_CLK);
//	clk_div #(420_000) clk_div_frame (clk_25M, 1'b1, reset, clk_frame);
	assign VGA_SYNC_N = 1'b0;

	wire [9:0] h_addr, v_addr;
	wire [23:0] vga_data;
	vga_ctrl vga_ctrl (
		.pclk(VGA_CLK),
		.reset(reset),
		.vga_data(vga_data),
		.h_addr(h_addr),
		.v_addr(v_addr),
		.hsync(VGA_HS),
		.vsync(VGA_VS),
		.valid(VGA_BLANK_N),
		.vga_r(VGA_R),
		.vga_g(VGA_G),
		.vga_b(VGA_B)
	);
	
	reg h_invalid;
	reg [3:0] col, row;		// 正在发送当前字符的row行，col列
	reg [6:0] char_col;		// 当前发送字符在term的col列
	reg [15:0] base;		// 当前发送行首字符为第base个
	always @(negedge clk_50M or posedge reset)
		if (reset) begin
			h_invalid <= 1'b0;
			row <= 4'b0;
			col <= 4'b0;
			char_col <= 7'b0;
			base <= 8'b0;
		end
		else if (VGA_CLK) begin
			if (h_addr == 10'b0) begin
				h_invalid <= 1'b0;
				col <= 4'b0;
				char_col <= 7'b0;
				if (v_addr == 10'b0) begin
					row <= 4'b0;
					base <= 8'b0;
				end
			end
			else if (!h_invalid) begin
				if (col == char_w - 1) begin		// 当前字符的一行输出完毕
					col <= 4'b0;
					if (char_col == term_w - 1) begin	// 一行字符的一行已输出完毕
						h_invalid <= 1'b1;
						char_col <= 7'b0;
						if (row == char_h - 1) begin	// 一行字符的所有行已输出完毕
							row <= 4'b0;
							base <= base + term_w;
						end
						else
							row <= row + 1'b1;
					end
					else
						char_col <= char_col + 1'b1;
				end
				else
					col <= col + 1'b1;
			end
		end
	
	assign charidx = base + char_col;
	
	wire [11:0] data_row;
	char_rom char_rom(
		clk_50M,
		char,
		row,
		data_row
	);
	assign vga_data = {24{h_invalid ? 1'b0 : data_row[col]}};
		
endmodule

module char_rom(
	input clk,
	input [7:0] char,
	input [3:0] line,
	output reg [11:0] data_row
);

	reg [11:0] ram[256*16-1:0];
	initial $readmemh("E:/test/exp11/vga_font.txt", ram);
	
	wire [12:0] addr = {char, line};
	always @(negedge clk)
		data_row <= ram[addr];

endmodule
