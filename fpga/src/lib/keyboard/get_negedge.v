module get_negedge(
	input clk,
	input clr_n,
	input in,
	output is_negedge
);

	reg [2:0] last_in;
	always @(posedge clk or negedge clr_n)
		last_in <= !clr_n ? 3'b0 : {last_in[1:0], in};
	
	assign is_negedge = last_in[2] & ~last_in[1];

endmodule
