`include "../common.v"

module perip(
	input  wire				clk,
	input  wire				rst,
	input  wire	[`DATA_BUS]	if_addr,
	output wire	[`DATA_BUS]	if_data,
	input  wire				mem_rw,
	input  wire	[`DATA_BUS]	mem_addr,
	output reg	[`DATA_BUS]	mem_rdata,
	input  wire	[`DATA_BUS]	mem_wdata,
	
	// VGA
	output wire	[7:0] VGA_R,
	output wire	[7:0] VGA_G,
	output wire	[7:0] VGA_B,
	output wire	VGA_CLK,
	output wire	VGA_HS,
	output wire	VGA_VS,
	output wire	VGA_SYNC_N,
	output wire	VGA_BLANK_N,
	
	// KBD
	inout  wire	PS2_CLK,
	inout  wire	PS2_DAT
);


	reg  ram_ena, term_ena, kbd_ena, time_ena;
	wire [`DATA_BUS] ram_addr = mem_addr - `RAM_ADDR_L;
	wire [`DATA_BUS] ram_rdata;
	wire [`DATA_BUS] term_addr = mem_addr - `TERM_ADDR_L;
	wire [`DATA_BUS] term_rdata;
	wire [`DATA_BUS] kbd_addr = mem_addr - `KBD_ADDR_L;
	wire [`DATA_BUS] kbd_rdata;
	wire [`DATA_BUS] time_addr = mem_addr - `TIME_ADDR_L;
	wire [`DATA_BUS] time_rdata;


	always @(*) begin
		ram_ena		= `DISABLE;
		term_ena	= `DISABLE;
		kbd_ena		= `DISABLE;
		time_ena	= `DISABLE;
		mem_rdata	= `DATA_ZERO;
		
		if (ram_addr < `RAM_ADDR_R - `RAM_ADDR_L) begin
			ram_ena		= `ENABLE;
			mem_rdata	= ram_rdata;
		end
		
		if (term_addr < `TERM_ADDR_R - `TERM_ADDR_L) begin
			term_ena	= `ENABLE;
			mem_rdata	= term_rdata;
		end
		
		if (kbd_addr < `KBD_ADDR_R - `KBD_ADDR_L) begin
			kbd_ena		= `ENABLE;
			mem_rdata	= kbd_rdata;
		end
		
		if (time_addr < `TIME_ADDR_R - `TIME_ADDR_L) begin
			time_ena	= `ENABLE;
			mem_rdata	= time_rdata;
		end
	end
	
	ram ram(
		.clk(clk),
		.if_addr(if_addr),
		.if_data(if_data),
		.mem_ena(ram_ena),
		.mem_rw(mem_rw),
		.mem_addr(ram_addr),
		.mem_rdata(ram_rdata),
		.mem_wdata(mem_wdata)
	);
	
	term term(
		.clk(clk),
		.rst(rst),
		.ena(term_ena),
		.rw(mem_rw),
		.addr(term_addr),
		.rdata(term_rdata),
		.wdata(mem_wdata),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_CLK(VGA_CLK),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_BLANK_N(VGA_BLANK_N)
	);
	
	kbd kbd(
		.clk(clk),
		.rst(rst),
		.ena(kbd_ena),
		.rw(mem_rw),
		.addr(kbd_addr),
		.rdata(kbd_rdata),
		.wdata(mem_wdata),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT)
	);
	
	perip_time perip_time(
		.clk(clk),
		.rst(rst),
		.ena(time_ena),
		.rw(mem_rw),
		.addr(time_addr),
		.rdata(time_rdata),
		.wdata(mem_wdata)
	);

endmodule
