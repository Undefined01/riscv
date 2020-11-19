`include "../common.v"

module ex_mem(
	input  wire	clk,
	input  wire	rst,
	input  wire stall,
	input  wire	flush,
	
	// from EX
	input  wire					ex_valid,
	input  wire					ex_mem_rw_o,
	input  wire	[`DATA_BUS]		ex_mem_addr_o,
	input  wire	[`DATA_BUS]		ex_mem_data_o,
	input  wire	[`REG_BUS]		ex_gprs_waddr_o,
	
	// to MEM
	output reg					mem_valid_i,
	output reg					mem_mem_rw_i,
	output reg	[`DATA_BUS]		mem_mem_addr_i,
	output reg	[`DATA_BUS]		mem_mem_data_i,
	output reg	[`REG_BUS]		mem_gprs_waddr_i
);

	always @(posedge clk)
		if (rst || flush) begin
			mem_valid <= 1'b0;
		end
		else if (id_valid_o && !stall) begin
			mem_valid		<= ex_valid;
			mem_mem_rw_i	<= ex_mem_rw_o;
			mem_mem_addr_i	<= ex_mem_addr_o;
			mem_mem_data_i	<= ex_mem_data_o;
			mem_gprs_waddr_i<= ex_gprs_waddr_o;
		end

endmodule
