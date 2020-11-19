`include "../common.v"

module ex(
	// from id
	input  wire	[`RTLOP_BUS]	rtlop,
	input  wire	[`RTLTYPE_BUS]	rtltype,
	input  wire	[`DATA_BUS]		pc,
	input  wire	[`DATA_BUS]		src1,
	input  wire	[`DATA_BUS]		src2,
	input  wire	[`REG_BUS]		gprs_waddr_i,
	
	// asynchronously to EX_MEM and ID
	output reg					mem_rw_o,
	output reg	[`DATA_BUS]		mem_addr_o,
	output reg	[`DATA_BUS]		mem_data_o,
	output reg	[`REG_BUS]		gprs_waddr_o,
	output reg	[`DATA_BUS]		gprs_wdata_o,
	
	// asynchronously to cpu_ctrl
	output wire					stall,
	output wire					jump_flag,
	output wire	[`DATA_BUS]		jump_addr
);

	wire [`DATA_BUS] res_add = src1 + src2;
	wire [`DATA_BUS] res_shl = src1 << src2;
	wire [`DATA_BUS] res_slt = $signed(src1) < $signed(src2);
	wire [`DATA_BUS] res_sltu = src1 < src2;
	wire [`DATA_BUS] res_xor = src1 ^ src2;
	wire [`DATA_BUS] res_shr = src1 >> src2;
	wire [`DATA_BUS] res_sar = $signed(src1) >> $signed(src2);
	wire [`DATA_BUS] res_or  = src1 | src2;
	wire [`DATA_BUS] res_and = src1 & src2;

	reg [`DATA_BUS] res;
	
	assign stall = 1'b0;
	assign jump_flag = 1'b0;
	assign jump_addr = `DATA_ZERO;

	always @(*) begin
		case (rtlop)
			`RTLOP_ADD:	res = res_add;
			`RTLOP_SHL:	res = res_shl;
			`RTLOP_SLT:	res = res_slt;
			`RTLOP_SLTU:res = res_sltu;
			`RTLOP_XOR:	res = res_xor;
			`RTLOP_SHR:	res = res_shr;
			`RTLOP_SAR:	res = res_sar;
			`RTLOP_OR:	res = res_or;
			`RTLOP_AND:	res = res_and;
			default:	res = `DATA_ZERO;
		endcase
	end
	
	always @(*) begin
		mem_rw_o = `MEM_READ;
		mem_addr_o = `DATA_ZERO;
		mem_data_o = `DATA_ZERO;
		gprs_waddr_o = `REG_X0;
		gprs_wdata_o = res;
		
		case (rtltype)
			`RTLTYPE_ARICH: begin
				gprs_waddr_o <= gprs_waddr_i;
			end
			default: begin
				gprs_waddr_o <= `REG_X0;
			end
		endcase
	end

endmodule
