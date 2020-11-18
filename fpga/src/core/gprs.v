`include "../common.v"

// 通用寄存器组。
// 异步读，同步写。
module gprs(
	input  wire	clk,
	input  wire	rst,
	input  wire	wena,
	input  wire	[`REG_BUS]	waddr,
	input  wire	[`DATA_BUS]	wdata,
	input  wire	[`REG_BUS]	raddr1,
	input  wire	[`REG_BUS]	raddr2,
	output reg	[`DATA_BUS]	rdata1,
	output reg	[`DATA_BUS]	rdata2
);

	reg [`DATA_BUS] regs[`REG_COUNT - 1 : 0];

	always @(posedge clk)
		if (rst)
			regs[0] <= `DATA_ZERO;
		else if (wena && waddr != `REG_X0)
			regs[waddr] <= wdata;
	
	always @(*) begin
		rdata1 = regs[raddr1];
		rdata2 = regs[raddr2];
	end

endmodule
