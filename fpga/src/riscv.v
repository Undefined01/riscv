`include "common.v"

module riscv(
	input  wire CLOCK_50
);

	wire clk = CLOCK_50;
	wire reset = 1'b0;
	
	wire [31:0] ram_if_addr, ram_if_data;
	
	reg [31:0] ram[128*1024-1:0];
	assign ram_if_data = ram[ram_if_addr[31:2]];
	
	riscv_core core(
		clk, reset, ram_if_addr, ram_if_data
	);

endmodule
