module I2C_controller (
	input CLOCK,
	output I2C_SCLK,		//I2C CLOCK
	inout I2C_SDAT,			//I2C DATA
	input [23:0] I2C_DATA,	//DATA: [SLAVE_ADDR,SUB_ADDR,DATA]
	input GO,				//GO transfor
	output reg END,			//END transfor
	output reg [2:0] ACK,	//ACK
	input RESET_N
	// TEST
	// output [5:0] SD_COUNTER,
	// output SDO,
);

	reg SDO;
	reg SCLK;
	reg [23:0] SD;
	reg [5:0] SD_COUNTER;

	//SET CLK and SDIN
	assign I2C_SCLK = SCLK | ((SD_COUNTER >= 4 && SD_COUNTER <= 30) ? ~CLOCK : 0 );
	assign I2C_SDAT = SDO ? 1'bz : 0;

	reg ACK1, ACK2, ACK3;

	//--I2C COUNTER
	always @(negedge RESET_N or posedge CLOCK )
		if (!RESET_N) SD_COUNTER = 6'b111111;
		else begin
			if (GO == 0)
				SD_COUNTER = 6'b0;
			else if (SD_COUNTER < 6'b111111)
				SD_COUNTER = SD_COUNTER + 1;
		end


	always @(negedge RESET_N or posedge CLOCK ) begin
		if (!RESET_N) begin
			SCLK = 1;
			SDO = 1;
			ACK1 = 0;
			ACK2 = 0;
			ACK3 = 0;
			END = 1;
		end
		else
			case (SD_COUNTER)
				6'd0 : begin
					ACK1=0 ;ACK2=0 ;ACK3=0 ; END=0;
					SDO=1; SCLK=1; ACK=3'b0;
				end
				//start
				6'd1 : begin SD=I2C_DATA; SDO=0; end
				6'd2 : SCLK=0;
				//SLAVE ADDR
				6'd3 : SDO=SD[23];
				6'd4 : SDO=SD[22];
				6'd5 : SDO=SD[21];
				6'd6 : SDO=SD[20];
				6'd7 : SDO=SD[19];
				6'd8 : SDO=SD[18];
				6'd9 : SDO=SD[17];
				6'd10 : SDO=SD[16]; //WR
				6'd11 : SDO=1'b1; //wait for ACK
				//SUB ADDR
				6'd12 : begin SDO=SD[15]; ACK1=I2C_SDAT; end
				6'd13 : SDO=SD[14];
				6'd14 : SDO=SD[13];
				6'd15 : SDO=SD[12];
				6'd16 : SDO=SD[11];
				6'd17 : SDO=SD[10];
				6'd18 : SDO=SD[9];
				6'd19 : SDO=SD[8];
				6'd20 : SDO=1'b1; // wait for ACK
				//DATA
				6'd21 : begin SDO=SD[7]; ACK2=I2C_SDAT; end
				6'd22 : SDO=SD[6];
				6'd23 : SDO=SD[5];
				6'd24 : SDO=SD[4];
				6'd25 : SDO=SD[3];
				6'd26 : SDO=SD[2];
				6'd27 : SDO=SD[1];
				6'd28 : SDO=SD[0];
				6'd29 : SDO=1'b1;//ACK
				//stop
				6'd30 : begin SDO=1'b0; SCLK=1'b0; ACK3=I2C_SDAT; end
				6'd31 : begin SCLK=1'b1; ACK={ACK1,ACK2,ACK3}; end
				6'd32 : begin SDO=1'b1; END=1; end
			endcase
		end

endmodule
