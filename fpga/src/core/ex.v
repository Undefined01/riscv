`include "../common.v"

module ex(
	// from id
	input  wire	[`RTLOP_BUS]	rtlop,
	input  wire	[`RTLTYPE_BUS]	rtltype,
	input  wire	[`DATA_BUS]		pc,
	input  wire	[`DATA_BUS]		src1,
	input  wire	[`DATA_BUS]		src2,
	input  wire	[`REG_BUS]		gprs_waddr_i,
	
	// asynchronously to EX_MEM_WB
	output reg					mem_ena_o,
	output reg					mem_rw_o,
	output reg	[`DATA_BUS]		mem_addr_o,
	output reg	[`DATA_BUS]		mem_data_o,
	output reg	[`REG_BUS]		gprs_waddr_o,
	output reg	[`DATA_BUS]		gprs_wdata_o,
	
	output reg					jump_flag,
	output reg	[`DATA_BUS]		jump_addr
);

	wire [`DATA_BUS] res_add = src1 + src2;
	wire [`DATA_BUS] res_shl = src1 << src2;
	wire [`DATA_BUS] res_slt = $signed(src1) < $signed(src2);
	wire [`DATA_BUS] res_sltu = src1 < src2;
	wire [`DATA_BUS] res_xor = src1 ^ src2;
	wire [`DATA_BUS] res_shr = src1 >> src2;
	wire [`DATA_BUS] res_sar = $signed(src1) >> src2;
	wire [`DATA_BUS] res_or  = src1 | src2;
	wire [`DATA_BUS] res_and = src1 & src2;

	reg [`DATA_BUS] res;
	

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
		mem_ena_o = `DISABLE;
		mem_rw_o = `MEM_READ;
		mem_addr_o = `DATA_ZERO;
		mem_data_o = `DATA_ZERO;
		gprs_waddr_o = `REG_X0;
		gprs_wdata_o = res;
		jump_flag = `DISABLE;
		jump_addr = `DATA_ZERO;
		
		case (rtltype)
			`RTLTYPE_ARICH: begin
				gprs_waddr_o = gprs_waddr_i;
			end
			
			`RTLTYPE_RMEM: begin
				gprs_waddr_o = gprs_waddr_i;
				mem_ena_o	 = `ENABLE;
				mem_rw_o	 = `MEM_READ;
				mem_addr_o	 = res;
			end
			
			`RTLTYPE_WMEM: begin
				mem_ena_o	= `ENABLE;
				mem_rw_o	= `MEM_WRITE;
				mem_addr_o	= src1;
				mem_data_o	= src2;
			end
			
			`RTLTYPE_JUMP: begin
				jump_flag = `ENABLE;
				jump_addr = res;
				// 写回到寄存器中的地址为jump下一条指令
				gprs_waddr_o = gprs_waddr_i;
				gprs_wdata_o = src1 + 4;
			end
			
			default: begin
				gprs_waddr_o <= `REG_X0;
			end
		endcase
	end

endmodule
