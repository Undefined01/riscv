`include "../common.v"

module term(
	input  wire				clk,
	input  wire				rst,
	input  wire				ena,
	input  wire				rw,
	input  wire	[`DATA_BUS]	addr,
	output wire	[`DATA_BUS]	rdata,
	input  wire	[`DATA_BUS]	wdata,
	
	// VGA
	output wire	[7:0] VGA_R,
	output wire	[7:0] VGA_G,
	output wire	[7:0] VGA_B,
	output wire	VGA_CLK,
	output wire	VGA_HS,
	output wire	VGA_VS,
	output wire	VGA_SYNC_N,
	output wire	VGA_BLANK_N
);
	
	(* ram_init_file = "vga_term/null_term.mif" *) reg [7:0] term[70*30-1:0];
	
	
	assign rdata = `DATA_ZERO;
	always @(posedge clk) begin
		if (ena && rw == `MEM_WRITE)
			term[addr] <= wdata[7:0];
	end
	
	
	wire [11:0] charidx;
	reg [7:0] char;
	always @(posedge clk)
		char <= term[charidx];
	
	
	clk_div #(2) clk_div_25M (clk, 1'b1, rst, VGA_CLK);
	vga_term vga_term (
		.clk_50M(clk),
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

endmodule
