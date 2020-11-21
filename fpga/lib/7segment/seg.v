module seg_uint4(
	input ena,
	input [3:0] x,
	output reg [6:0] y
);
	always @ (*)
	if (!ena)
		y = 7'b1111111;
	else
	case (x)
		0: y = 7'b1000000;
		1: y = 7'b1111001;
		2: y = 7'b0100100;
		3: y = 7'b0110000;
		4: y = 7'b0011001;
		5: y = 7'b0010010;
		6: y = 7'b0000010;
		7: y = 7'b1111000;
		8: y = 7'b0000000;
		9: y = 7'b0010000;
		10: y = 7'b0001000;
		11: y = 7'b0000011;
		12: y = 7'b1000110;
		13: y = 7'b0100001;
		14: y = 7'b0000110;
		15: y = 7'b0001110;
		default: y = 7'bxxxxxxx;
	endcase
endmodule

module seg_uint8(
	input ena,
	input [7:0] x,
	output [6:0] high,
	output [6:0] low
);
	seg_uint4 seg_high (ena, x[7:4], high);
	seg_uint4 seg_low (ena, x[3:0], low);
endmodule
