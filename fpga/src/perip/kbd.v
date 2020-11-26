`include "../common.v"

module kbd(
	input  wire				clk,
	input  wire				rst,
	input  wire				ena,
	input  wire				rw,
	input  wire	[`DATA_BUS]	addr,
	output reg	[`DATA_BUS]	rdata,
	input  wire	[`DATA_BUS]	wdata,
	
	// keyboard
	input  wire	PS2_CLK,
	input  wire	PS2_DAT
);

	wire ready, overflow;
	reg nextdata_n;
	wire keyup, extend;
	wire [7:0] scancode;

	always @(posedge clk)
		if (rst) begin
			nextdata_n <= 1'b1;
		end
		else begin
			rdata <= `DATA_ZERO;
			nextdata_n <= 1'b1;
			if (ready && nextdata_n) begin
				rdata <= {keyup, extend, {22{1'b0}}, scancode};
				nextdata_n <= 1'b0;
			end
		end

	ps2_keyboard ps2_keyboard (
		.clk(clk),
		.rst(rst),
		.ps2_clk(PS2_CLK),
		.ps2_data(PS2_DAT),
		.nextdata_n(nextdata_n),
		.keyup(keyup),
		.extend(extend),
		.scancode(scancode),
		.ready(ready),
		.overflow(overflow)
	);

endmodule
