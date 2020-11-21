module vga_ctrl(
	input pclk,				// 25MHz时钟
	input reset,			// 置位
	input [23:0] vga_data,	// 上层模块提供的VGA颜色数据
	output [9:0] h_addr,	// 提供给上层模块的当前扫描像素点坐标
	output [9:0] v_addr,
	output hsync,			// 行同步和列同步信号
	output vsync,
	output valid,			// 消隐信号
	output [7:0] vga_r,		// 红绿蓝颜色信号
	output [7:0] vga_g,
	output [7:0] vga_b
);

	// 640x480 分辨率下的 VGA 参数设置
	parameter h_frontporch = 96;
	parameter h_active = 144;
	parameter h_backporch = 784;
	parameter h_total = 800;
	
	parameter v_frontporch = 2;
	parameter v_active = 35;
	parameter v_backporch = 515;
	parameter v_total = 525;
	
	// 像素计数值
	reg [9:0] x_cnt;
	reg [9:0] y_cnt;
	
	always @(posedge reset or posedge pclk) // 行像素计数
		if (reset)
			x_cnt <= 1;
		else if (x_cnt == h_total)
			x_cnt <= 1;
		else
			x_cnt <= x_cnt + 1'b1;
		
	always @(posedge reset or posedge pclk)  // 列像素计数
		if (reset)
			y_cnt <= 1;
		else begin
			if (y_cnt == v_total & x_cnt == h_total)
				y_cnt <= 1;
			else if (x_cnt == h_total)
				y_cnt <= y_cnt + 1'b1;
		end
	
	// 生成同步信号
	assign hsync = (x_cnt > h_frontporch);
	assign vsync = (y_cnt > v_frontporch);
	
	// 生成消隐信号
	wire h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
	wire v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
	assign valid = h_valid & v_valid;
	
	// 计算当前有效像素坐标
	assign h_addr = h_valid ? (x_cnt - h_active - 1'b1) : {10{1'b0}};
	assign v_addr = v_valid ? (y_cnt - v_active - 1'b1) : {10{1'b0}};
	
	// 设置输出的颜色值
	assign {vga_r, vga_g, vga_b} = vga_data[23:0];

endmodule
