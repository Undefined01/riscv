`include "../common.v"

module id(
	input  wire	clk,
	input  wire	rst,
	input  wire stall,
	input  wire	flush,
	input  wire	valid_i,
	input  wire	[`DATA_BUS]	instr_i,
	input  wire [`DATA_BUS] pc_i,
	
	// from gprs
	input  wire	[`DATA_BUS]	gprs_rdata1_i,
	input  wire	[`DATA_BUS]	gprs_rdata2_i,
	
	// to gprs，需要使用的寄存器值
	output reg	[`REG_BUS]	gprs_raddr1,
	output reg	[`REG_BUS]	gprs_raddr2,
	
	// to EX
	output reg  valid_o,
	output reg	[`RTLOP_BUS]	rtl_op,
	output reg	[`RTLTYPE_BUS]	rtl_type,
	output reg	[`DATA_BUS]	pc_o,
	output reg	[`DATA_BUS]	data1_o,
	output reg	[`DATA_BUS]	data2_o,
	output reg	[`REG_BUS]	gprs_waddr_o,
	
	output reg	error
);

	wire [6:0] opcode = instr_i[6:0];
	wire [2:0] funct3 = instr_i[14:12];
	wire [6:0] funct7 = instr_i[31:25];
	wire [4:0] rd = instr_i[11:7];
	wire [4:0] rs1 = instr_i[19:15];
	wire [4:0] rs2 = instr_i[24:20];
	
	wire [`DATA_BUS] I_imm = {{20{instr_i[31]}}, instr_i[31:20]};
	

	reg	[`RTLOP_BUS]	tmp_rtl_op;
	reg	[`RTLTYPE_BUS]	tmp_rtl_type;
	reg	[`DATA_BUS]	tmp_data1_o;
	reg	[`DATA_BUS]	tmp_data2_o;
	reg	[`REG_BUS]	tmp_gprs_waddr_o;
	
	reg	tmp_error;
	
	always @(*) begin
		tmp_error = 1'b0;
		tmp_rtl_op = `RTLOP_ADD;
		tmp_rtl_type = `RTLTYPE_CALC;
		gprs_raddr1 = `REG_X0;
		gprs_raddr2 = `REG_X0;
		tmp_data1_o = gprs_rdata1_i;
		tmp_data2_o = gprs_rdata2_i;
		tmp_gprs_waddr_o = `REG_X0;
		
		if (valid_i)
			case (opcode)
				`INSTRGROUP_I: begin
					gprs_raddr1 = rs1;
					tmp_data2_o = I_imm;
					tmp_gprs_waddr_o = rd;
					
					tmp_rtl_type = `RTLTYPE_CALC;
					case (funct3)
						`FUNCT3_SR: begin
							if (funct7 == `FUNCT7_SHR)
								tmp_rtl_op = `RTLOP_SHR;
							else if (funct7 == `FUNCT7_SAR)
								tmp_rtl_op = `RTLOP_SAR;
							else
								tmp_error = 1'b1;
						end
						default: begin
							tmp_rtl_op = {1'b0, funct3};
						end
					endcase
				end
				`INSTRGROUP_R: begin
					gprs_raddr1 = rs1;
					gprs_raddr2 = rs2;
					tmp_gprs_waddr_o = rd;
					
					tmp_rtl_type = `RTLTYPE_CALC;
					case (funct3)
						`FUNCT3_ADD: begin
							if (funct7 == `FUNCT7_ADD)
								tmp_data1_o = tmp_data1_o;
							else if (funct7 == `FUNCT7_SUB)
								tmp_data1_o = ~tmp_data1_o + 1'b1;
							else
								tmp_error = 1'b1;
						end
						`FUNCT3_SR: begin
							if (funct7 == `FUNCT7_SHR)
								tmp_rtl_op = `RTLOP_SHR;
							else if (funct7 == `FUNCT7_SAR)
								tmp_rtl_op = `RTLOP_SAR;
							else
								tmp_error = 1'b1;
						end
						default: begin
							if (funct7 != `FUNCT7_ZERO)
								tmp_error = 1'b1;
							tmp_rtl_op = {1'b0, funct3};
						end
					endcase
				end
				default: begin
					tmp_error = 1'b1;
				end
			endcase
	end
	
	always @(posedge clk) begin
		if (rst || flush)
			valid_o <= 1'b0;
		else if (~stall) begin
			valid_o <= valid_i;
			pc_o <= pc_i;
			rtl_op <= tmp_rtl_op;
			rtl_type <= tmp_rtl_type;
			data1_o <= tmp_data1_o;
			data2_o <= tmp_data2_o;
			gprs_waddr_o <= tmp_gprs_waddr_o;
			error <= tmp_error;
		end
	end
	
endmodule
