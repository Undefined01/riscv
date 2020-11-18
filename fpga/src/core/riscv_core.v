`include "../common.v"

module riscv_core(
	input  wire	clk,
	input  wire	rst,
	output wire	[`DATA_BUS] mem_if_addr,
	input  wire	[`DATA_BUS] mem_if_data
);

	// CPU 全局状态
	
	// 执行跳转，同时应该刷新流水线
	wire				jump_flag;
	wire [`DATA_BUS]	jump_addr;
	
	// 流水线控制
	wire stall, flush;
	assign flush = jump_flag;
	
	wire				ex_gprs_wena;
	wire [`REG_BUS]		ex_gprs_waddr;
	wire [`DATA_BUS]	ex_gprs_wdata;
	wire [`REG_BUS]  gprs_raddr1, gprs_raddr2;
	wire [`DATA_BUS] gprs_rdata1, gprs_rdata2;
	
	gprs gprs (
		.clk(clk),
		.rst(rst),
		.wena(ex_gprs_wena),
		.waddr(ex_gprs_waddr),
		.wdata(ex_gprs_wdata),
		.raddr1(gprs_raddr1),
		.raddr2(gprs_raddr2),
		.rdata1(gprs_rdata1),
		.rdata2(gprs_rdata2)
	);
	
	
	// IF阶段
	
	reg  [`DATA_BUS] pc, if_pc;
	wire [`DATA_BUS] pc_predict;
	
	reg  if_valid;
	reg  [`DATA_BUS] if_instr;
	
	always @(posedge clk)
		if (rst)
			pc <= `CPU_RESET_ADDR;
		else if (stall)
			pc <= pc;
		else if (jump_flag) 
			pc <= jump_addr;
		else 
			pc <= pc_predict;

	// 期望在上升沿前获取到下一条指令
	assign mem_if_addr = pc;
	always @(posedge clk)
		if (rst)
			if_valid <= 1'b0;
		else begin
			if_valid <= 1'b1;
			if_pc <= pc;
			if_instr <= mem_if_data;
		end
	
	
	// ID 阶段
	
	wire 				id_valid;
	wire [`DATA_BUS]	id_pc;
	wire [`DATA_BUS]	id_src1, id_src2;
	wire [`REG_BUS]		id_gprs_waddr;
	wire [`RTLOP_BUS]	id_rtl_op;
	wire [`RTLTYPE_BUS]	id_rtl_type;
	wire				id_error;
	
	id id(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.flush(flush),
		.valid_i(if_valid),
		.instr_i(if_instr),
		.pc_i(if_pc),
		.gprs_rdata1_i(gprs_rdata1),
		.gprs_rdata2_i(gprs_rdata2),
		.gprs_raddr1(gprs_raddr1),
		.gprs_raddr2(gprs_raddr2),
		
		.valid_o(id_valid),
		.rtl_op(id_rtl_op),
		.rtl_type(id_rtl_type),
		.pc_o(id_pc),
		.data1_o(id_src1),
		.data2_o(id_src2),
		.gprs_waddr_o(id_gprs_waddr),
		
		.error(id_error)
	);
	
	// 进行分支预测。此处总是预测不跳转（顺序执行）
	assign pc_predict = pc + 4;
	
	
	// EX 阶段
	
	wire 				ex_mem_wena;
	wire [`DATA_BUS]	ex_mem_waddr;
	wire [`DATA_BUS]	ex_mem_wdata;
	
	ex ex(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.valid_i(id_valid),
		.rtl_op(id_rtl_op),
		.rtl_type(id_rtl_type),
		.pc(id_pc),
		.src1(id_src1),
		.src2(id_src2),
		.gprs_waddr_i(id_gprs_waddr),
		
		.mem_wena(ex_mem_wena),
		.mem_waddr(ex_mem_waddr),
		.mem_wdata(ex_mem_wdata),
		
		.gprs_wena_o(ex_gprs_wena),
		.gprs_waddr_o(ex_gprs_waddr),
		.gprs_wdata_o(ex_gprs_wdata),
		
		.jump(jump_flag),
		.jump_addr(jump_addr)
	);
	

endmodule
