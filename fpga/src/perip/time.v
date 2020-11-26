`include "../common.v"

module perip_time(
	input  wire				clk,
	input  wire				rst,
	input  wire				ena,
	input  wire				rw,
	input  wire	[`DATA_BUS]	addr,
	output reg	[`DATA_BUS]	rdata,
	input  wire	[`DATA_BUS]	wdata
);
	
	wire clk_1us;
	wire carry;
	wire [63:0] time_us;
	
	always @(posedge clk)
		if (ena) begin
			if (addr == 0)
				rdata <= time_us[31:0];
			else
				rdata <= time_us[63:32];
		end
	
	clk_div #(50) clk1us(clk, 1'b1, rst, clk_1us);
	
	counter #(64'hffffffffffffffff) time_cnt(
		.clk(clk_1us),
		.reset(rst),
		.ena(1'b1),
		.num(time_us),
		.carry(carry)
	);

endmodule
