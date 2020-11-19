`include "../common.v"

module id(
	// from IF
	input  wire	[`DATA_BUS]	instr_i,
	input  wire [`DATA_BUS] pc_i,
	
	// asynchronously from gprs
	input  wire	[`DATA_BUS]	gprs_rdata1_i,
	input  wire	[`DATA_BUS]	gprs_rdata2_i,
	
	// asynchronously to gprs
	output reg	[`REG_BUS]	gprs_raddr1,
	output reg	[`REG_BUS]	gprs_raddr2,
	
	// asynchronously to ID_EX
	output reg	[`RTLOP_BUS]	rtlop_o,
	output reg	[`RTLTYPE_BUS]	rtltype_o,
	output reg	[`DATA_BUS]		pc_o,
	output reg	[`DATA_BUS]		src1_o,
	output reg	[`DATA_BUS]		src2_o,
	output reg	[`REG_BUS]		gprs_waddr_o,
	
	// asynchronously to cpu_ctrl
	output reg	error_o
);

	wire [6:0] opcode = instr_i[6:0];
	wire [2:0] funct3 = instr_i[14:12];
	wire [6:0] funct7 = instr_i[31:25];
	wire [4:0] rd  = instr_i[11:7];
	wire [4:0] rs1 = instr_i[19:15];
	wire [4:0] rs2 = instr_i[24:20];
	
	wire [`DATA_BUS] I_imm = {{20{instr_i[31]}}, instr_i[31:20]};
	
	
	
	always @(*) begin
		error_o		= 1'b0;
		rtlop_o		= `RTLOP_ADD;
		rtltype_o	= `RTLTYPE_ARICH;
		pc_o		= pc_i;
		src1_o		= gprs_rdata1_i;
		src2_o		= gprs_rdata2_i;
		gprs_raddr1  = rs1;
		gprs_raddr2  = rs2;
		gprs_waddr_o = `REG_X0;
		
		case (opcode)
			// 寄存器与立即数的算术运算
			`INSTRGROUP_I: begin
				src1_o = gprs_rdata1_i;
				src2_o = I_imm;
				gprs_waddr_o = rd;
				
				rtltype_o = `RTLTYPE_ARICH;
				rtlop_o = {1'b0, funct3};
				case (funct3)
					`FUNCT3_SR: case (funct7)
						`FUNCT7_SHR:	rtlop_o = `RTLOP_SHR;
						`FUNCT7_SAR:	rtlop_o = `RTLOP_SAR;
						default:		error_o = 1'b1;
					endcase
					default:	rtlop_o = {1'b0, funct3};
				endcase
			end
			
			// 寄存器与寄存器的算术运算
			`INSTRGROUP_R: begin
				src1_o = gprs_rdata1_i;
				src2_o = I_imm;
				gprs_waddr_o = rd;
				
				rtltype_o = `RTLTYPE_ARICH;
				rtlop_o = {1'b0, funct3};
				case (funct3)
					`FUNCT3_ADD: case (funct7)
						`FUNCT7_ADD:	src2_o = src1_o;
						`FUNCT7_SUB:	src2_o = ~src2_o + 1'b1;
						default:		error_o = 1'b1;
					endcase
					`FUNCT3_SR: case (funct7)
						`FUNCT7_SHR:	rtlop_o = `RTLOP_SHR;
						`FUNCT7_SAR:	rtlop_o = `RTLOP_SAR;
						default:		error_o = 1'b1;
					endcase
					default: case (funct7)
						`FUNCT7_ZERO:	rtlop_o = {1'b0, funct3};
						default:		error_o = 1'b1;
					endcase
				endcase
			end
			
			default: begin
				error_o = 1'b1;
			end
		endcase
	end
	
endmodule
