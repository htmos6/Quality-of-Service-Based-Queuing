module readalgorithm (clk, start, reset, button0, button1, temp_number, readed_data,
								number_to_store, next_read, time_to_read, buffer1_12bit, buffer2_12bit,
								buffer3_12bit, buffer4_12bit);

	input clk;
	input start;
	input reset;
	input button0; // input button for 4-bit binary data entrance as 0
	input button1; // input button for 4-bit binary data entrance as 1
	
	output reg [3:0] temp_number; // 4-bit input which iss kept temporarily in here !
	output reg [3:0] number_to_store; // decimal 4-bit number --> created from taken input
	output reg [3:0] next_read; // data will be readed next
	output reg [3:0] readed_data; // output that you have read and display in your screen
	output reg time_to_read;

	output reg [11:0] buffer1_12bit;
	output reg [11:0] buffer2_12bit;
	output reg [11:0] buffer3_12bit;
	output reg [11:0] buffer4_12bit;
		
	reg [4:0] ct_start_low_noise; // in order to check & prevent noise problem
	reg [4:0] ct_start_high_noise;
	
	reg [4:0] ct_button0_low_noise;
	reg [4:0] ct_button0_high_noise;
	
	reg [4:0] ct_button1_low_noise;
	reg [4:0] ct_button1_high_noise;
	
	reg button0_is_pressed; // input buttons --> 0 (inactive, not pressed)
	reg button1_is_pressed; // input buttons --> 1 (active, pressed)
	reg number_is_definite; // Is stored is definite ?
	
	reg start_equal_0_ct_allower; // until start button is at least 15 clock cycle 0 --> it determines it is not a noise

	reg allow_for_input; // this allows always block to take input until next start button pressing
	 
	reg [1:0] buffer1 [0:5]; // define buffer1
	reg [1:0] buffer2 [0:5]; // define buffer2
	reg [1:0] buffer3 [0:5]; // define buffer3
	reg [1:0] buffer4 [0:5]; // define buffer4

	reg [2:0] ct1; // define counter 1
	reg [2:0] ct2; // define counter 2
	reg [2:0] ct3; // define counter 3
	reg [2:0] ct4; // define counter 4
	reg [2:0] ct_inp; // define counter for input to take 4 bit exact

	reg [2:0] i;
	reg [28:0] counter_read;

	reg [9:0] ct_dropped;
	reg [9:0] ct_dropped_buffer1;
	reg [9:0] ct_dropped_buffer2;
	reg [9:0] ct_dropped_buffer3;
	reg [9:0] ct_dropped_buffer4;
	
	reg [9:0] ct_received;
	reg [9:0] ct_received_buffer1;
	reg [9:0] ct_received_buffer2;
	reg [9:0] ct_received_buffer3;
	reg [9:0] ct_received_buffer4;
	
	reg [9:0] ct_transmitted;
	reg [9:0] ct_transmitted_buffer1;
	reg [9:0] ct_transmitted_buffer2;
	reg [9:0] ct_transmitted_buffer3;
	reg [9:0] ct_transmitted_buffer4;
	
	
	// define weights of buffers for data transfer
	reg [5:0] weight1;
	reg [5:0] weight2;
	reg [5:0] weight3;
	reg [5:0] weight4;
	
	
	initial begin
		allow_for_input = 1'd0;
		button0_is_pressed = 1'd0; // initially input button0 is inactive --> 0
		button1_is_pressed = 1'd0; // initially input button1 is inactive --> 0
		
		ct1 = 3'd0; 
		ct2 = 3'd0; 
		ct3 = 3'd0; 
		ct4 = 3'd0; 
		
		ct_inp = 3'd0;

		ct_start_low_noise = 5'd0;
		ct_start_high_noise = 5'd0;
		
		ct_button0_low_noise = 5'd0;
		ct_button0_high_noise = 5'd0;
		
		ct_button1_low_noise = 5'd0;
		ct_button1_high_noise = 5'd0;
		
		ct_dropped = 10'd0;
		ct_dropped_buffer1 = 10'd0;
		ct_dropped_buffer2 = 10'd0;
		ct_dropped_buffer3 = 10'd0;
		ct_dropped_buffer4 = 10'd0;
		
		ct_received = 10'd0;
		ct_received_buffer1 = 10'd0;
		ct_received_buffer2 = 10'd0;
		ct_received_buffer3 = 10'd0;
		ct_received_buffer4 = 10'd0;
		
		ct_transmitted = 10'd0;
		ct_transmitted_buffer1 = 10'd0;
		ct_transmitted_buffer2 = 10'd0;
		ct_transmitted_buffer3 = 10'd0;
		ct_transmitted_buffer4 = 10'd0;
		
		time_to_read <= 1'b0;
		counter_read <= 0;
		
		i = 3'd0;
		
		number_is_definite = 1'd0;
		
		start_equal_0_ct_allower = 1'b1; // initially allowed
		
		// weight of each buffer for data read according to counter(ct1,ct2,ct3,ct4)
		weight1 = 6'd0;
		weight2 = 6'd0;
		weight3 = 6'd0;
		weight4 = 6'd0;
		
		next_read = 0;
		
		
	end

	//// Mehmet input read ///
	always @(posedge clk) begin
	
		buffer1_12bit <= {buffer1[0],	buffer1[1], buffer1[2], buffer1[3], buffer1[4], buffer1[5]}; // first in is the rightest one 
		buffer2_12bit <= {buffer2[0], buffer2[1], buffer2[2], buffer2[3], buffer2[4], buffer2[5]}; // first in is the rightest one 
		buffer3_12bit <= {buffer3[0], buffer3[1], buffer3[2], buffer3[3], buffer3[4], buffer3[5]}; // first in is the rightest one 
		buffer4_12bit <= {buffer4[0], buffer4[1], buffer4[2], buffer4[3], buffer4[4], buffer4[5]}; // first in is the rightest one 
	
		
		if (reset == 1'd0) begin // if you press to reset , turn back to initial conditions
			ct_inp <= 3'd0;
			allow_for_input <= 1'd0; // if people do not press start button --> do not allow for input entrance
			button0_is_pressed <= 1'd0; // initially input button0 is inactive --> 0
			button1_is_pressed <= 1'd0; // initially input button1 is inactive --> 0
			ct_start_low_noise <= 0;
			ct_start_high_noise <= 0;
			start_equal_0_ct_allower <= 1;
		end
		
		////// Start signal is given //////
		else if (start == 1'd0 && reset == 1'd1) begin // when people press start button, take just 4-bit until next start button.
			if (ct_start_low_noise > 15) begin
				allow_for_input <= 1'd1;
				button0_is_pressed <= 1'd0;
				button1_is_pressed <= 1'd0;
				ct_inp <= 3'd0;
				ct_start_high_noise <= 0;
				ct_start_low_noise <= 0;
				start_equal_0_ct_allower <= 0;
			end
			else if (start_equal_0_ct_allower == 1'b1) begin 
				ct_start_low_noise <= ct_start_low_noise + 1;
			end
		end
		
		else if (start == 1'd1 && reset == 1'd1) begin // when people press start button, take just 4-bit until next start button.
			if (ct_start_high_noise > 15) begin
				ct_start_high_noise <= 0;
				ct_start_low_noise <= 0;
				start_equal_0_ct_allower <= 1;
			end
			else begin 
				ct_start_high_noise <= ct_start_high_noise + 1;
			end
		end
		
		////// 4-bit input is started to given //////
		if (ct_inp <= 3'd3 && allow_for_input == 1'd1 && reset == 1'd1) begin
				if (button0 == 1'd0 && button0_is_pressed == 1'd0) begin // if button0 is pressed && previously not pressed to button0 --> increase counter
					if(ct_button0_low_noise > 15) begin
						temp_number[3'd3 - ct_inp] <= 1'd0;
						button0_is_pressed <= 1'd1; 
						ct_inp <= ct_inp + 3'd1;
						ct_button0_low_noise <= 0;
						start_equal_0_ct_allower <= 1;
					end
					else begin 
						ct_button0_low_noise <= ct_button0_low_noise + 1;
					end
				end 
				else if (button1 == 1'd0 && button1_is_pressed == 1'd0) begin // if button1 is pressed && previously not pressed to button1 --> increase counter
					if(ct_button1_low_noise > 15) begin	
						temp_number[3'd3 - ct_inp] <= 1'd1;
						button1_is_pressed <= 1'd1;
						ct_inp <= ct_inp + 3'd1;
						ct_button1_low_noise <= 0;
						start_equal_0_ct_allower <= 1;
					end
					else begin 
						ct_button1_low_noise <= ct_button1_low_noise + 1;
					end
				end 
				else if (button0 == 1'd1 && button0_is_pressed == 1'd1) begin // if button0 is returned to 1 --> can be used as an input again
					if (ct_button0_high_noise > 15) begin
						ct_button0_high_noise <= 0;
						button0_is_pressed <= 1'd0;
					end
					else begin
						ct_button0_high_noise <= ct_button0_high_noise + 1;
					end
				end
				else if (button1 == 1'd1 && button1_is_pressed == 1'd1) begin // if button1 is returned to 1 --> can be used as an input again
					if (ct_button1_high_noise > 15) begin
						ct_button1_high_noise <= 0;
						button1_is_pressed <= 1'd0;
					end
					else begin
						ct_button1_high_noise <= ct_button1_high_noise + 1;
					end
				end
		end
				
		////// 4-bit input given is completed - filled 4 bit temprorary input //////
		else if (ct_inp == 3'd4 && reset == 1'd1 && number_is_definite == 1'd0) begin
			ct_transmitted <= ct_transmitted + 10'd1;
			if (temp_number[1:0] == 2'b00) begin
				number_to_store <= 4'd0;
				number_is_definite = 1'd1; 
			end
			else if (temp_number[1:0] == 2'b01) begin
				number_to_store <= 4'd1;
				number_is_definite = 1'd1;
			end
			else if (temp_number[1:0] == 2'b10) begin
				number_to_store <= 4'd2;
				number_is_definite = 1'd1;
			end
			else if (temp_number[1:0] == 2'b11) begin
				number_to_store <= 4'd3;
				number_is_definite = 1'd1;
			end
		end
		
		////// Stored number is determined, send it to corresponding buffer //////
		else if (ct_inp == 3'd4 && reset == 1'd1 && number_is_definite == 1'd1) begin // if counter reaches 4, set it to 0 again
			start_equal_0_ct_allower <= 1;
			if (temp_number[3:2] == 2'b00) begin // Store inside buffer 1
				number_is_definite = 1'd0;
				ct_transmitted_buffer1 <= ct_transmitted_buffer1 + 1;
				if (ct1 <= 5) begin
					buffer1[3'd5-ct1] <= number_to_store; // start storing from index 5
					ct1 <= ct1 + 3'd1;
				end
				else if (ct1 == 6) begin
					ct1 <= 3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
					ct_dropped_buffer1 <= ct_dropped_buffer1 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer1[3'd5-i] <= buffer1[3'd4-i];
						end
					buffer1[3'd0] <= number_to_store;
				end
				case(ct1)
					0: weight1 <= 6'd9;
					1: weight1 <= 6'd13;
					2: weight1 <= 6'd15;
					3: weight1 <= 6'd16;
					4: weight1 <= 6'd17;
					5: weight1 <= 6'd19;
				endcase
				if (ct3 == 3'd5 && ct1==3'd6) begin
					if (ct2<3'd5) begin
						weight1 <= 6'd20;
					end
					else begin
						weight3 <= 6'd20;
					end
				end
			end
			else if (temp_number[3:2] == 2'b01) begin // Store inside buffer 2
				number_is_definite = 1'd0;
				ct_transmitted_buffer2 <= ct_transmitted_buffer2 + 1;
				if (ct2 <= 5) begin
					buffer2[3'd5-ct2] <= number_to_store;  // start storing from index 5
					ct2 <= ct2 + 3'd1;
				end
				else if (ct2 == 6) begin
					ct2 <=3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
					ct_dropped_buffer2 <= ct_dropped_buffer2 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer2[3'd5-i] <= buffer2[3'd4-i];
						end
					buffer2[3'd0] <= number_to_store;
				end
				case(ct2)
					0: weight2 <= 6'd6;
					1: weight2 <= 6'd8;
					2: weight2 <= 6'd12;
					3: weight2 <= 6'd14;
					4: weight2 <= 6'd18;
					5: weight2 <= 6'd21;
				endcase
				if (ct3 == 3'd5 && ct1 == 3'd6) begin
					if (ct2<3'd5) begin
						weight1 <= 6'd20;
					end
					else begin
						weight3 <= 6'd20;
					end
				end
			end
			else if (temp_number[3:2] == 2'b10) begin // Store inside buffer 3
					number_is_definite = 1'd0;
					ct_transmitted_buffer3 <= ct_transmitted_buffer3 + 1;
					if (ct3 <= 5) begin
						buffer3[3'd5-ct3] <= number_to_store;  // start storing from index 5
						ct3 <= ct3 + 3'd1;
					end
					else if (ct3 == 6) begin
						ct3 <= 3'd6; // since 1 input comes while 6 box is full, slide one
						ct_dropped <= ct_dropped + 10'd1;
						ct_dropped_buffer3 <= ct_dropped_buffer3 + 1;
							for(i=3'd0; i < 3'd5; i=i+3'd1) begin
								buffer3[3'd5-i] <= buffer3[3'd4-i];
							end
						buffer3[3'd0] <= number_to_store;
					end
					case(ct3)
						0: weight3 <= 6'd3;
						1: weight3 <= 6'd5;
						2: weight3 <= 6'd7;
						3: weight3 <= 6'd11;
						4: weight3 <= 6'd19;
						5: weight3 <= 6'd23;
					endcase
					if (ct3 == 3'd5 && ct1 == 3'd6) begin
						if (ct2<3'd5) begin
							weight1 <= 6'd20;
						end
						else begin
							weight3 <= 6'd20;
						end
					end
			end
			else if (temp_number[3:2] == 2'b11) begin // Store inside buffer 4
				number_is_definite = 1'd0;
				ct_transmitted_buffer4 <= ct_transmitted_buffer4 + 1;
				if (ct4 <= 5) begin
					buffer4[3'd5-ct4] <= number_to_store;  // start storing from index 5
					ct4 <= ct4 + 3'd1;
				end
				else if (ct4 == 6) begin
					ct4 <= 3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
					ct_dropped_buffer4 <= ct_dropped_buffer4 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer4[3'd5-i] <= buffer4[3'd4-i];
						end
					buffer4[3'd0] <= number_to_store;
				end
				case(ct4)
					0: weight4 <= 6'd1;
					1: weight4 <= 6'd2;
					2: weight4 <= 6'd4;
					3: weight4 <= 6'd10;
					4: weight4 <= 6'd22;
					5: weight4 <= 6'd24;
				endcase
			end
			ct_inp <= 3'd0;
			allow_for_input <= 1'd0; // after reset your counter, do not allow input entrance until pressing start button
		end // end of the "else if (ct_inp == 3'd4 && reset == 1'd1 && number_is_definite == 1'd1)"
		
		////// Determine the buffer in order to read data ////// 
		if (1) begin
			if ((weight4 > weight3) && (weight4 > weight2) && (weight4 > weight1)) begin
				next_read[3:2] <= 4'd3;
				next_read[1:0] <= buffer4[5];
			end
			else if ((weight3 > weight4) && (weight3 > weight2) && (weight3 > weight1)) begin
				next_read[3:2] <= 4'd2;
				next_read[1:0] <= buffer3[5];
			end
			else if ((weight2 > weight4) && (weight2 > weight3) && (weight2 > weight1)) begin
				next_read[3:2] <= 4'd1;
				next_read[1:0] <= buffer2[5];
			end
			else if ((weight1 > weight4) && (weight1 > weight3) && (weight1 > weight2)) begin
				next_read[3:2] <= 4'd0;
				next_read[1:0] <= buffer1[5];
			end	
			else if ((weight1 == weight2) && (weight2 == weight3) && (weight3 == weight4)) begin
				next_read <= 0;
			end
			else if ((ct1 == 3'd0) && (ct2 == 3'd0) && (ct3 == 3'd0) && (ct4 == 3'd0))	begin // bu kısım gereksiz olabilir ama ne olur ne olmaz dursun
				next_read <= 0;
				// sıfırlama kararını uyguladık burda, inputumuz olmadan almak isterse sonradan hata da tanımlayabiliriz. Mesela outputu 4 bit yerine 5 bit alıp son bit 1 ise hata göster, 0 ise sıkıntı yok gibi belki.
			end
		end
		
		////// In order to read your data, count up to 3 seconds //////
		if (1) begin 
			if (counter_read < 900) begin // 75_000_000
				counter_read <= counter_read + 1;
			end
			else if (counter_read == 900) begin // 75_000_000
				if (ct1 == 0 && ct2 == 0 && ct3 == 0 && ct4 == 0) begin
					time_to_read <= 0;
					counter_read <= 0;
				end
				else begin
					time_to_read <= 1;
					counter_read <= 0;
				end
			end
			if (time_to_read == 1'b1) begin
				readed_data [3:0] <= next_read [3:0];
				ct_received <= ct_received + 1;
				time_to_read <= 1'b0;
				case(next_read[3:2])
					0: begin
						ct1 <= ct1 - 3'd1;
						ct_received_buffer1 <= ct_received_buffer1 + 1;
						for(i=3'd0; i < 3'd5 ; i=i+3'd1) begin
							buffer1[3'd5-i] <= buffer1[3'd4-i];
						end
						case(ct1-1)
							0: weight1 <= 6'd0;
							1: weight1 <= 6'd9;
							2: weight1 <= 6'd13;
							3: weight1 <= 6'd15;
							4: weight1 <= 6'd16;
							5: weight1 <= 6'd17;
							6: weight1 <= 6'd19;
						endcase
					end
					1:begin
						ct2 <= ct2 - 3'd1;
						ct_received_buffer2 <= ct_received_buffer2 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer2[3'd5-i] <= buffer2[3'd4-i];
						end
						case(ct2-1)
							0: weight2 <= 6'd0;
							1: weight2 <= 6'd6;
							2: weight2 <= 6'd8;
							3: weight2 <= 6'd12;
							4: weight2 <= 6'd14;
							5: weight2 <= 6'd18;
							6: weight2 <= 6'd21;
						endcase
						if (ct3 == 3'd5 && ct1 == 3'd6) begin
							if (ct2<3'd6) begin
								weight1 <= 6'd20;
							end
							else begin
								weight3 <= 6'd20;
							end
						end
					end
					2:begin
						ct3 <= ct3 - 3'd1;
						ct_received_buffer3 <= ct_received_buffer3 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer3[3'd5-i] <= buffer3[3'd4-i];
						end
						case(ct3-1)
							0: weight3 <= 6'd0;
							1: weight3 <= 6'd3;
							2: weight3 <= 6'd5;
							3: weight3 <= 6'd7;
							4: weight3 <= 6'd11;
							5: weight3 <= 6'd19;
							6: weight3 <= 6'd23;
						endcase
						if (ct3 == 3'd6 && ct1 == 3'd6) begin
							if (ct2<3'd5) begin
								weight1 <= 6'd20;
							end
							else begin
								weight3 <= 6'd20;
							end
						end
					end
					3:begin
						ct4 <= ct4 - 3'd1;
						ct_received_buffer4 <= ct_received_buffer4 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer4[3'd5-i] <= buffer4[3'd4-i];
						end
						case(ct4-1)
							0: weight4 <= 6'd0;
							1: weight4 <= 6'd1;
							2: weight4 <= 6'd2;
							3: weight4 <= 6'd4;
							4: weight4 <= 6'd10;
							5: weight4 <= 6'd22;
							6: weight4 <= 6'd24;
						endcase
					end
				endcase
			end
		end
	end
	
endmodule





