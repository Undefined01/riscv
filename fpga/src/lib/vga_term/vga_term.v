module vga_term #(
	parameter char_w = 9,
	parameter char_h = 16,
	parameter term_w = 70,
	parameter term_h = 30
) (
	input  wire			clk_50M,	// 50MHz 时钟
	input  wire			rst,		// 置位
	output wire	[11:0]	charidx,	// 提供给上层模块的当前扫描字符坐标
	input  wire	[7:0]	char,
	output wire			vga_clk,	// 25MHz 时钟
	output wire			sync_n,		// 同步信号
	output wire			hsync,		// 行同步和列同步信号
	output wire			vsync,
	output wire			valid,		// 消隐信号
	output reg	[7:0]	vga_r,		// 红绿蓝颜色信号
	output reg	[7:0]	vga_g,
	output reg	[7:0]	vga_b
);

	// 640x480 分辨率下的 VGA 参数设置
	localparam h_frontporch = 96;
	localparam h_active = 144;
	localparam h_backporch = 784;
	localparam h_total = 800;
	
	localparam v_frontporch = 2;
	localparam v_active = 35;
	localparam v_backporch = 515;
	localparam v_total = 525;
	
	wire clk_25M;
	clk_div #(2) clk_div_25M (clk_50M, 1'b1, rst, clk_25M);
	assign vga_clk = clk_25M;


	// 像素计数值
	wire [9:0] x, y;
	wire xcarry, ycarry;
	counter #(h_total-1, 10) x_cnt (clk_25M, rst,   1'b1, x, xcarry);
	counter #(v_total-1, 10) y_cnt (clk_25M, rst, xcarry, y, ycarry);
	
	// 生成同步信号
	assign sync_n = 1'b0;
	assign hsync = (x >= h_frontporch);
	assign vsync = (y >= v_frontporch);
	
	// 生成消隐信号
	wire h_valid = x >= h_active && x < h_backporch;
	wire v_valid = y >= v_active && y < v_backporch;
	assign valid = h_valid && v_valid;
	
	// 计算当前输出字符
	reg h_invalid;
	reg [3:0] col, row;		// 正在发送当前字符的row行，col列
	reg [6:0] char_col;		// 当前发送字符在term的col列
	reg [11:0] base;		// 当前发送行首字符为第base个
	always @(posedge clk_25M or posedge rst)
		if (rst) begin
			h_invalid <= 1'b0;
			row <= 4'b0;
			col <= 4'b0;
			char_col <= 7'b0;
			base <= 8'b0;
		end
		else begin
			if (x < h_active || x >= h_backporch) begin
				h_invalid <= 1'b0;
				col <= 4'b0;
				char_col <= 7'b0;
				if (y < v_active || y >= v_backporch) begin
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
	
	// 设置输出的颜色值
	wire [11:0] data_row;

	char_rom char_rom(clk_50M, char, row, data_row);
	
	always @(posedge clk_50M)
		{vga_r, vga_g, vga_b} <= {24{h_invalid ? 1'b0 : data_row[col]}};
		
endmodule

module char_rom(
	input  wire			clk,
	input  wire	[7:0]	char,
	input  wire	[3:0]	row,
	output reg	[11:0]	data_row
);

	(* ram_init_file = "vga_term/vga_font.mif" *)
	(* ram_style = "distributed" *)
	reg [11:0] ram[256*16-1:0];
	
	wire [12:0] addr = {char, row};
	always @(posedge clk) data_row <= ram[addr];

endmodule
