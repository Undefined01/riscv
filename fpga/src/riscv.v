`include "common.v"

module riscv(
	input  wire	CLOCK_50,
	input  wire	[3:0] KEY,
	
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
	output wire	VGA_BLANK_N
);

	wire clk = CLOCK_50;
	wire rst = ~KEY[0];
	
	
	wire mem_rw;
	wire [`DATA_BUS] mem_addr, mem_wdata;
	reg  [`DATA_BUS] mem_rdata;
	
	reg  ram_ena, term_ena;

	wire ram_mem_rw = mem_rw;
	wire [`DATA_BUS] ram_if_addr;
	wire [`DATA_BUS] ram_mem_addr = mem_addr;
	wire [`DATA_BUS] ram_mem_wdata = mem_wdata;
	reg  [`DATA_BUS] ram_if_data, ram_mem_rdata;

	wire term_wena;
	wire [`DATA_BUS] term_waddr = mem_addr - 32'ha0000000;
	wire [`DATA_BUS] term_wdata = mem_wdata;
	
	always @(*) begin
		ram_ena		= `DISABLE;
		term_ena	= `DISABLE;
		mem_rdata	= `DATA_ZERO;
		
		if (32'ha0000000 <= mem_addr && mem_addr < 32'ha1000000) begin
			term_ena = `ENABLE;
			mem_rdata = `DATA_ZERO;
		end
		if (32'h00000000 <= mem_addr && mem_addr < 32'h10000000) begin
			ram_ena = `ENABLE;
			mem_rdata = ram_mem_rdata;
		end
	end
	
	reg [`DATA_BUS] ram[4*1024-1:0];
	initial $readmemh("E:/test/riscv/fpga/testbench/build/test_perip.hex", ram);
	
	always @(posedge clk) begin
		ram_if_data <= ram[ram_if_addr[31:2]];
		if (ram_ena) begin
			if (ram_mem_rw == `MEM_READ)
				ram_mem_rdata <= ram[ram_mem_addr[31:2]];
			else
				ram[ram_mem_addr[31:2]] <= ram_mem_wdata;
		end
	end
	riscv_core core(
		~KEY[3], rst,
		ram_if_addr, ram_if_data,
		mem_rw, mem_addr, mem_rdata, mem_wdata
	);
	
	
	(* ram_init_file = "vga_term/null_term.mif" *) reg [7:0] term[70*30-1:0];
	
	wire [11:0] charidx;
	reg [7:0] char;
	always @(posedge CLOCK_50) begin
		char <= term[charidx];
		if (term_ena)
			term[term_waddr] <= term_wdata[7:0];
	end
	
	clk_div #(2) clk_div_25M (CLOCK_50, 1'b1, rst, VGA_CLK);
	vga_term vga_term (
		.clk_50M(CLOCK_50),
		.clk_25M(VGA_CLK),
		.rst(rst),
		.charidx(charidx),
		.char(char),
		.sync_n(VGA_SYNC_N),
		.hsync(VGA_HS),
		.vsync(VGA_VS),
		.valid(VGA_BLANK_N),
		.vga_r(VGA_R),
		.vga_g(VGA_G),
		.vga_b(VGA_B)
	);
	
	seg_uint8 seg_pc (1'b1, ram_if_addr[7:0], HEX1, HEX0);
	seg_uint8 seg_mem (1'b1, term_waddr[7:0], HEX3, HEX2);
	seg_uint8 seg_memd (1'b1, term_wdata[7:0], HEX5, HEX4);
	assign LEDR[0] = term_ena;

endmodule
