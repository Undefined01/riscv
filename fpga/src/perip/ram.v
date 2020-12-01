`include "../common.v"

module ram(
	input  wire				clk,
	input  wire	[`DATA_BUS]	if_addr,
	output reg	[`DATA_BUS]	if_data,
	input  wire				mem_ena,
	input  wire				mem_rw,
	input  wire	[`DATA_BUS]	mem_addr,
	output reg	[`DATA_BUS]	mem_rdata,
	input  wire	[`DATA_BUS]	mem_wdata
);
	
	reg [`DATA_BUS] ram[`RAM_SIZE-1:0];
	initial $readmemh("../testbench/build/firmware.hex", ram);
	
	always @(posedge clk) begin
		if (mem_ena) begin
			if (mem_rw == `MEM_READ)
				mem_rdata <= ram[mem_addr[31:2]];
			else
				ram[mem_addr[31:2]] <= mem_wdata;
		end
		if_data <= ram[if_addr[31:2]];
	end

endmodule
