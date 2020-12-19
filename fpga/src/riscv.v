`include "common.v"

module riscv(
	input  wire	CLOCK_50,
	input  wire	[3:0] KEY,
	
	//////////// LED //////////
	output wire	[9:0] LEDR,
	
	//////////// Seg7 //////////
	output wire	[6:0] HEX0,
	output wire	[6:0] HEX1,
	output wire	[6:0] HEX2,
	output wire	[6:0] HEX3,
	output wire	[6:0] HEX4,
	output wire	[6:0] HEX5,
	
	//////////// VGA //////////
	output wire	[7:0] VGA_R,
	output wire	[7:0] VGA_G,
	output wire	[7:0] VGA_B,
	output wire	VGA_CLK,
	output wire	VGA_HS,
	output wire	VGA_VS,
	output wire	VGA_SYNC_N,
	output wire	VGA_BLANK_N,
	
	//////////// PS2 //////////
	inout  wire	PS2_CLK,
	inout  wire	PS2_DAT
);

	wire clk = CLOCK_50;
	wire rst = ~KEY[0];
	
	
	wire [`DATA_BUS]	if_addr, if_data;
	wire				mem_rw;
	wire [`DATA_BUS]	mem_addr, mem_rdata, mem_wdata;
	
	wire [7:0] seg,seg2;
	
	perip perip(
		.clk(clk),
		.rst(rst),
		.if_addr(if_addr),
		.if_data(if_data),
		.mem_rw(mem_rw),
		.mem_addr(mem_addr),
		.mem_rdata(mem_rdata),
		.mem_wdata(mem_wdata),
		// VGA
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_BLANK_N(VGA_BLANK_N),
		// KBD
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT)
	);
	
	riscv_core core(
		CLOCK_50, rst,
		if_addr, if_data,
		mem_rw, mem_addr, mem_rdata, mem_wdata
	);
	
	
	
	seg_uint8 seg_pc (1'b1, if_addr[7:0], HEX1, HEX0);
	seg_uint8 seg_mem (1'b1, seg2, HEX3, HEX2);
	seg_uint8 seg_memd (1'b1, seg, HEX5, HEX4);

endmodule
