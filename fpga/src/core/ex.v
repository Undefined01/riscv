`include "../common.v"

module ex(
	input  wire clk,
	input  wire rst,
	output wire stall,
	
	// from id
	input  wire					valid_i,
	input  wire	[`RTLOP_BUS]	rtl_op,
	input  wire	[`RTLTYPE_BUS]	rtl_type,
	input  wire	[`DATA_BUS]		pc,
	input  wire	[`DATA_BUS]		src1,
	input  wire	[`DATA_BUS]		src2,
	input  wire	[`REG_BUS]		gprs_waddr_i,
	
	// to mem
	output reg					mem_wena,
	output reg	[`DATA_BUS]		mem_waddr,
	output reg	[`DATA_BUS]		mem_wdata,
	
	// to gprs
	output reg					gprs_wena_o,
	output reg	[`REG_BUS]		gprs_waddr_o,
	output reg	[`DATA_BUS]		gprs_wdata_o,
	
	// to cpu ctrl
	output reg					jump,
	output reg	[`DATA_BUS]		jump_addr
);

	assign stall = 1'b0;

	wire [`DATA_BUS] res_add = src1 + src2;

	reg [`DATA_BUS] res;
	
	always @(*) begin
		case (rtl_op)
			`RTLOP_ADD: res = res_add;
			default:	res = `DATA_ZERO;
		endcase
	end
	
	always @(posedge clk) begin
		gprs_wena_o <= 1'b0;
		gprs_waddr_o <= gprs_waddr_i;
		gprs_wdata_o <= res;
		
		mem_wena <= 1'b0;
		mem_waddr <= res;
		mem_wdata <= src1;
		
		jump <= 1'b0;
		jump_addr <= res;
		
		if (valid_i)
			case (rtl_type)
				`RTLTYPE_CALC: begin
					gprs_wena_o <= 1'b1;
				end
			endcase
	end

endmodule
