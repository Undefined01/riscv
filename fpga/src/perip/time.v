`include "../common.v"

module perip_time(
	input  wire				clk,
	input  wire				rst,
	input  wire				ena,
	input  wire				rw,
	input  wire	[`DATA_BUS]	addr,
	output wire	[`DATA_BUS]	rdata,
	input  wire	[`DATA_BUS]	wdata
);
	
	wire clk_1us;
	wire carry;
	wire [63:0] time_us;
	
	assign rdata = addr == 0 ? time_us[31:0] : time_us[63:32];
	
	clk_div #(50) clk1us(clk, 1'b1, rst, clk_1us);
	
	counter #(64'hffffffffffffffff) time_cnt(
		.clk(clk_1us),
		.reset(rst),
		.ena(1'b1),
		.num(time_us),
		.carry(carry)
	);

endmodule
