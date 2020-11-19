`include "../common.v"

module id_ex(
	input  wire	clk,
	input  wire	rst,
	input  wire stall,
	input  wire	flush,
	
	// from ID
	input  wire					id_valid,
	input  wire [`RTLOP_BUS]	id_rtlop_o,
	input  wire [`RTLTYPE_BUS]	id_rtltype_o,
	input  wire [`DATA_BUS]		id_pc_o,
	input  wire [`DATA_BUS]		id_src1_o,
	input  wire [`DATA_BUS]		id_src2_o,
	input  wire [`REG_BUS]		id_gprs_waddr_o,
	
	// to EX
	output reg					ex_valid,
	output reg	[`RTLOP_BUS]	ex_rtlop_i,
	output reg	[`RTLTYPE_BUS]	ex_rtltype_i,
	output reg	[`DATA_BUS]		ex_pc_i,
	output reg	[`DATA_BUS]		ex_src1_i,
	output reg	[`DATA_BUS]		ex_src2_i,
	output reg	[`REG_BUS]		ex_gprs_waddr_i
);

	always @(posedge clk)
		if (rst || flush) begin
			ex_valid <= 1'b0;
		end
		else if (id_valid && !stall) begin
			ex_valid		<= id_valid;
			ex_rtlop_i		<= id_rtlop_o;
			ex_rtltype_i	<= id_rtltype_o;
			ex_pc_i			<= id_pc_o;
			ex_src1_i		<= id_src1_o;
			ex_src2_i		<= id_src2_o;
			ex_gprs_waddr_i	<= id_gprs_waddr_o;
		end
	
endmodule
