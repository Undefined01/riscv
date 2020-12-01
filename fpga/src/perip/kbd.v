`include "../common.v"

module kbd(
	input  wire				clk,
	input  wire				rst,
	input  wire				ena,
	input  wire				rw,
	input  wire	[`DATA_BUS]	addr,
	output reg	[`DATA_BUS]	rdata,
	input  wire	[`DATA_BUS]	wdata,
	output reg  [7:0] count,
	output reg  [7:0] seg2,
	
	
	// keyboard
	input  wire	PS2_CLK,
	input  wire	PS2_DAT
);

	wire ready;
	wire [7:0] scancode;

	ps2_keyboard ps2_keyboard (
		.clk(clk),
		.rst(rst),
		.ps2_clk(PS2_CLK),
		.ps2_data(PS2_DAT),
		.ready(ready),
		.scancode(scancode)
	);
	
	`include "../lib/keyboard/scancode.h"
	wire is_keyup = scancode == `KEYUP;
	wire is_extend = scancode == `KEYEXTEND;
	
	reg [31:0] fifo[15:0];
	reg [3:0] head, tail;
	
	reg keyup, extend;
	reg shift;
	reg [9:0] last_code;

	(* ram_init_file = "keyboard/scancode2ascii.mif" *) reg [7:0] ascii_table[511:0];
	reg [7:0] ascii;
	always @(posedge clk)
		ascii <= ascii_table[{shift, scancode}];

	always @(posedge clk)
		if (rst) begin
			head <= 4'b0;
			tail <= 4'b0;
			keyup <= 1'b0;
			extend <= 1'b0;
			shift <= 1'b0;
			last_code <= 8'b0;
		end
		else begin
			rdata <= `DATA_ZERO;
			last_code <= 8'b0;
			if (ready) begin
				count <= count + 1'b1;
				seg2 <= scancode;
				if (is_keyup) keyup <= 1'b1;
				if (is_extend) extend <= 1'b1;
				if (!is_keyup && !is_extend) begin
					if (scancode == `KEY_LSHIFT || scancode == `KEY_RSHIFT)
						shift <= keyup ^ 1'b1;
					last_code <= {keyup, extend, scancode};
					keyup <= 1'b0;
					extend <= 1'b0;
				end
			end
			if (last_code[7:0] != 8'b0 && last_code[9] == 1'b0 && ascii != 8'b0) begin
				fifo[head] <= {{14{1'b0}}, last_code, ascii};
				head <= head + 1'b1;
			end
			if (ena && head != tail) begin
				rdata <= fifo[tail];
				tail <= tail + 1'b1;
			end
		end

endmodule
