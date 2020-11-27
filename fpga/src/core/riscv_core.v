`include "../common.v"

module riscv_core(
	input  wire	clk,
	input  wire	rst,
	output wire	[`DATA_BUS]	mem_if_addr,
	input  wire	[`DATA_BUS]	mem_if_data,
	output wire 			mem_mem_rw,		// MEM访存阶段对内存的操作。0读取；1写入。
	output wire [`DATA_BUS]	mem_mem_addr,
	input  wire [`DATA_BUS] mem_mem_rdata,
	output wire [`DATA_BUS] mem_mem_wdata
);

	// CPU 全局状态
	
	// 执行跳转，同时应该刷新流水线
	wire				jump_flag;
	wire [`DATA_BUS]	jump_addr;
	
	// 流水线控制
	wire stall;	// ID阶段需要MEM阶段读入的数据，发生RAW冲突，需要暂停一个周期
	wire flush;	// 分支预测错误，需要清空流水线
	
	// 目前的预测函数对任意跳转都会预测错误
	assign flush = jump_flag;
	
	
	// 读取
	wire [`REG_BUS]  id_gprs_raddr1, id_gprs_raddr2;
	wire [`DATA_BUS] id_gprs_rdata1, id_gprs_rdata2;
	// 转发
	wire [`REG_BUS]		ex_gprs_waddr;
	wire [`DATA_BUS]	ex_gprs_wdata;
	// 写回
	wire [`REG_BUS]		wb_gprs_waddr;
	wire [`DATA_BUS]	wb_gprs_wdata;
	wire				wb_gprs_wena = wb_gprs_waddr != `REG_X0;
	
	gprs gprs (
		.clk(clk),
		.rst(rst),
		.wena(wb_gprs_wena),
		.waddr(wb_gprs_waddr),
		.wdata(wb_gprs_wdata),
		.raddr1(id_gprs_raddr1),
		.raddr2(id_gprs_raddr2),
		.rdata1(id_gprs_rdata1),
		.rdata2(id_gprs_rdata2)
	);
	
	
	// IF阶段
	
	reg  [`DATA_BUS] pc, next_pc;
	wire [`DATA_BUS] pc_predict;
	
	reg  if_valid;
	reg  [`DATA_BUS] if_pc;
	wire [`DATA_BUS] if_instr = mem_if_data;
	
	// 进行分支预测。此处总是预测不跳转（顺序执行）
	assign pc_predict = pc + 4;
	
	always @(*)
		if (rst)
			next_pc = `CPU_RESET_ADDR;
		else if (stall)
			next_pc = pc;
		else if (jump_flag) 
			next_pc = jump_addr + 4;
		else 
			next_pc = pc_predict;
			
	always @(posedge clk)
		pc <= next_pc;

	// 期望在上升沿前获取到下一条指令
	assign mem_if_addr = flush ? jump_addr : stall ? if_pc : pc;
	always @(posedge clk)
		if (rst)
			if_valid <= 1'b0;
		else if (!stall) begin
			if_valid <= 1'b1;
			if_pc <= mem_if_addr;
		end
	
	
	// ID 阶段
	
	wire 				id_valid = if_valid;
	wire [`DATA_BUS]	id_instr_i = if_instr;
	wire [`DATA_BUS]	id_pc_i = if_pc;
	
	wire [`DATA_BUS]	id_pc_o;
	wire [`DATA_BUS]	id_src1_o, id_src2_o;
	wire [`REG_BUS]		id_gprs_waddr_o;
	wire [`RTLOP_BUS]	id_rtlop_o;
	wire [`RTLTYPE_BUS]	id_rtltype_o;
	wire				id_error_o;
	
	// ID模块所有输入输出均为异步
	id id(
		// from IF
		.instr_i(id_instr_i),
		.pc_i(id_pc_i),
		
		// from gprs
		.gprs_rdata1_i(id_gprs_rdata1),
		.gprs_rdata2_i(id_gprs_rdata2),
		// to gprs
		.gprs_raddr1(id_gprs_raddr1),
		.gprs_raddr2(id_gprs_raddr2),
		
		// 转发 from EX
		.ex_gprs_waddr(wb_gprs_waddr),
		.ex_gprs_wdata(wb_gprs_wdata),
		
		// to ID_EX
		.rtlop_o(id_rtlop_o),
		.rtltype_o(id_rtltype_o),
		.pc_o(id_pc_o),
		.src1_o(id_src1_o),
		.src2_o(id_src2_o),
		.gprs_waddr_o(id_gprs_waddr_o),
		
		// to cpu_ctrl
		.error_o(id_error_o)
	);
	
	
	// ID -> EX
	
	wire 				ex_valid;
	wire [`RTLOP_BUS]	ex_rtlop_i;
	wire [`RTLTYPE_BUS]	ex_rtltype_i;
	wire [`DATA_BUS]	ex_pc_i;
	wire [`DATA_BUS]	ex_src1_i;
	wire [`DATA_BUS]	ex_src2_i;
	wire [`REG_BUS]		ex_gprs_waddr_i;
	
	id_ex id_ex(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.flush(flush),
	
		// from ID
		.id_valid(id_valid),
		.id_rtlop_o(id_rtlop_o),
		.id_rtltype_o(id_rtltype_o),
		.id_pc_o(id_pc_o),
		.id_src1_o(id_src1_o),
		.id_src2_o(id_src2_o),
		.id_gprs_waddr_o(id_gprs_waddr_o),
		
		// to EX
		.ex_valid(ex_valid),
		.ex_rtlop_i(ex_rtlop_i),
		.ex_rtltype_i(ex_rtltype_i),
		.ex_pc_i(ex_pc_i),
		.ex_src1_i(ex_src1_i),
		.ex_src2_i(ex_src2_i),
		.ex_gprs_waddr_i(ex_gprs_waddr_i)
	);
	
	
	// EX 阶段
	
	wire				ex_mem_ena_o;
	wire 				ex_mem_rw_o;
	wire [`DATA_BUS]	ex_mem_addr_o;
	wire [`DATA_BUS]	ex_mem_data_o;
	
	ex ex(
		// from ID
		.rtlop(ex_rtlop_i),
		.rtltype(ex_rtltype_i),
		.pc(ex_pc_i),
		.src1(ex_src1_i),
		.src2(ex_src2_i),
		.gprs_waddr_i(ex_gprs_waddr_i),
		
		// to EX_MEM
		.mem_ena_o(ex_mem_ena_o),
		.mem_rw_o(ex_mem_rw_o),
		.mem_addr_o(ex_mem_addr_o),
		.mem_data_o(ex_mem_data_o),
		
		// to EX_MEM
		.gprs_waddr_o(ex_gprs_waddr),
		.gprs_wdata_o(ex_gprs_wdata),
		
		// to cpu_ctrl
		.jump_flag(jump_flag),
		.jump_addr(jump_addr)
	);
	
	
	// EX -> MEM
	
	// 无独立的EX_MEM和MEM模块，MEM信号交由上层模块处理。
	// 期望在EX到MEM中间的上升沿上层MEM模块处理完毕。
	assign mem_mem_rw = ex_mem_rw_o;
	assign mem_mem_addr = ex_mem_addr_o;
	assign mem_mem_wdata = ex_mem_data_o;
	
	ex_mem_wb ex_mem_wb(
		.clk(clk),
		.rst(rst),
		
		// from EX
		.ex_valid(ex_valid),
		.ex_mem_ena(ex_mem_ena_o),
		.gprs_waddr_i(ex_gprs_waddr),
		.gprs_wdata_i(ex_gprs_wdata),
		
		// from MEM
		.mem_rw_i(mem_mem_rw),
		.mem_rdata_i(mem_mem_rdata),
		
		// to GPRS
		.gprs_waddr_o(wb_gprs_waddr),
		.gprs_wdata_o(wb_gprs_wdata),
		
		// to cpu_ctrl
		.stall(stall)
	);
	
	
	// WB
	
	// 无独立的WB模块，WB信号交由GPRS模块处理。
	

endmodule
