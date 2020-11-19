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

	integer i;
	always @(posedge clk)
		if (rst) begin
			for (i=0; i<`REG_COUNT; i=i+1)
				regs[i] <= `DATA_ZERO;
		end
		else if (wena && waddr != `REG_X0)
			regs[waddr] <= wdata;
	
	always @(*) begin
		rdata1 = regs[raddr1];
		rdata2 = regs[raddr2];
	end

endmodule
