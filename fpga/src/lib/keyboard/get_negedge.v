module get_negedge(
	input clk,
	input rst,
	input in,
	output is_negedge
);

	reg [2:0] last_in;
	always @(posedge clk or posedge rst)
		last_in <= rst ? 3'b0 : {last_in[1:0], in};
	
	assign is_negedge = last_in[2] & ~last_in[1];

endmodule
