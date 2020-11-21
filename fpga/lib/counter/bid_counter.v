module bid_counter
#(
	parameter bound,
	parameter width = $clog2(bound)
) (
	input clk,
	input reset,
	input ena,
	input set,
	input [width-1:0] set_num,
	input updown,	// 1 for down
	output reg [width-1:0] num,
	output carry
);
	wire [31:0] w_bound = bound;

	wire [width-1:0] from, to;
	assign {from, to} = updown ? {w_bound[width-1:0], {width{1'b0}}} : {{width{1'b0}}, w_bound[width-1:0]};
	assign carry = ena && (num == to);

	always @ (posedge clk or posedge reset) begin
		if (reset) num = 0;
		else if (set) num = set_num;
		else if (ena) begin
			num = carry ? from : num + (updown ? (-1'b1) : (1'b1));
		end
	end

endmodule

module bid_counter_2bcd
#(
	parameter bcd_bound
)
(
	input clk,
	input reset,
	input ena,
	input set,
	input [7:0] set_num,
	input updown,
	output [7:0] cnt,
	output carry
);

	assign carry = ena && (cnt == (updown ? 0 : bcd_bound));

	wire carry1, carry2;
	wire set1 = set || carry1 || carry;
	wire set2 = set || carry2 || carry;
	wire [3:0] set_num1 = set ? set_num[3:0] : updown ? (carry ? bcd_bound[3:0] : 4'h9) : 4'h0;
	wire [3:0] set_num2 = set ? set_num[7:4] : updown ? (carry ? bcd_bound[7:4] : 4'h9) : 4'h0;

	bid_counter #(9) low (
		clk, reset, ena, set1, set_num1, updown, cnt[3:0], carry1
	);
	bid_counter #(9) high (
		clk, reset, ena && carry1, set2, set_num2, updown, cnt[7:4], carry2
	);
	
endmodule
