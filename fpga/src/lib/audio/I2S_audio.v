module I2S_audio(
	input AUD_XCK,
	input reset_n,
	output reg AUD_BCK,
	output AUD_DATA,
	output reg AUD_LRCK,
	input [15:0] audiodata
);

	reg [7:0] bck_counter;
	reg [7:0] lr_counter;
	wire [7:0] bitaddr;

	//generate BCK 1.536MHz
	always @ (posedge AUD_XCK or negedge reset_n)
		if(!reset_n) begin
			bck_counter <= 8'd0;
			AUD_BCK     <= 1'b0;
		end
		else if(bck_counter >= 8'd5) begin
			bck_counter <= 8'd0;
			AUD_BCK <= ~AUD_BCK;
		end
		else
			bck_counter <= bck_counter + 8'd1;

	//generate LRCK, 48kHz, at negedge of BCK
	always @ (negedge AUD_BCK or negedge reset_n)
		if(!reset_n) begin
			lr_counter <= 8'd0;
			AUD_LRCK     <= 1'b0;
		end
		else if(lr_counter >= 8'd15) begin //div BCK by 32
			lr_counter <= 8'd0;
			AUD_LRCK <= ~AUD_LRCK;
		end
		else
			lr_counter <= lr_counter + 8'd1;

	//send data, input data avaible at posedge of lrclk, prepared at the posedge of bck
	assign  bitaddr  = 8'd15- lr_counter;
	assign  AUD_DATA = audiodata[bitaddr[3:0]];

endmodule 