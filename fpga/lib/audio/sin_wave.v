// sin_wave module returns sin(2pi * step * n / 1024) where step is a fixed point number.
// freqency = step * clk_freq / 1024

module sin_wave(
	input clk,
	input reset_n,
	input [15:0] step,		// Fixed point: 10-bit integer and 6-bit fraction
	output reg [15:0] dataout
);

	(* ram_init_file = "sintable.mif" *) reg [15:0] sintable [1023:0];

	reg [15:0] freq_counter;	//16bit counter

	always @(posedge clk)	//change data at posedge of lrclk
		dataout <= sintable[freq_counter[15:6]];	// 10-bit address;

	always @(posedge clk or negedge reset_n)	//step counter
		if(!reset_n)
			freq_counter <= 16'b0;
		else
			freq_counter <= freq_counter + step;

endmodule
