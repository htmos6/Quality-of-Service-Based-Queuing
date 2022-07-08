`timescale 1ns / 1ps

// image generator of a road and a sky 640x480 @ 60 fps

////////////////////////////////////////////////////////////////////////
module VGAnscreen(
	input clk,           // 50 MHz
	output o_hsync,      // horizontal sync
	output o_vsync,	     // vertical sync
	output [7:0] o_red,
	output [7:0] o_blue,
	output [7:0] o_green,
	output reg clkk,
	input start, 
	input reset, 
	input button0, // input button for 4-bit binary data entrance as 0
	input button1, // input button for 4-bit binary data entrance as 1
	output reg [3:0] temp_number, // 4-bit input which iss kept temporarily in here !
	output reg [3:0] number_to_store, // decimal 4-bit number --> created from taken input
	output reg [3:0] next_read, // data will be readed next
	output reg [3:0] readed_data, // output that you have read and display in your screen
	output reg time_to_read,
	output reg [2:0] ct1, // define counter 1
	output reg [2:0] ct2, // define counter 2
	output reg [2:0] ct3, // define counter 3
	output reg [2:0] ct4 // define counter 4
	
);


	
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
	
	/////////////////////////////////////////////////////////////////////////////////////////////// üstü readal
	
	reg [9:0] ctx = 0;  // horizontal counter
	reg [9:0] cty = 0;  // vertical counter
	reg [7:0] r_red = 0;
	reg [7:0] r_blue = 0;
	reg [7:0] r_green = 0;
	
	reg [11:0]x_b1 = 12'd240;
	reg [11:0]x_b2 = 12'd320;
	reg [11:0]x_b3 = 12'd400;
	reg [11:0]x_b4 = 12'd480;
	
	reg [11:0]y_b6 = 12'd155;
	reg [11:0]y_b5 = 12'd195;
	reg [11:0]y_b4 = 12'd235;
	reg [11:0]y_b3 = 12'd275;
	reg [11:0]y_b2 = 12'd315;
	reg [11:0]y_b1 = 12'd355;
	
	
	reg [11:0] x_br1 = 12'd576 ;
	reg [11:0] x_br2 = 12'd616 ;
	reg [11:0] x_br3 = 12'd656 ;
	reg [11:0] x_br4 = 12'd696 ;
	reg [11:0] x_brt = 12'd750 ;
	
	reg [11:0] x_bi1 = 12'd561 ;
	reg [11:0] x_bi2 = 12'd601 ;
	reg [11:0] x_bi3 = 12'd641 ;
	reg [11:0] x_bi4 = 12'd681 ;
	reg [11:0] x_bit = 12'd735 ;
	
	reg [11:0] y_t = 12'd140 ;
	reg [11:0] y_r = 12'd220 ;
	reg [11:0] y_d = 12'd300 ;
	
	
	
	
	
	wire [2:0] b1c1;
	
	reg rst = 0;  // for PLL
	
	wire clk25MHz;
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// clk divider 50 MHz to 25 MHz
	clk25 ip1(
		.rst(rst),
		.refclk(clk),
		.outclk_0(clk25MHz),
		.locked()
		);  
	// end clk divider 50 MHz to 25 MHz
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/*
	readalgorithm reda(
		.clk(clk), 
		.start(), 
		.reset(), 
		.button0(), 
		.button1(), 
		.temp_number(), 
		.readed_data(), 
		.ct1(ct1),
		.ct2(ct2),
		.ct3(ct3),
		.ct4(ct4),
		.number_to_store(), 
		.next_read(),  
		.time_to_read(),
			.b1_5(b15), 
		.b1_4(b14), 
		.b1_3(b13), 	
		.b1_2(b12), 
		.b1_1(b11),
		.b1_0(b10), 
			.b2_5(b25), 
		.b2_4(b24), 
		.b2_3(b23), 	
		.b2_2(b22), 
		.b2_1(b21),
		.b2_0(b20), 
			.b3_5(b35), 
		.b3_4(b34), 
		.b3_3(b33), 	
		.b3_2(b32), 
		.b3_1(b31),
		.b3_0(b30), 
			.b4_5(b45), 
		.b4_4(b44), 
		.b4_3(b43), 	
		.b4_2(b42), 
		.b4_1(b41),
		.b4_0(b40), 

		
	);
	*/
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
initial 
	begin
		clkk <= 0;

		allow_for_input <= 1'd0;
		button0_is_pressed <= 1'd0; // initially input button0 is inactive --> 0
		button1_is_pressed <= 1'd0; // initially input button1 is inactive --> 0
		
		ct1 <= 3'd6; 
		ct2 <= 3'd6; 
		ct3 <= 3'd6; 
		ct4 <= 3'd6; 
		
		weight1 = 6'd19;
		weight2 = 6'd21;
		weight3 = 6'd23;
		weight4 = 6'd24;
		
		ct_inp = 3'd0;
		
		next_read = 4'b0100;
		temp_number = 4'b0100;
		readed_data = 4'b0100;
		

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
		
		ct_transmitted = 10'd24;
		ct_transmitted_buffer1 = 10'd6;
		ct_transmitted_buffer2 = 10'd6;
		ct_transmitted_buffer3 = 10'd6;
		ct_transmitted_buffer4 = 10'd6;
		
		time_to_read <= 1'b0;
		counter_read <= 0;
		
		i = 3'd0;
		
		number_is_definite = 1'd0;
		
		start_equal_0_ct_allower = 1'b1; // initially allowed
		
		
		next_read = 0;
		

		
	end
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// counter and sync generation
	always @(posedge clk25MHz)  // horizontal counter
		begin		
			clkk = clkk +1;
			if (ctx <  799)
				ctx <= ctx + 1;  // horizontal counter (including off-screen horizontal 160 pixels) total of 800 pixels 
			else
				ctx <= 0;              
		end  // always 
	
	always @ (posedge clk25MHz)  // vertical counter
		begin		
			if (ctx == 799)  // only counts up 1 count after horizontal finishes 800 counts
				begin		
					if (cty <  525)  // vertical counter (including off-screen vertical 45 pixels) total of 525 pixels
						cty <= cty + 1;
					else
						cty <= 0;              
				end  // if (ctx...
		end  // always
	// end counter and sync generation  

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// hsync and vsync output assignments
	assign o_hsync = (ctx >=  0 && ctx <  96) ? 1:0;  // hsync high for 96 counts                                                 
	assign o_vsync = (cty >=  0 && cty <  2) ? 1:0;   // vsync high for 2 counts
	// end hsync and vsync output assignments

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// Mehmet input read ///
	always @(posedge clk) begin
		
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
			if (ct_start_low_noise > 5) begin
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
			if (ct_start_high_noise > 5) begin
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
					if(ct_button0_low_noise > 5) begin
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
				if (button1 == 1'd0 && button1_is_pressed == 1'd0) begin // if button1 is pressed && previously not pressed to button1 --> increase counter
					if(ct_button1_low_noise > 5) begin	
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
				if (button0 == 1'd1 && button0_is_pressed == 1'd1) begin // if button0 is returned to 1 --> can be used as an input again
					if (ct_button0_high_noise > 5) begin
						ct_button0_high_noise <= 0;
						button0_is_pressed <= 1'd0;
					end
					else begin
						ct_button0_high_noise <= ct_button0_high_noise + 1;
					end
				end
				if (button1 == 1'd1 && button1_is_pressed == 1'd1) begin // if button1 is returned to 1 --> can be used as an input again
					if (ct_button1_high_noise > 5) begin
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
					buffer1[ct1] <= number_to_store; // start storing from index 5
					ct1 <= ct1 + 3'd1;
				end
				else if (ct1 == 6) begin
					ct1 <= 3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
					ct_dropped_buffer1 <= ct_dropped_buffer1 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) 
							begin
								buffer1[i] <= buffer1[i + 3'd1];
							end						
						buffer1[5] <= number_to_store;
						
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
					if (ct2 < 3'd5) begin
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
					buffer2[ct2] <= number_to_store;  // start storing from index 5
					ct2 <= ct2 + 3'd1;
				end
				else if (ct2 == 6) begin
					// since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
					ct_dropped_buffer2 <= ct_dropped_buffer2 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) 
							begin
								buffer2[i] <= buffer2[i + 3'd1];
							end						
						buffer2[5] <= number_to_store;
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
					if (ct2 < 3'd5) begin
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
						buffer3[ct3] <= number_to_store;  // start storing from index 5
						ct3 <= ct3 + 3'd1;
					end
					else if (ct3 == 6) begin
						ct3 <= 3'd6; // since 1 input comes while 6 box is full, slide one
						ct_dropped <= ct_dropped + 10'd1;
						ct_dropped_buffer3 <= ct_dropped_buffer3 + 1;
							for(i=3'd0; i < 3'd5; i=i+3'd1) 
								begin
									buffer3[i] <= buffer3[i + 3'd1];
								end
						buffer3[5] <= number_to_store;
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
						if (ct2 < 3'd5) begin
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
					buffer4[ct4] <= number_to_store;  // start storing from index 5
					ct4 <= ct4 + 3'd1;
				end
				else if (ct4 == 6) begin
					ct4 <= 3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
					ct_dropped_buffer4 <= ct_dropped_buffer4 + 1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) 
								begin
									buffer4[i] <= buffer4[i + 3'd1];
								end
					buffer4[5] <= number_to_store;
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
				next_read[1:0] <= buffer4[0];
			end
			else if ((weight3 > weight4) && (weight3 > weight2) && (weight3 > weight1)) begin
				next_read[3:2] <= 4'd2;
				next_read[1:0] <= buffer3[0];
			end
			else if ((weight2 > weight4) && (weight2 > weight3) && (weight2 > weight1)) begin
				next_read[3:2] <= 4'd1;
				next_read[1:0] <= buffer2[0];
			end
			else if ((weight1 > weight4) && (weight1 > weight3) && (weight1 > weight2)) begin
				next_read[3:2] <= 4'd0;
				next_read[1:0] <= buffer1[0];
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
			if (counter_read < 150000000) begin // 75_000_000
				counter_read <= counter_read + 1;
			end
			else if (counter_read >= 150000000) begin // 75_000_000
				if (ct1 == 0 && ct2 == 0 && ct3 == 0 && ct4 == 0) begin
					time_to_read <= 0;
					counter_read <= 0;
				end
				else begin
					counter_read <= 0;
					readed_data [3:0] <= next_read [3:0];
					ct_received <= ct_received + 1;
					case(next_read[3:2])
						2'd0: begin
							if (ct1 >= 1)
								begin
									ct1 <= ct1 - 3'd1;
									ct_received_buffer1 <= ct_received_buffer1 + 1;
									
									
									for(i=3'd0; i < 3'd5; i=i+3'd1) 
								begin
									buffer1[i] <= buffer1[i + 3'd1];
								end
									
									
								/*				
									buffer1[0] <= buffer1[1];
									buffer1[1] <= buffer1[2];
									buffer1[2] <= buffer1[3];
									buffer1[3] <= buffer1[4];
									buffer1[4] <= buffer1[5];
								*/
									case(ct1 - 1)
										0: weight1 <= 6'd0;
										1: weight1 <= 6'd9;
										2: weight1 <= 6'd13;
										3: weight1 <= 6'd15;
										4: weight1 <= 6'd16;
										5: weight1 <= 6'd17;
										6: weight1 <= 6'd19;
									endcase
								end
							end
						2'd1:begin
							if (ct2 >= 1)
							begin
								ct2 <= ct2 - 3'd1;
								ct_received_buffer2 <= ct_received_buffer2 + 1;
								
								/*
								buffer2[0] <= buffer2[1];
								buffer2[1] <= buffer2[2];
								buffer2[2] <= buffer2[3];
								buffer2[3] <= buffer2[4];
								buffer2[4] <= buffer2[5];
								*/
								
								for(i=3'd0; i < 3'd5; i=i+3'd1) 
								begin
									buffer2[i] <= buffer2[i + 3'd1];
								end
								
								case(ct2 - 1)
									0: weight2 <= 6'd0;
									1: weight2 <= 6'd6;
									2: weight2 <= 6'd8;
									3: weight2 <= 6'd12;
									4: weight2 <= 6'd14;
									5: weight2 <= 6'd18;
									6: weight2 <= 6'd21;
								endcase
								if (ct3 == 3'd5 && ct1 == 3'd6) 
								begin
									if (ct2 < 3'd6) begin
										weight1 <= 6'd20;
									end
									else begin
										weight3 <= 6'd20;
									end
								end
							end
						end
						2'd2:begin
						if (ct3 >= 1)
							begin
								ct3 <= ct3 - 3'd1;
								ct_received_buffer3 <= ct_received_buffer3 + 1;
								
								for(i=3'd0; i < 3'd5; i=i+3'd1) 
								begin
									buffer3[i] <= buffer3[i + 3'd1];
								end
								
								/*
								buffer3[0] <= buffer3[1];
								buffer3[1] <= buffer3[2];
								buffer3[2] <= buffer3[3];
								buffer3[3] <= buffer3[4];
								buffer3[4] <= buffer3[5];
								*/
								
								case(ct3-1)
									0: weight3 <= 6'd0;
									1: weight3 <= 6'd3;
									2: weight3 <= 6'd5;
									3: weight3 <= 6'd7;
									4: weight3 <= 6'd11;
									5: weight3 <= 6'd19;
									6: weight3 <= 6'd23;
								endcase
								if (ct3 == 3'd6 && ct1 == 3'd6) 
								begin
									if (ct2 < 3'd5) begin
										weight1 <= 6'd20;
									end
									else begin
										weight3 <= 6'd20;
									end
								end
							end
						end
						2'd3:begin
						if (ct4 >= 1)
							begin
								ct4 <= ct4 - 3'd1;
								ct_received_buffer4 <= ct_received_buffer4 + 1;
								for(i=3'd0; i < 3'd5; i=i+3'd1) 
								begin
									buffer4[i] <= buffer4[i + 3'd1];
								end
								
								/*
								buffer4[0] <= buffer4[1];
								buffer4[1] <= buffer4[2];
								buffer4[2] <= buffer4[3];
								buffer4[3] <= buffer4[4];
								buffer4[4] <= buffer4[5];
								*/
								
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
						end
					endcase
				end
			end
		end
	end










///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// pattern generate
	always @ (posedge clk)
		begin
			
		/////////////////////////////////////////////////////////////////////////////////////////////////////// ekran düzenlemeleri:
			////////////////////////////////////////////////////////////////////////////////////// 1(0 150) , 14(410 514) y=y+30, x=x+140
			if (cty < 70 || cty >= 480)
				begin             	
					r_red <= 8'd255;    // white
					r_blue <= 8'd255;
					r_green <= 8'd255;
				end
			////////////////////////////////////////////////////////////////////////////////////// 1,14 y=y+30, x=x+140
			
			//////////////////////////////////////////////////////////////////////////////////////				SAGDAKI YAZILAR
			else if ((ctx > 550) && (cty >= 70 || cty < 480) ) 						
				begin
					if ((cty < 102) && (cty >= 100) && (ctx < 775))								// yatay alt çizgi
						begin
							r_red <= 8'd0;    // black
							r_blue <= 8'd0;																
							r_green <= 8'd0;
						end
					else if ((((ctx < 572) && (ctx >= 570)) 										// dikey çizgiler
								|| ((ctx < 612) && (ctx >= 610))
								|| ((ctx < 652) && (ctx >= 650))
								|| ((ctx < 692) && (ctx >= 690))
								|| ((ctx < 732) && (ctx >= 730)) ) && (cty < 400))
						begin
							r_red <= 8'd0;    // black
							r_blue <= 8'd0;															
							r_green <= 8'd0;
						end
					else if (((cty < 100) && (cty >= 70)) && (ctx >= 570)	)										// başlıklar  1 2 3 4 T
						begin
							if ((((ctx < (570 + 22)) && (ctx >= (570 + 20))) && ((cty < (60 + 32)) && (cty >= (60 + 12)))))                  		// 1 çiz
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;												
									r_green <= 8'd0;
								end
							else if ((((ctx < (610 + 26)) && (ctx >= (610 + 16))) && ((cty < (60 + 32)) && (cty >= (60 + 12))))                  		// 2 çiz
									&& (  ((cty < (60 + 14)) || (cty >= (60 + 30)) || ((cty < (60 + 24)) && (cty >= (60 + 22))) ) 						// yatay çizgiler
									|| (((cty < (60 + 24)) && (ctx >= (610 + 24))) || (((cty >= (60 + 22))) && (ctx < (610 + 18)))  ) ))					// dikey çizgiler
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;												
									r_green <= 8'd0;
								end
							else if ((((ctx < (650 + 26)) && (ctx >= (650 + 16))) && ((cty < (60 + 32)) && (cty >= (60 + 12))))                  		// 3 çiz
								&& (  ((cty < (60 + 14)) || (cty >= (60 + 30)) || ((cty < (60 + 23)) && (cty >= (60 + 21))) ) 						// yatay
								|| (ctx >= (650 + 24))) )																													// dikey
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;												
									r_green <= 8'd0;
								end
							else if ((((ctx < (690 + 26)) && (ctx >= (690 + 16))) && ((cty < (60 + 32)) && (cty >= (60 + 12))))       		// 4 çiz
								&& ( ((cty < (60 + 23)) && (cty >= (60 + 21)))					// yatay
									|| (	((ctx < (690 + 18)) && (cty < (60 + 23)))																		// dikey sol
									|| (ctx >= (690 + 24))	)  ))																										// dikey sağ
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;												
									r_green <= 8'd0;
								end	
							else if ((((ctx < (730 + 26)) && (ctx >= (730 + 16))) && ((cty < (60 + 32)) && (cty >= (60 + 12))))       		// T çiz
										&& (  (cty < (60 + 14)) 																											// yatay
											|| (((ctx < (730 + 22)) && (ctx >= (730 + 20))) && ((cty < (60 + 32)) && (cty >= (60 + 12))))	)  )																										// dikey
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;												
									r_green <= 8'd0;
								end
							else
								begin
									r_red <= 8'd255;    // white
									r_blue <= 8'd255;												//
									r_green <= 8'd255;
								end			
						end
					
					else if (((ctx >= 550) && (ctx < 570))	&& ((cty >= 100) && (cty < 450)))																								///////////////// Soldaki T R D yazıları
						begin
							if (((ctx < (535 + 26)) && (ctx >= (535 + 16))) && ((cty < (140 + 32)) && (cty >= (140 + 12))))       		// T çiz
								begin
									if (  (cty < (140 + 14)) 																											// yatay
										|| (((ctx < (535 + 22)) && (ctx >= (535 + 20))) && ((cty < (140 + 32)) && (cty >= (140 + 12))))	)  																										// dikey
									begin
										r_red <= 8'd0;    // black
										r_blue <= 8'd0;												
										r_green <= 8'd0;
									end
									else 
										begin
											r_red <= 8'd255;    // white
											r_blue <= 8'd255;												//
											r_green <= 8'd255;
										end
								end		
							else if ((((ctx < (535 + 26)) && (ctx >= (535 + 16))) && ((cty < (220 + 32)) && (cty >= (220 + 12))))                  			// R çiz
							&& (  (((cty == (220 + 14)) || (cty == (220 + 21))) && ((ctx >= (535 + 23))))																	// yatay1 21 14
							|| (((cty == (220 + 13)) || (cty == (220 + 22))) && ((ctx < (535 + 25)))) 																		// yatay2 22 13
							|| (((cty == (220 + 12)) || (cty == (220 + 23))) && ((ctx < (535 + 24))))																		// yatay3 23 12
							|| ((cty == (220 + 24)) && ((ctx >= (535 + 18)) && (ctx < (535 + 20))) )																		// yatay4 24
							|| ((cty == (220 + 25)) && ((ctx >= (535 + 18)) && (ctx < (535 + 21))) )																		// yatay4 25
							|| ((cty == (220 + 26)) && ((ctx >= (535 + 19)) && (ctx < (535 + 22))) )																		// yatay4 26
							|| ((cty == (220 + 27)) && ((ctx >= (535 + 20)) && (ctx < (535 + 23))) )																		// yatay4 27
							|| ((cty == (220 + 28)) && ((ctx >= (535 + 21)) && (ctx < (535 + 24))) )																		// yatay4 28
							|| ((cty == (220 + 29)) && ((ctx >= (535 + 22)) && (ctx < (535 + 25))) )																		// yatay4 29
							|| ((cty == (220 + 30)) && ((ctx >= (535 + 23)) && (ctx < (535 + 26))) )																		// yatay4 29
							|| ((cty == (220 + 31)) && ((ctx >= (535 + 24)) && (ctx < (535 + 26))) )																		// yatay4 30
							|| ((cty == (220 + 32)) && ((ctx >= (535 + 25)) && (ctx < (535 + 26))) )																		// yatay4 31
								|| ((ctx == (535 + 25)) && ((cty < (220 + 21)) && (cty >= (220 + 14))))																		// dikey sağ1
								|| ((ctx == (535 + 24)) && ((cty < (220 + 22)) && (cty >= (220 + 13))))																		// dikey sağ2
								|| (ctx < (535 + 18)) ))																																	// dikey sol
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;												
									r_green <= 8'd0;
								end
							else if ((((ctx < (535 + 26)) && (ctx >= (535 + 16))) && ((cty < (300 + 32)) && (cty >= (300 + 12))))                  				// D çiz
								&& (  (((cty == (300 + 12)) || (cty == (300 + 31))) && ((ctx < (535 + 24))) )																	// yatay1
								|| (((cty == (300 + 13)) || (cty == (300 + 30))) && ((ctx < (535 + 25))) ) 																		// yatay2
								|| (((cty == (300 + 14)) || (cty == (300 + 29))) && ((ctx >= (535 + 23))) )																		// yatay3
									|| ((ctx == (535 + 25)) && ((cty < (300 + 30)) && (cty >= (300 + 14))))																		// dikey sağ1
									|| ((ctx == (535 + 24)) && ((cty < (300 + 31)) && (cty >= (300 + 13))))																		// dikey sağ2
									|| (ctx < (535 + 18)) ))																																	// dikey sol
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;												
									r_green <= 8'd0;
								end
							else 
								begin
									r_red <= 8'd255;    // white
									r_blue <= 8'd255;												//
									r_green <= 8'd255;
								end
						end
					
					
						/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM
									/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM
												/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM
															/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM
																			
				
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////// yüzler basamağı
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 300)&& (ct_transmitted >= 200)))

	begin
		if ((((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_bit - 15 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_bit - 15 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 200)&& (ct_transmitted >= 100)))

	begin
		if ((((ctx < (x_bit - 15 + 22)) && (ctx >= (x_bit - 15 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 100) && (ct_transmitted >= 0)))

	begin
		if ((((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  	// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_bit - 15 + 18)) || (ctx >= (x_bit - 15 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	


///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 300)&& (ct_dropped >= 200)))

	begin
		if ((((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_bit - 15 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_bit - 15 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 200)&& (ct_dropped >= 100)))

	begin
		if ((((ctx < (x_bit - 15 + 22)) && (ctx >= (x_bit - 15 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 100) && (ct_dropped >= 0)))

	begin
		if ((((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  	// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_bit - 15 + 18)) || (ctx >= (x_bit - 15 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	


///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 300)&& (ct_received >= 200)))

	begin
		if ((((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_bit - 15 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_bit - 15 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 200)&& (ct_received >= 100)))

	begin
		if ((((ctx < (x_bit - 15 + 22)) && (ctx >= (x_bit - 15 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 100) && (ct_received >= 0)))

	begin
		if ((((ctx < (x_bit - 15 + 26)) && (ctx >= (x_bit - 15 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  	// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_bit - 15 + 18)) || (ctx >= (x_bit - 15 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	


	
	
	
	
	
	
	
	
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// onlar basamağı
	
	
	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
(ct_dropped >= 90 && ct_dropped < 100))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_d + 23)))																			// dikey sol
				|| (ctx >= (x_bit + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 90)&& (ct_dropped >= 80)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_bit + 18)) 																										// dikey sol
			|| (ctx >= (x_bit + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 80)&& (ct_dropped >= 70)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_bit + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 70)&& (ct_dropped >= 60)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_bit + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bit + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 60)&& (ct_dropped >= 50)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_bit + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&
((ct_dropped < 50)&& (ct_dropped >= 40)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_bit + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 40)&& (ct_dropped >= 30)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_bit + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 30)&& (ct_dropped >= 20)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_bit + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_bit + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 20)&& (ct_dropped >= 10)))

	begin
		if ((((ctx < (x_bit + 22)) && (ctx >= (x_bit + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped < 10)&& (ct_dropped >= 0)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  	// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_bit + 18)) || (ctx >= (x_bit + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	

/////////////////////////////////////////////////////////


///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
(ct_received >= 90 && ct_received < 100))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_bit + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 90)&& (ct_received >= 80)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_bit + 18)) 																										// dikey sol
			|| (ctx >= (x_bit + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 80)&& (ct_received >= 70)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_bit + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 70)&& (ct_received >= 60)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_bit + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bit + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 60)&& (ct_received >= 50)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_bit + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  &&
((ct_received < 50)&& (ct_received >= 40)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| (ctx >= (x_bit + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 40)&& (ct_received >= 30)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_bit + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 30)&& (ct_received >= 20)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_bit + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_bit + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 20)&& (ct_received >= 10)))

	begin
		if ((((ctx < (x_bit + 22)) && (ctx >= (x_bit + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r+ 12))))  && 
((ct_received < 10)&& (ct_received >= 0)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  	// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_bit + 18)) || (ctx >= (x_bit + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	


///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
(ct_transmitted >= 90 && ct_transmitted < 100))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_t + 23)))																			// dikey sol
				|| (ctx >= (x_bit + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 90)&& (ct_transmitted >= 80)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_bit + 18)) 																										// dikey sol
			|| (ctx >= (x_bit + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 80)&& (ct_transmitted >= 70)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_bit + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 70)&& (ct_transmitted >= 60)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_bit + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bit + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 60)&& (ct_transmitted >= 50)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_bit + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&
((ct_transmitted < 50)&& (ct_transmitted >= 40)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| (	((ctx < (x_bit + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_bit + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 40)&& (ct_transmitted >= 30)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_bit + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 30)&& (ct_transmitted >= 20)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_bit + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_bit + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 20)&& (ct_transmitted >= 10)))

	begin
		if ((((ctx < (x_bit + 22)) && (ctx >= (x_bit + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted < 10)&& (ct_transmitted >= 0)))

	begin
		if ((((ctx < (x_bit + 26)) && (ctx >= (x_bit + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  	// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_bit + 18)) || (ctx >= (x_bit + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	
	
	
	
	else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && (ct_received_buffer1 >= 90))
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi1 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| (ctx >= (x_bi1 + 24))	)  ))																								// dikey sağ																begin
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

		
///////////// if counter received ends with 8 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 < 90)&& (ct_received_buffer1 >= 80)))
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_bi1 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi1 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end





///////////// if counter received ends with 7 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 < 80)&& (ct_received_buffer1 >= 70)))
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_bi1 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	

	
	
///////////// if counter received ends with 6 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 < 70)&& (ct_received_buffer1 >= 60)))
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_bi1 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi1 + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		


					
				

///////////// if counter received ends with 5 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&  
			((ct_received_buffer1 < 60)&& (ct_received_buffer1 >= 50)))
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi1 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_bi1 + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end
					
		
///////////// if counter received ends with 4 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
		((ct_received_buffer1 < 50)&& (ct_received_buffer1 >= 40)) )
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_bi1 + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_bi1 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
				
	
///////////// if counter received ends with 3 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
			((ct_received_buffer1 < 40)&& (ct_received_buffer1 >= 30)) )
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_bi1 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
					
	
///////////// if counter received ends with 2 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
	((ct_received_buffer1 < 30)&& (ct_received_buffer1 >= 20)) )
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_bi1 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_bi1 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
					
		
///////////// if counter received ends with 1 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
			((ct_received_buffer1 < 20)&& (ct_received_buffer1 >= 10)) )
	begin
		if ((((ctx < (x_bi1 + 22)) && (ctx >= (x_bi1 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
				
		///////////// if counter received ends with 0 ///////////// 
else if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
		((ct_received_buffer1 < 10)&& (ct_received_buffer1 >= 0)) )
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_bi1 + 18)) || (ctx >= (x_bi1 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
			


	
	
					
					
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
	(ct_received_buffer2 >= 90))
	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi2 + 18)) &&  (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_bi2 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
 ((ct_received_buffer2 < 90)&& (ct_received_buffer2 >= 80)))
	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_bi2 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi2 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer2 < 80)&& (ct_received_buffer2 >= 70)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_bi2 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
((ct_received_buffer2 < 70)&& (ct_received_buffer2 >= 60)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_bi2 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi2 + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer2 < 60)&& (ct_received_buffer2 >= 50)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi2 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_bi2 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer2 < 50)&& (ct_received_buffer2 >= 40)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_bi2 + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_bi2 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer2 < 40)&& (ct_received_buffer2 >= 30)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_bi2 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer2 < 30)&& (ct_received_buffer2 >= 20)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_bi2 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_bi2 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer2 < 20)&& (ct_received_buffer2 >= 10)))

	begin
		if ((((ctx < (x_bi2 + 22)) && (ctx >= (x_bi2 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer2 < 10)&& (ct_received_buffer2 >= 0)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_bi2 + 18)) || (ctx >= (x_bi2 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////



///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
(ct_received_buffer3 >= 90))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi3 + 18)) &&  (cty < (y_r + 23)))																		// dikey sol
				|| (ctx >= (x_bi3 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer3 < 90)&& (ct_received_buffer3 >= 80)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_bi3 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi3 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
((ct_received_buffer3 < 80)&& (ct_received_buffer3 >= 70)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_bi3 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer3 < 70)&& (ct_received_buffer3 >= 60)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_bi3 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi3 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
((ct_received_buffer3 < 60)&& (ct_received_buffer3 >= 50)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi3 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_bi3 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
((ct_received_buffer3 < 50)&& (ct_received_buffer3 >= 40)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_bi3 + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_bi3 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer3 < 40)&& (ct_received_buffer3 >= 30)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_bi3 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
((ct_received_buffer3 < 30)&& (ct_received_buffer3 >= 20)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_bi3 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_bi3 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) &&
((ct_received_buffer3 < 20)&& (ct_received_buffer3 >= 10)))

	begin
		if ((((ctx < (x_bi3 + 22)) && (ctx >= (x_bi3 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && 
((ct_received_buffer3 < 10)&& (ct_received_buffer3 >= 0)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_bi3 + 18)) || (ctx >= (x_bi3 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& (ct_received_buffer4 >= 90))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi4 + 18)) &&  (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_bi4 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 90)&& (ct_received_buffer4 >= 80)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_bi4 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi4 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 80)&& (ct_received_buffer4 >= 70)))
	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_bi4 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&&((ct_received_buffer4 < 70)&& (ct_received_buffer4 >= 60)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_bi4 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi4 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 60)&& (ct_received_buffer4 >= 50)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_bi4 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_bi4 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 50)&& (ct_received_buffer4 >= 40)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_bi4 + 18)) && (cty < (y_r + 23)))																				// dikey sol
				|| (ctx >= (x_bi4 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 40)&& (ct_received_buffer4 >= 30)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_bi4 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 30)&& (ct_received_buffer4 >= 20)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_bi4 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_bi4 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 20)&& (ct_received_buffer4 >= 10)))

	begin
		if ((((ctx < (x_bi4 + 22)) && (ctx >= (x_bi4 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 < 10)&& (ct_received_buffer4 >= 0)))
	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_bi4 + 18)) || (ctx >= (x_bi4 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
/////////////////////////////////////////////////////////////////////////////////////////// received sonu
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

	///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&
  (ct_transmitted_buffer1 >= 90))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi1 + 18)) &&  (cty < (y_t + 23)))																			// dikey sol
				|| (ctx >= (x_bi1 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) && 
((ct_transmitted_buffer1 < 90)&& (ct_transmitted_buffer1 >= 80)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_bi1 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi1 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))
 && ((ct_transmitted_buffer1 < 80)&& (ct_transmitted_buffer1 >= 70)))


	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_bi1 + 24))	)  )																							// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  
((ct_transmitted_buffer1 < 70)&& (ct_transmitted_buffer1 >= 60)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_bi1 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi1 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) && 
((ct_transmitted_buffer1 < 60)&& (ct_transmitted_buffer1 >= 50)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi1 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_bi1 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  
((ct_transmitted_buffer1 < 50)&& (ct_transmitted_buffer1 >= 40)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| 	((ctx < (x_bi1 + 18)) && (cty < (y_t + 23)))																																					// dikey sol
				|| (ctx >= (x_bi1 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  
((ct_transmitted_buffer1 < 40)&& (ct_transmitted_buffer1 >= 30)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_bi1 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  
((ct_transmitted_buffer1 < 30)&& (ct_transmitted_buffer1 >= 20)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_bi1 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_bi1 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  
((ct_transmitted_buffer1 < 20)&& (ct_transmitted_buffer1 >= 10)))

	begin
		if ((((ctx < (x_bi1 + 22)) && (ctx >= (x_bi1 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  
((ct_transmitted_buffer1 < 10)&& (ct_transmitted_buffer1 >= 0)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_bi1 + 18)) || (ctx >= (x_bi1 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
	
	///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
(ct_transmitted_buffer2 >= 90))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi2 + 18)) &&  (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_bi2 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&
((ct_transmitted_buffer2 < 90)&& (ct_transmitted_buffer2 >= 80)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_bi2 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi2 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer2 < 80)&& (ct_transmitted_buffer2 >= 70)))
 
	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_bi2 + 24))	)  )																							// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&
((ct_transmitted_buffer2 < 70)&& (ct_transmitted_buffer2 >= 60)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_bi2 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi2 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer2 < 60)&& (ct_transmitted_buffer2 >= 50)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi2 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_bi2 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer2 < 50)&& (ct_transmitted_buffer2 >= 40)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| (	((ctx < (x_bi2 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_bi2 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer2 < 40)&& (ct_transmitted_buffer2 >= 30)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_bi2 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer2 < 30)&& (ct_transmitted_buffer2 >= 20)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_bi2 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_bi2 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer2 < 20)&& (ct_transmitted_buffer2 >= 10)))

	begin
		if ((((ctx < (x_bi2 + 22)) && (ctx >= (x_bi2 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (  ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer2 < 10)&& (ct_transmitted_buffer2 >= 0)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_bi2 + 18)) || (ctx >= (x_bi2 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
	///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////





///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
(ct_transmitted_buffer3 >= 90))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi3 + 18)) &&  (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_bi3 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 90)&& (ct_transmitted_buffer3 >= 80)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_bi3 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi3 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&
((ct_transmitted_buffer3 < 80)&& (ct_transmitted_buffer3 >= 70)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_bi3 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 70)&& (ct_transmitted_buffer3 >= 60)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_bi3 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi3 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 60)&& (ct_transmitted_buffer3 >= 50)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi3 + 18)) && (cty < (y_t + 23)))																	// dikey sol
				|| ((ctx >= (x_bi3 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 50)&& (ct_transmitted_buffer3 >= 40)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| (	((ctx < (x_bi3 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_bi3 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 40)&& (ct_transmitted_buffer3 >= 30)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_bi3 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 30)&& (ct_transmitted_buffer3 >= 20)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_bi3 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_bi3 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 20)&& (ct_transmitted_buffer3 >= 10)))

	begin
		if ((((ctx < (x_bi3 + 22)) && (ctx >= (x_bi3 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer3 < 10)&& (ct_transmitted_buffer3 >= 0)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_bi3 + 18)) || (ctx >= (x_bi3 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
	///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////





///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
(ct_transmitted_buffer4 >= 90))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi4 + 18)) &&  (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_bi4 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&
((ct_transmitted_buffer4 < 90)&& (ct_transmitted_buffer4 >= 80)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_bi4 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi4 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&
((ct_transmitted_buffer4 < 80)&& (ct_transmitted_buffer4 >= 70)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_bi4 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer4 < 70)&& (ct_transmitted_buffer4 >= 60)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_bi4 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi4 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer4 < 60)&& (ct_transmitted_buffer4 >= 50)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_bi4 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_bi4 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer4 < 50)&& (ct_transmitted_buffer4 >= 40)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| (	((ctx < (x_bi4 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_bi4 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer4 < 40)&& (ct_transmitted_buffer4 >= 30)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_bi4 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&
((ct_transmitted_buffer4 < 30)&& (ct_transmitted_buffer4 >= 20)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_bi4 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_bi4 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer4 < 20)&& (ct_transmitted_buffer4 >= 10)))

	begin
		if ((((ctx < (x_bi4 + 22)) && (ctx >= (x_bi4 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && 
((ct_transmitted_buffer4 < 10)&& (ct_transmitted_buffer4 >= 0)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_bi4 + 18)) || (ctx >= (x_bi4 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end


	///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////




///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&  
(ct_dropped_buffer1 >= 90))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi1 + 18)) &&  (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_bi1 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&
((ct_dropped_buffer1 < 90)&& (ct_dropped_buffer1 >= 80)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_bi1 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi1 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer1 < 80)&& (ct_dropped_buffer1 >= 70)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_bi1 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer1 < 70)&& (ct_dropped_buffer1 >= 60)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_bi1 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi1 + 24)) && (cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer1 < 60)&& (ct_dropped_buffer1 >= 50)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi1 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_bi1 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer1 < 50)&& (ct_dropped_buffer1 >= 40)))
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_bi1 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_bi1 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer1 < 40)&& (ct_dropped_buffer1 >= 30)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_bi1 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&
((ct_dropped_buffer1 < 30)&& (ct_dropped_buffer1 >= 20)))

	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_bi1 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_bi1 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer1 < 20)&& (ct_dropped_buffer1 >= 10)))

	begin
		if ((((ctx < (x_bi1 + 22)) && (ctx >= (x_bi1 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (  ((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer1 < 10)&& (ct_dropped_buffer1 >= 0)))
	begin
		if ((((ctx < (x_bi1 + 26)) && (ctx >= (x_bi1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  			// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_bi1 + 18)) || (ctx >= (x_bi1 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////




///////////// if counter received ends with 8 ///////////// 
else if (((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12)))) && 
(ct_dropped_buffer2 >= 90))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi2 + 18)) && (cty < (y_d + 23)))																			// dikey sol
				|| (ctx >= (x_bi2 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 90)&& (ct_dropped_buffer2 >= 80)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_bi2 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi2 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 80)&& (ct_dropped_buffer2 >= 70)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_bi2 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 70)&& (ct_dropped_buffer2 >= 60)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_bi2 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi2 + 24)) && (cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 60)&& (ct_dropped_buffer2 >= 50)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi2 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_bi2 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 50)&& (ct_dropped_buffer2 >= 40)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_bi2 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_bi2 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 40)&& (ct_dropped_buffer2 >= 30)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_bi2 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 30)&& (ct_dropped_buffer2 >= 20)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_bi2 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_bi2 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 20)&& (ct_dropped_buffer2 >= 10)))

	begin
		if ((((ctx < (x_bi2 + 22)) && (ctx >= (x_bi2 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer2 < 10)&& (ct_dropped_buffer2 >= 0)))

	begin
		if ((((ctx < (x_bi2 + 26)) && (ctx >= (x_bi2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  			// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_bi2 + 18)) || (ctx >= (x_bi2 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////




///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&  
(ct_dropped_buffer3 >= 90))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi3 + 18)) && (cty < (y_d + 23)))																			// dikey sol
				|| (ctx >= (x_bi3 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 90)&& (ct_dropped_buffer3 >= 80)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_bi3 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi3 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 80)&& (ct_dropped_buffer3 >= 70)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_bi3 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 70)&& (ct_dropped_buffer3 >= 60)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_bi3 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi3 + 24)) && (cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 60)&& (ct_dropped_buffer3 >= 50)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi3 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_bi3 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&
((ct_dropped_buffer3 < 50)&& (ct_dropped_buffer3 >= 40)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_bi3 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_bi3 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 40)&& (ct_dropped_buffer3 >= 30)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_bi3 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 30)&& (ct_dropped_buffer3 >= 20)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_bi3 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_bi3 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 20)&& (ct_dropped_buffer3 >= 10)))

	begin
		if ((((ctx < (x_bi3 + 22)) && (ctx >= (x_bi3 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer3 < 10)&& (ct_dropped_buffer3 >= 0)))

	begin
		if ((((ctx < (x_bi3 + 26)) && (ctx >= (x_bi3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  			// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_bi3 + 18)) || (ctx >= (x_bi3 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////



///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
(ct_dropped_buffer4 >= 90))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi4 + 18)) && (cty < (y_d + 23)))																			// dikey sol
				|| (ctx >= (x_bi4 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 90)&& (ct_dropped_buffer4 >= 80)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_bi4 + 18)) 																										// dikey sol
			|| (ctx >= (x_bi4 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 80)&& (ct_dropped_buffer4 >= 70)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_bi4 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 70)&& (ct_dropped_buffer4 >= 60)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_bi4 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_bi4 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 60)&& (ct_dropped_buffer4 >= 50)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_bi4 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_bi4 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&
((ct_dropped_buffer4 < 50)&& (ct_dropped_buffer4 >= 40)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_bi4 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_bi4 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 40)&& (ct_dropped_buffer4 >= 30)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_bi4 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 30)&& (ct_dropped_buffer4 >= 20)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_bi4 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_bi4 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 20)&& (ct_dropped_buffer4 >= 10)))

	begin
		if ((((ctx < (x_bi4 + 22)) && (ctx >= (x_bi4 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && 
((ct_dropped_buffer4 < 10)&& (ct_dropped_buffer4 >= 0)))

	begin
		if ((((ctx < (x_bi4 + 26)) && (ctx >= (x_bi4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  	// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_bi4 + 18)) || (ctx >= (x_bi4 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// birler basamağı
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    total count
				
/// total number 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd9) ||(ct_received == 10'd19) || (ct_received == 10'd29) 
	|| (ct_received == 10'd39) || (ct_received == 10'd49) || (ct_received == 10'd59) 
	|| (ct_received == 10'd69) || (ct_received == 10'd79) || (ct_received == 10'd89) 
	|| (ct_received == 10'd99)))
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_brt + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| (ctx >= (x_brt + 24))	)  ))																								// dikey sağ																begin
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

		
///////////// if counter received ends with 8 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd8) ||(ct_received == 10'd18) || (ct_received == 10'd28) 
	|| (ct_received == 10'd38) || (ct_received == 10'd48) || (ct_received == 10'd58) 
	|| (ct_received == 10'd68) || (ct_received == 10'd78) || (ct_received == 10'd88) 
	|| (ct_received == 10'd98)))
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_brt + 18)) 																										// dikey sol
			|| (ctx >= (x_brt + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end





///////////// if counter received ends with 7 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd7) ||(ct_received == 10'd17) || (ct_received == 10'd27) 
	|| (ct_received == 10'd37) || (ct_received == 10'd47) || (ct_received == 10'd57) 
	|| (ct_received == 10'd67) || (ct_received == 10'd77) || (ct_received == 10'd87) 
	|| (ct_received == 10'd97)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																									// yatay
				|| (ctx >= (x_brt + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	

	
	
///////////// if counter received ends with 6 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd6) ||(ct_received == 10'd16) || (ct_received == 10'd26) 
	|| (ct_received == 10'd36) || (ct_received == 10'd46) || (ct_received == 10'd56) 
	|| (ct_received == 10'd66) || (ct_received == 10'd76) || (ct_received == 10'd86) 
	|| (ct_received == 10'd96)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_brt + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_brt + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		


					
				

///////////// if counter received ends with 5 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd5) ||(ct_received == 10'd15) || (ct_received == 10'd25) 
	|| (ct_received == 10'd35) || (ct_received == 10'd45) || (ct_received == 10'd55) 
	|| (ct_received == 10'd65) || (ct_received == 10'd75) || (ct_received == 10'd85) 
	|| (ct_received == 10'd95)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_brt + 18)) && 	(cty < (y_r + 23)))																	// dikey sol
				|| ((ctx >= (x_brt + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end
					
		
///////////// if counter received ends with 4 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd4) ||(ct_received == 10'd14) || (ct_received == 10'd24) 
	|| (ct_received == 10'd34) || (ct_received == 10'd44) || (ct_received == 10'd54) 
	|| (ct_received == 10'd64) || (ct_received == 10'd74) || (ct_received == 10'd84) 
	|| (ct_received == 10'd94)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_brt + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_brt + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
				
	
///////////// if counter received ends with 3 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd3) ||(ct_received == 10'd13) || (ct_received == 10'd23) 
	|| (ct_received == 10'd33) || (ct_received == 10'd43) || (ct_received == 10'd53) 
	|| (ct_received == 10'd63) || (ct_received == 10'd73) || (ct_received == 10'd83) 
	|| (ct_received == 10'd93)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_brt + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
					
	
///////////// if counter received ends with 2 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd2) ||(ct_received == 10'd12) || (ct_received == 10'd22) 
	|| (ct_received == 10'd32) || (ct_received == 10'd42) || (ct_received == 10'd52) 
	|| (ct_received == 10'd62) || (ct_received == 10'd72) || (ct_received == 10'd82) 
	|| (ct_received == 10'd92)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_brt + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_brt + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
					
		
///////////// if counter received ends with 1 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd1) ||(ct_received == 10'd11) || (ct_received == 10'd21) 
	|| (ct_received == 10'd31) || (ct_received == 10'd41) || (ct_received == 10'd51) 
	|| (ct_received == 10'd61) || (ct_received == 10'd71) || (ct_received == 10'd81) 
	|| (ct_received == 10'd91)) )
	begin
		if ((((ctx < (x_brt + 22)) && (ctx >= (x_brt + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
				
		///////////// if counter received ends with 0 ///////////// 
else if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received == 10'd0) ||(ct_received == 10'd10) || (ct_received == 10'd20) 
	|| (ct_received == 10'd30) || (ct_received == 10'd40) || (ct_received == 10'd50) 
	|| (ct_received == 10'd60) || (ct_received == 10'd70) || (ct_received == 10'd80) 
	|| (ct_received == 10'd90)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_brt + 18)) || (ctx >= (x_brt + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
			
					

/////////////////////////////////////////////////////////////////////////////////////////// received sonu
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
	

	
				
			///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd9) ||(ct_transmitted == 10'd19) || (ct_transmitted == 10'd29) 
	|| (ct_transmitted == 10'd39) || (ct_transmitted == 10'd49) || (ct_transmitted == 10'd59) 
	|| (ct_transmitted == 10'd69) || (ct_transmitted == 10'd79) || (ct_transmitted == 10'd89) 
	|| (ct_transmitted == 10'd99)))
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_brt + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_brt + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) && ((ct_transmitted == 10'd8) ||(ct_transmitted == 10'd18) || (ct_transmitted == 10'd28) 
	|| (ct_transmitted == 10'd38) || (ct_transmitted == 10'd48) || (ct_transmitted == 10'd58) 
	|| (ct_transmitted == 10'd68) || (ct_transmitted == 10'd78) || (ct_transmitted == 10'd88) 
	|| (ct_transmitted == 10'd98)))
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_brt + 18)) 																										// dikey sol
			|| (ctx >= (x_brt + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd7) ||(ct_transmitted == 10'd17) || (ct_transmitted == 10'd27) 
	|| (ct_transmitted == 10'd37) || (ct_transmitted == 10'd47) || (ct_transmitted == 10'd57) 
	|| (ct_transmitted == 10'd67) || (ct_transmitted == 10'd77) || (ct_transmitted == 10'd87) 
	|| (ct_transmitted == 10'd97)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_brt + 24))	)  )																							// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd6) ||(ct_transmitted == 10'd16) || (ct_transmitted == 10'd26) 
	|| (ct_transmitted == 10'd36) || (ct_transmitted == 10'd46) || (ct_transmitted == 10'd56) 
	|| (ct_transmitted == 10'd66) || (ct_transmitted == 10'd76) || (ct_transmitted == 10'd86) 
	|| (ct_transmitted == 10'd96))) 
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_brt + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_brt + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd5) ||(ct_transmitted == 10'd15) || (ct_transmitted == 10'd25) 
	|| (ct_transmitted == 10'd35) || (ct_transmitted == 10'd45) || (ct_transmitted == 10'd55) 
	|| (ct_transmitted == 10'd65) || (ct_transmitted == 10'd75) || (ct_transmitted == 10'd85) 
	|| (ct_transmitted == 10'd95)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_brt + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_brt + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd4) ||(ct_transmitted == 10'd14) || (ct_transmitted == 10'd24) 
	|| (ct_transmitted == 10'd34) || (ct_transmitted == 10'd44) || (ct_transmitted == 10'd54) 
	|| (ct_transmitted == 10'd64) || (ct_transmitted == 10'd74) || (ct_transmitted == 10'd84) 
	|| (ct_transmitted == 10'd94)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| 	((ctx < (x_brt + 18)) && (cty < (y_t + 23)))																																					// dikey sol
				|| (ctx >= (x_brt + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd3) ||(ct_transmitted == 10'd13) || (ct_transmitted == 10'd23) 
	|| (ct_transmitted == 10'd33) || (ct_transmitted == 10'd43) || (ct_transmitted == 10'd53) 
	|| (ct_transmitted == 10'd63) || (ct_transmitted == 10'd73) || (ct_transmitted == 10'd83) 
	|| (ct_transmitted == 10'd93)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_brt + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd2) ||(ct_transmitted == 10'd12) || (ct_transmitted == 10'd22) 
	|| (ct_transmitted == 10'd32) || (ct_transmitted == 10'd42) || (ct_transmitted == 10'd52) 
	|| (ct_transmitted == 10'd62) || (ct_transmitted == 10'd72) || (ct_transmitted == 10'd82) 
	|| (ct_transmitted == 10'd92)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_brt + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_brt + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd1) ||(ct_transmitted == 10'd11) || (ct_transmitted == 10'd21) 
	|| (ct_transmitted == 10'd31) || (ct_transmitted == 10'd41) || (ct_transmitted == 10'd51) 
	|| (ct_transmitted == 10'd61) || (ct_transmitted == 10'd71) || (ct_transmitted == 10'd81) 
	|| (ct_transmitted == 10'd91))) 
	begin
		if ((((ctx < (x_brt + 22)) && (ctx >= (x_brt + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted == 10'd0) ||(ct_transmitted == 10'd10) || (ct_transmitted == 10'd20) 
	|| (ct_transmitted == 10'd30) || (ct_transmitted == 10'd40) || (ct_transmitted == 10'd50) 
	|| (ct_transmitted == 10'd60) || (ct_transmitted == 10'd70) || (ct_transmitted == 10'd80) 
	|| (ct_transmitted == 10'd90))) 
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_brt + 18)) || (ctx >= (x_brt + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////


///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&  ((ct_dropped == 10'd9) ||(ct_dropped == 10'd19) || (ct_dropped == 10'd29) 
	|| (ct_dropped == 10'd39) || (ct_dropped == 10'd49) || (ct_dropped == 10'd59) 
	|| (ct_dropped == 10'd69) || (ct_dropped == 10'd79) || (ct_dropped == 10'd89) 
	|| (ct_dropped == 10'd99)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_brt + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_brt + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd8) ||(ct_dropped == 10'd18) || (ct_dropped == 10'd28) 
	|| (ct_dropped == 10'd38) || (ct_dropped == 10'd48) || (ct_dropped == 10'd58) 
	|| (ct_dropped == 10'd68) || (ct_dropped == 10'd78) || (ct_dropped == 10'd88) 
	|| (ct_dropped == 10'd98)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_brt + 18)) 																										// dikey sol
			|| (ctx >= (x_brt + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd7) ||(ct_dropped == 10'd17) || (ct_dropped == 10'd27) 
	|| (ct_dropped == 10'd37) || (ct_dropped == 10'd47) || (ct_dropped == 10'd57) 
	|| (ct_dropped == 10'd67) || (ct_dropped == 10'd77) || (ct_dropped == 10'd87) 
	|| (ct_dropped == 10'd97)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_brt + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd6) ||(ct_dropped == 10'd16) || (ct_dropped == 10'd26) 
	|| (ct_dropped == 10'd36) || (ct_dropped == 10'd46) || (ct_dropped == 10'd56) 
	|| (ct_dropped == 10'd66) || (ct_dropped == 10'd76) || (ct_dropped == 10'd86) 
	|| (ct_dropped == 10'd96)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_brt + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_brt + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd5) ||(ct_dropped == 10'd15) || (ct_dropped == 10'd25) 
	|| (ct_dropped == 10'd35) || (ct_dropped == 10'd45) || (ct_dropped == 10'd55) 
	|| (ct_dropped == 10'd65) || (ct_dropped == 10'd75) || (ct_dropped == 10'd85) 
	|| (ct_dropped == 10'd95)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_brt + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_brt + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd4) ||(ct_dropped == 10'd14) || (ct_dropped == 10'd24) 
	|| (ct_dropped == 10'd34) || (ct_dropped == 10'd44) || (ct_dropped == 10'd54) 
	|| (ct_dropped == 10'd64) || (ct_dropped == 10'd74) || (ct_dropped == 10'd84) 
	|| (ct_dropped == 10'd94)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_brt + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_brt + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd3) ||(ct_dropped == 10'd13) || (ct_dropped == 10'd23) 
	|| (ct_dropped == 10'd33) || (ct_dropped == 10'd43) || (ct_dropped == 10'd53) 
	|| (ct_dropped == 10'd63) || (ct_dropped == 10'd73) || (ct_dropped == 10'd83) 
	|| (ct_dropped == 10'd93)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_brt + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd2) ||(ct_dropped == 10'd12) || (ct_dropped == 10'd22) 
	|| (ct_dropped == 10'd32) || (ct_dropped == 10'd42) || (ct_dropped == 10'd52) 
	|| (ct_dropped == 10'd62) || (ct_dropped == 10'd72) || (ct_dropped == 10'd82) 
	|| (ct_dropped == 10'd92)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_brt + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_brt + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd1) ||(ct_dropped == 10'd11) || (ct_dropped == 10'd21) 
	|| (ct_dropped == 10'd31) || (ct_dropped == 10'd41) || (ct_dropped == 10'd51) 
	|| (ct_dropped == 10'd61) || (ct_dropped == 10'd71) || (ct_dropped == 10'd81) 
	|| (ct_dropped == 10'd91)) )
	begin
		if ((((ctx < (x_brt + 22)) && (ctx >= (x_brt + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (  ((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped == 10'd0) ||(ct_dropped == 10'd10) || (ct_dropped == 10'd20) 
	|| (ct_dropped == 10'd30) || (ct_dropped == 10'd40) || (ct_dropped == 10'd50) 
	|| (ct_dropped == 10'd60) || (ct_dropped == 10'd70) || (ct_dropped == 10'd80) 
	|| (ct_dropped == 10'd90)) )
	begin
		if ((((ctx < (x_brt + 26)) && (ctx >= (x_brt + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  			// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_brt + 18)) || (ctx >= (x_brt + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end








	
	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    total count
	
	else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd9) ||(ct_received_buffer1 == 10'd19) || (ct_received_buffer1 == 10'd29) 
	|| (ct_received_buffer1 == 10'd39) || (ct_received_buffer1 == 10'd49) || (ct_received_buffer1 == 10'd59) 
	|| (ct_received_buffer1 == 10'd69) || (ct_received_buffer1 == 10'd79) || (ct_received_buffer1 == 10'd89) 
	|| (ct_received_buffer1 == 10'd99)))
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br1 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| (ctx >= (x_br1 + 24))	)  ))																								// dikey sağ																begin
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

		
///////////// if counter received ends with 8 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd8) ||(ct_received_buffer1 == 10'd18) || (ct_received_buffer1 == 10'd28) 
	|| (ct_received_buffer1 == 10'd38) || (ct_received_buffer1 == 10'd48) || (ct_received_buffer1 == 10'd58) 
	|| (ct_received_buffer1 == 10'd68) || (ct_received_buffer1 == 10'd78) || (ct_received_buffer1 == 10'd88) 
	|| (ct_received_buffer1 == 10'd98)))
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_br1 + 18)) 																										// dikey sol
			|| (ctx >= (x_br1 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end





///////////// if counter received ends with 7 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd7) ||(ct_received_buffer1 == 10'd17) || (ct_received_buffer1 == 10'd27) 
	|| (ct_received_buffer1 == 10'd37) || (ct_received_buffer1 == 10'd47) || (ct_received_buffer1 == 10'd57) 
	|| (ct_received_buffer1 == 10'd67) || (ct_received_buffer1 == 10'd77) || (ct_received_buffer1 == 10'd87) 
	|| (ct_received_buffer1 == 10'd97)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_br1 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	

	
	
///////////// if counter received ends with 6 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd6) ||(ct_received_buffer1 == 10'd16) || (ct_received_buffer1 == 10'd26) 
	|| (ct_received_buffer1 == 10'd36) || (ct_received_buffer1 == 10'd46) || (ct_received_buffer1 == 10'd56) 
	|| (ct_received_buffer1 == 10'd66) || (ct_received_buffer1 == 10'd76) || (ct_received_buffer1 == 10'd86) 
	|| (ct_received_buffer1 == 10'd96)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_br1 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br1 + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		


					
				

///////////// if counter received ends with 5 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd5) ||(ct_received_buffer1 == 10'd15) || (ct_received_buffer1 == 10'd25) 
	|| (ct_received_buffer1 == 10'd35) || (ct_received_buffer1 == 10'd45) || (ct_received_buffer1 == 10'd55) 
	|| (ct_received_buffer1 == 10'd65) || (ct_received_buffer1 == 10'd75) || (ct_received_buffer1 == 10'd85) 
	|| (ct_received_buffer1 == 10'd95)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br1 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_br1 + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end
					
		
///////////// if counter received ends with 4 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd4) ||(ct_received_buffer1 == 10'd14) || (ct_received_buffer1 == 10'd24) 
	|| (ct_received_buffer1 == 10'd34) || (ct_received_buffer1 == 10'd44) || (ct_received_buffer1 == 10'd54) 
	|| (ct_received_buffer1 == 10'd64) || (ct_received_buffer1 == 10'd74) || (ct_received_buffer1 == 10'd84) 
	|| (ct_received_buffer1 == 10'd94)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_br1 + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_br1 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
				
	
///////////// if counter received ends with 3 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd3) ||(ct_received_buffer1 == 10'd13) || (ct_received_buffer1 == 10'd23) 
	|| (ct_received_buffer1 == 10'd33) || (ct_received_buffer1 == 10'd43) || (ct_received_buffer1 == 10'd53) 
	|| (ct_received_buffer1 == 10'd63) || (ct_received_buffer1 == 10'd73) || (ct_received_buffer1 == 10'd83) 
	|| (ct_received_buffer1 == 10'd93)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_br1 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
					
	
///////////// if counter received ends with 2 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd2) ||(ct_received_buffer1 == 10'd12) || (ct_received_buffer1 == 10'd22) 
	|| (ct_received_buffer1 == 10'd32) || (ct_received_buffer1 == 10'd42) || (ct_received_buffer1 == 10'd52) 
	|| (ct_received_buffer1 == 10'd62) || (ct_received_buffer1 == 10'd72) || (ct_received_buffer1 == 10'd82) 
	|| (ct_received_buffer1 == 10'd92)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_br1 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_br1 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
					
		
///////////// if counter received ends with 1 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd1) ||(ct_received_buffer1 == 10'd11) || (ct_received_buffer1 == 10'd21) 
	|| (ct_received_buffer1 == 10'd31) || (ct_received_buffer1 == 10'd41) || (ct_received_buffer1 == 10'd51) 
	|| (ct_received_buffer1 == 10'd61) || (ct_received_buffer1 == 10'd71) || (ct_received_buffer1 == 10'd81) 
	|| (ct_received_buffer1 == 10'd91)) )
	begin
		if ((((ctx < (x_br1 + 22)) && (ctx >= (x_br1 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
				
		///////////// if counter received ends with 0 ///////////// 
else if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer1 == 10'd0) ||(ct_received_buffer1 == 10'd10) || (ct_received_buffer1 == 10'd20) 
	|| (ct_received_buffer1 == 10'd30) || (ct_received_buffer1 == 10'd40) || (ct_received_buffer1 == 10'd50) 
	|| (ct_received_buffer1 == 10'd60) || (ct_received_buffer1 == 10'd70) || (ct_received_buffer1 == 10'd80) 
	|| (ct_received_buffer1 == 10'd90)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_br1 + 18)) || (ctx >= (x_br1 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
			
					
					
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd9) ||(ct_received_buffer2 == 10'd19) || (ct_received_buffer2 == 10'd29) 
	|| (ct_received_buffer2 == 10'd39) || (ct_received_buffer2 == 10'd49) || (ct_received_buffer2 == 10'd59) 
	|| (ct_received_buffer2 == 10'd69) || (ct_received_buffer2 == 10'd79) || (ct_received_buffer2 == 10'd89) 
	|| (ct_received_buffer2 == 10'd99)))
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br2 + 18)) &&  (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_br2 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd8) ||(ct_received_buffer2 == 10'd18) || (ct_received_buffer2 == 10'd28) 
	|| (ct_received_buffer2 == 10'd38) || (ct_received_buffer2 == 10'd48) || (ct_received_buffer2 == 10'd58) 
	|| (ct_received_buffer2 == 10'd68) || (ct_received_buffer2 == 10'd78) || (ct_received_buffer2 == 10'd88) 
	|| (ct_received_buffer2 == 10'd98)))
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_br2 + 18)) 																										// dikey sol
			|| (ctx >= (x_br2 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd7) ||(ct_received_buffer2 == 10'd17) || (ct_received_buffer2 == 10'd27) 
	|| (ct_received_buffer2 == 10'd37) || (ct_received_buffer2 == 10'd47) || (ct_received_buffer2 == 10'd57) 
	|| (ct_received_buffer2 == 10'd67) || (ct_received_buffer2 == 10'd77) || (ct_received_buffer2 == 10'd87) 
	|| (ct_received_buffer2 == 10'd97))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_br2 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd6) ||(ct_received_buffer2 == 10'd16) || (ct_received_buffer2 == 10'd26) 
	|| (ct_received_buffer2 == 10'd36) || (ct_received_buffer2 == 10'd46) || (ct_received_buffer2 == 10'd56) 
	|| (ct_received_buffer2 == 10'd66) || (ct_received_buffer2 == 10'd76) || (ct_received_buffer2 == 10'd86) 
	|| (ct_received_buffer2 == 10'd96))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_br2 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br2 + 24)) && (cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd5) ||(ct_received_buffer2 == 10'd15) || (ct_received_buffer2 == 10'd25) 
	|| (ct_received_buffer2 == 10'd35) || (ct_received_buffer2 == 10'd45) || (ct_received_buffer2 == 10'd55) 
	|| (ct_received_buffer2 == 10'd65) || (ct_received_buffer2 == 10'd75) || (ct_received_buffer2 == 10'd85) 
	|| (ct_received_buffer2 == 10'd95)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br2 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_br2 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd4) ||(ct_received_buffer2 == 10'd14) || (ct_received_buffer2 == 10'd24) 
	|| (ct_received_buffer2 == 10'd34) || (ct_received_buffer2 == 10'd44) || (ct_received_buffer2 == 10'd54) 
	|| (ct_received_buffer2 == 10'd64) || (ct_received_buffer2 == 10'd74) || (ct_received_buffer2 == 10'd84) 
	|| (ct_received_buffer2 == 10'd94)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_br2 + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_br2 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd3) ||(ct_received_buffer2 == 10'd13) || (ct_received_buffer2 == 10'd23) 
	|| (ct_received_buffer2 == 10'd33) || (ct_received_buffer2 == 10'd43) || (ct_received_buffer2 == 10'd53) 
	|| (ct_received_buffer2 == 10'd63) || (ct_received_buffer2 == 10'd73) || (ct_received_buffer2 == 10'd83) 
	|| (ct_received_buffer2 == 10'd93)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_br2 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd2) ||(ct_received_buffer2 == 10'd12) || (ct_received_buffer2 == 10'd22) 
	|| (ct_received_buffer2 == 10'd32) || (ct_received_buffer2 == 10'd42) || (ct_received_buffer2 == 10'd52) 
	|| (ct_received_buffer2 == 10'd62) || (ct_received_buffer2 == 10'd72) || (ct_received_buffer2 == 10'd82) 
	|| (ct_received_buffer2 == 10'd92)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_br2 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_br2 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd1) ||(ct_received_buffer2 == 10'd11) || (ct_received_buffer2 == 10'd21) 
	|| (ct_received_buffer2 == 10'd31) || (ct_received_buffer2 == 10'd41) || (ct_received_buffer2 == 10'd51) 
	|| (ct_received_buffer2 == 10'd61) || (ct_received_buffer2 == 10'd71) || (ct_received_buffer2 == 10'd81) 
	|| (ct_received_buffer2 == 10'd91)) )
	begin
		if ((((ctx < (x_br2 + 22)) && (ctx >= (x_br2 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer2 == 10'd0) ||(ct_received_buffer2 == 10'd10) || (ct_received_buffer2 == 10'd20) 
	|| (ct_received_buffer2 == 10'd30) || (ct_received_buffer2 == 10'd40) || (ct_received_buffer2 == 10'd50) 
	|| (ct_received_buffer2 == 10'd60) || (ct_received_buffer2 == 10'd70) || (ct_received_buffer2 == 10'd80) 
	|| (ct_received_buffer2 == 10'd90)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_br2 + 18)) || (ctx >= (x_br2 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////



///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd9) ||(ct_received_buffer3 == 10'd19) || (ct_received_buffer3 == 10'd29) 
	|| (ct_received_buffer3 == 10'd39) || (ct_received_buffer3 == 10'd49) || (ct_received_buffer3 == 10'd59) 
	|| (ct_received_buffer3 == 10'd69) || (ct_received_buffer3 == 10'd79) || (ct_received_buffer3 == 10'd89) 
	|| (ct_received_buffer3 == 10'd99)))
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br3 + 18)) &&  (cty < (y_r + 23)))																		// dikey sol
				|| (ctx >= (x_br3 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd8) ||(ct_received_buffer3 == 10'd18) || (ct_received_buffer3 == 10'd28) 
	|| (ct_received_buffer3 == 10'd38) || (ct_received_buffer3 == 10'd48) || (ct_received_buffer3 == 10'd58) 
	|| (ct_received_buffer3 == 10'd68) || (ct_received_buffer3 == 10'd78) || (ct_received_buffer3 == 10'd88) 
	|| (ct_received_buffer3 == 10'd98)))
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_br3 + 18)) 																										// dikey sol
			|| (ctx >= (x_br3 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd7) ||(ct_received_buffer3 == 10'd17) || (ct_received_buffer3 == 10'd27) 
	|| (ct_received_buffer3 == 10'd37) || (ct_received_buffer3 == 10'd47) || (ct_received_buffer3 == 10'd57) 
	|| (ct_received_buffer3 == 10'd67) || (ct_received_buffer3 == 10'd77) || (ct_received_buffer3 == 10'd87) 
	|| (ct_received_buffer3 == 10'd97))) 
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_br3 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd6) ||(ct_received_buffer3 == 10'd16) || (ct_received_buffer3 == 10'd26) 
	|| (ct_received_buffer3 == 10'd36) || (ct_received_buffer3 == 10'd46) || (ct_received_buffer3 == 10'd56) 
	|| (ct_received_buffer3 == 10'd66) || (ct_received_buffer3 == 10'd76) || (ct_received_buffer3 == 10'd86) 
	|| (ct_received_buffer3 == 10'd96)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_br3 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br3 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd5) ||(ct_received_buffer3 == 10'd15) || (ct_received_buffer3 == 10'd25) 
	|| (ct_received_buffer3 == 10'd35) || (ct_received_buffer3 == 10'd45) || (ct_received_buffer3 == 10'd55) 
	|| (ct_received_buffer3 == 10'd65) || (ct_received_buffer3 == 10'd75) || (ct_received_buffer3 == 10'd85) 
	|| (ct_received_buffer3 == 10'd95)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br3 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_br3 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd4) ||(ct_received_buffer3 == 10'd14) || (ct_received_buffer3 == 10'd24) 
	|| (ct_received_buffer3 == 10'd34) || (ct_received_buffer3 == 10'd44) || (ct_received_buffer3 == 10'd54) 
	|| (ct_received_buffer3 == 10'd64) || (ct_received_buffer3 == 10'd74) || (ct_received_buffer3 == 10'd84) 
	|| (ct_received_buffer3 == 10'd94)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_br3 + 18)) && (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_br3 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd3) ||(ct_received_buffer3 == 10'd13) || (ct_received_buffer3 == 10'd23) 
	|| (ct_received_buffer3 == 10'd33) || (ct_received_buffer3 == 10'd43) || (ct_received_buffer3 == 10'd53) 
	|| (ct_received_buffer3 == 10'd63) || (ct_received_buffer3 == 10'd73) || (ct_received_buffer3 == 10'd83) 
	|| (ct_received_buffer3 == 10'd93)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_br3 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd2) ||(ct_received_buffer3 == 10'd12) || (ct_received_buffer3 == 10'd22) 
	|| (ct_received_buffer3 == 10'd32) || (ct_received_buffer3 == 10'd42) || (ct_received_buffer3 == 10'd52) 
	|| (ct_received_buffer3 == 10'd62) || (ct_received_buffer3 == 10'd72) || (ct_received_buffer3 == 10'd82) 
	|| (ct_received_buffer3 == 10'd92)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_br3 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_br3 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd1) ||(ct_received_buffer3 == 10'd11) || (ct_received_buffer3 == 10'd21) 
	|| (ct_received_buffer3 == 10'd31) || (ct_received_buffer3 == 10'd41) || (ct_received_buffer3 == 10'd51) 
	|| (ct_received_buffer3 == 10'd61) || (ct_received_buffer3 == 10'd71) || (ct_received_buffer3 == 10'd81) 
	|| (ct_received_buffer3 == 10'd91)) )
	begin
		if ((((ctx < (x_br3 + 22)) && (ctx >= (x_br3 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))) && ((ct_received_buffer3 == 10'd0) ||(ct_received_buffer3 == 10'd10) || (ct_received_buffer3 == 10'd20) 
	|| (ct_received_buffer3 == 10'd30) || (ct_received_buffer3 == 10'd40) || (ct_received_buffer3 == 10'd50) 
	|| (ct_received_buffer3 == 10'd60) || (ct_received_buffer3 == 10'd70) || (ct_received_buffer3 == 10'd80) 
	|| (ct_received_buffer3 == 10'd90)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_br3 + 18)) || (ctx >= (x_br3 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////




///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd9) ||(ct_received_buffer4 == 10'd19) || (ct_received_buffer4 == 10'd29) 
	|| (ct_received_buffer4 == 10'd39) || (ct_received_buffer4 == 10'd49) || (ct_received_buffer4 == 10'd59) 
	|| (ct_received_buffer4 == 10'd69) || (ct_received_buffer4 == 10'd79) || (ct_received_buffer4 == 10'd89) 
	|| (ct_received_buffer4 == 10'd99)))
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 9 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br4 + 18)) &&  (cty < (y_r + 23)))																			// dikey sol
				|| (ctx >= (x_br4 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd8) ||(ct_received_buffer4 == 10'd18) || (ct_received_buffer4 == 10'd28) 
	|| (ct_received_buffer4 == 10'd38) || (ct_received_buffer4 == 10'd48) || (ct_received_buffer4 == 10'd58) 
	|| (ct_received_buffer4 == 10'd68) || (ct_received_buffer4 == 10'd78) || (ct_received_buffer4 == 10'd88) 
	|| (ct_received_buffer4 == 10'd98)))
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 8 çiz
		&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 				// yatay
			|| (	(ctx < (x_br4 + 18)) 																										// dikey sol
			|| (ctx >= (x_br4 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd7) ||(ct_received_buffer4 == 10'd17) || (ct_received_buffer4 == 10'd27) 
	|| (ct_received_buffer4 == 10'd37) || (ct_received_buffer4 == 10'd47) || (ct_received_buffer4 == 10'd57) 
	|| (ct_received_buffer4 == 10'd67) || (ct_received_buffer4 == 10'd77) || (ct_received_buffer4 == 10'd87) 
	|| (ct_received_buffer4 == 10'd97)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 7 çiz
			&& (  (cty < (y_r + 14)) 																										// yatay
				|| (ctx >= (x_br4 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd6) ||(ct_received_buffer4 == 10'd16) || (ct_received_buffer4 == 10'd26) 
	|| (ct_received_buffer4 == 10'd36) || (ct_received_buffer4 == 10'd46) || (ct_received_buffer4 == 10'd56) 
	|| (ct_received_buffer4 == 10'd66) || (ct_received_buffer4 == 10'd76) || (ct_received_buffer4 == 10'd86) 
	|| (ct_received_buffer4 == 10'd96)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 6 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	(ctx < (x_br4 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br4 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd5) ||(ct_received_buffer4 == 10'd15) || (ct_received_buffer4 == 10'd25) 
	|| (ct_received_buffer4 == 10'd35) || (ct_received_buffer4 == 10'd45) || (ct_received_buffer4 == 10'd55) 
	|| (ct_received_buffer4 == 10'd65) || (ct_received_buffer4 == 10'd75) || (ct_received_buffer4 == 10'd85) 
	|| (ct_received_buffer4 == 10'd95)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 5 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) 			// yatay
				|| (	((ctx < (x_br4 + 18)) && (cty < (y_r + 23)))																		// dikey sol
				|| ((ctx >= (x_br4 + 24)) &&(cty >= (y_r + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd4) ||(ct_received_buffer4 == 10'd14) || (ct_received_buffer4 == 10'd24) 
	|| (ct_received_buffer4 == 10'd34) || (ct_received_buffer4 == 10'd44) || (ct_received_buffer4 == 10'd54) 
	|| (ct_received_buffer4 == 10'd64) || (ct_received_buffer4 == 10'd74) || (ct_received_buffer4 == 10'd84) 
	|| (ct_received_buffer4 == 10'd94)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))       		// 4 çiz
			&& ( ((cty < (y_r + 23)) && (cty >= (y_r + 21)))																			// yatay
				|| (	((ctx < (x_br4 + 18)) && (cty < (y_r + 23)))																				// dikey sol
				|| (ctx >= (x_br4 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd3) ||(ct_received_buffer4 == 10'd13) || (ct_received_buffer4 == 10'd23) 
	|| (ct_received_buffer4 == 10'd33) || (ct_received_buffer4 == 10'd43) || (ct_received_buffer4 == 10'd53) 
	|| (ct_received_buffer4 == 10'd63) || (ct_received_buffer4 == 10'd73) || (ct_received_buffer4 == 10'd83) 
	|| (ct_received_buffer4 == 10'd93)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 3 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 23)) && (cty >= (y_r + 21))) ) 						// yatay
			|| (ctx >= (x_br4 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd2) ||(ct_received_buffer4 == 10'd12) || (ct_received_buffer4 == 10'd22) 
	|| (ct_received_buffer4 == 10'd32) || (ct_received_buffer4 == 10'd42) || (ct_received_buffer4 == 10'd52) 
	|| (ct_received_buffer4 == 10'd62) || (ct_received_buffer4 == 10'd72) || (ct_received_buffer4 == 10'd82) 
	|| (ct_received_buffer4 == 10'd92)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  		// 2 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30)) || ((cty < (y_r + 24)) && (cty >= (y_r + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_r + 24)) && (ctx >= (x_br4 + 24))) || (((cty >= (y_r + 22))) && (ctx < (x_br4 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd1) ||(ct_received_buffer4 == 10'd11) || (ct_received_buffer4 == 10'd21) 
	|| (ct_received_buffer4 == 10'd31) || (ct_received_buffer4 == 10'd41) || (ct_received_buffer4 == 10'd51) 
	|| (ct_received_buffer4 == 10'd61) || (ct_received_buffer4 == 10'd71) || (ct_received_buffer4 == 10'd81) 
	|| (ct_received_buffer4 == 10'd91)) )
	begin
		if ((((ctx < (x_br4 + 22)) && (ctx >= (x_br4 + 20))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))
&& ((ct_received_buffer4 == 10'd0) ||(ct_received_buffer4 == 10'd10) || (ct_received_buffer4 == 10'd20) 
	|| (ct_received_buffer4 == 10'd30) || (ct_received_buffer4 == 10'd40) || (ct_received_buffer4 == 10'd50) 
	|| (ct_received_buffer4 == 10'd60) || (ct_received_buffer4 == 10'd70) || (ct_received_buffer4 == 10'd80) 
	|| (ct_received_buffer4 == 10'd90)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_r + 32)) && (cty >= (y_r + 12))))                  			// 0 çiz
			&& (  ((cty < (y_r + 14)) || (cty >= (y_r + 30))) 																						// yatay
				|| ((ctx < (x_br4 + 18)) || (ctx >= (x_br4 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
/////////////////////////////////////////////////////////////////////////////////////////// received sonu
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
	

	
				
			///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd9) ||(ct_transmitted_buffer1 == 10'd19) || (ct_transmitted_buffer1 == 10'd29) 
	|| (ct_transmitted_buffer1 == 10'd39) || (ct_transmitted_buffer1 == 10'd49) || (ct_transmitted_buffer1 == 10'd59) 
	|| (ct_transmitted_buffer1 == 10'd69) || (ct_transmitted_buffer1 == 10'd79) || (ct_transmitted_buffer1 == 10'd89) 
	|| (ct_transmitted_buffer1 == 10'd99)))
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br1 + 18)) &&  (cty < (y_t + 23)))																			// dikey sol
				|| (ctx >= (x_br1 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) && ((ct_transmitted_buffer1 == 10'd8) ||(ct_transmitted_buffer1 == 10'd18) || (ct_transmitted_buffer1 == 10'd28) 
	|| (ct_transmitted_buffer1 == 10'd38) || (ct_transmitted_buffer1 == 10'd48) || (ct_transmitted_buffer1 == 10'd58) 
	|| (ct_transmitted_buffer1 == 10'd68) || (ct_transmitted_buffer1 == 10'd78) || (ct_transmitted_buffer1 == 10'd88) 
	|| (ct_transmitted_buffer1 == 10'd98)))
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_br1 + 18)) 																										// dikey sol
			|| (ctx >= (x_br1 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd7) ||(ct_transmitted_buffer1 == 10'd17) || (ct_transmitted_buffer1 == 10'd27) 
	|| (ct_transmitted_buffer1 == 10'd37) || (ct_transmitted_buffer1 == 10'd47) || (ct_transmitted_buffer1 == 10'd57) 
	|| (ct_transmitted_buffer1 == 10'd67) || (ct_transmitted_buffer1 == 10'd77) || (ct_transmitted_buffer1 == 10'd87) 
	|| (ct_transmitted_buffer1 == 10'd97)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_br1 + 24))	)  )																							// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd6) ||(ct_transmitted_buffer1 == 10'd16) || (ct_transmitted_buffer1 == 10'd26) 
	|| (ct_transmitted_buffer1 == 10'd36) || (ct_transmitted_buffer1 == 10'd46) || (ct_transmitted_buffer1 == 10'd56) 
	|| (ct_transmitted_buffer1 == 10'd66) || (ct_transmitted_buffer1 == 10'd76) || (ct_transmitted_buffer1 == 10'd86) 
	|| (ct_transmitted_buffer1 == 10'd96))) 
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_br1 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br1 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd5) ||(ct_transmitted_buffer1 == 10'd15) || (ct_transmitted_buffer1 == 10'd25) 
	|| (ct_transmitted_buffer1 == 10'd35) || (ct_transmitted_buffer1 == 10'd45) || (ct_transmitted_buffer1 == 10'd55) 
	|| (ct_transmitted_buffer1 == 10'd65) || (ct_transmitted_buffer1 == 10'd75) || (ct_transmitted_buffer1 == 10'd85) 
	|| (ct_transmitted_buffer1 == 10'd95)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br1 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_br1 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd4) ||(ct_transmitted_buffer1 == 10'd14) || (ct_transmitted_buffer1 == 10'd24) 
	|| (ct_transmitted_buffer1 == 10'd34) || (ct_transmitted_buffer1 == 10'd44) || (ct_transmitted_buffer1 == 10'd54) 
	|| (ct_transmitted_buffer1 == 10'd64) || (ct_transmitted_buffer1 == 10'd74) || (ct_transmitted_buffer1 == 10'd84) 
	|| (ct_transmitted_buffer1 == 10'd94)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| 	((ctx < (x_br1 + 18)) && (cty < (y_t + 23)))																																					// dikey sol
				|| (ctx >= (x_br1 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd3) ||(ct_transmitted_buffer1 == 10'd13) || (ct_transmitted_buffer1 == 10'd23) 
	|| (ct_transmitted_buffer1 == 10'd33) || (ct_transmitted_buffer1 == 10'd43) || (ct_transmitted_buffer1 == 10'd53) 
	|| (ct_transmitted_buffer1 == 10'd63) || (ct_transmitted_buffer1 == 10'd73) || (ct_transmitted_buffer1 == 10'd83) 
	|| (ct_transmitted_buffer1 == 10'd93)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_br1 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd2) ||(ct_transmitted_buffer1 == 10'd12) || (ct_transmitted_buffer1 == 10'd22) 
	|| (ct_transmitted_buffer1 == 10'd32) || (ct_transmitted_buffer1 == 10'd42) || (ct_transmitted_buffer1 == 10'd52) 
	|| (ct_transmitted_buffer1 == 10'd62) || (ct_transmitted_buffer1 == 10'd72) || (ct_transmitted_buffer1 == 10'd82) 
	|| (ct_transmitted_buffer1 == 10'd92)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_br1 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_br1 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd1) ||(ct_transmitted_buffer1 == 10'd11) || (ct_transmitted_buffer1 == 10'd21) 
	|| (ct_transmitted_buffer1 == 10'd31) || (ct_transmitted_buffer1 == 10'd41) || (ct_transmitted_buffer1 == 10'd51) 
	|| (ct_transmitted_buffer1 == 10'd61) || (ct_transmitted_buffer1 == 10'd71) || (ct_transmitted_buffer1 == 10'd81) 
	|| (ct_transmitted_buffer1 == 10'd91))) 
	begin
		if ((((ctx < (x_br1 + 22)) && (ctx >= (x_br1 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12)))) &&  ((ct_transmitted_buffer1 == 10'd0) ||(ct_transmitted_buffer1 == 10'd10) || (ct_transmitted_buffer1 == 10'd20) 
	|| (ct_transmitted_buffer1 == 10'd30) || (ct_transmitted_buffer1 == 10'd40) || (ct_transmitted_buffer1 == 10'd50) 
	|| (ct_transmitted_buffer1 == 10'd60) || (ct_transmitted_buffer1 == 10'd70) || (ct_transmitted_buffer1 == 10'd80) 
	|| (ct_transmitted_buffer1 == 10'd90))) 
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_br1 + 18)) || (ctx >= (x_br1 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////


///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd9) ||(ct_transmitted_buffer2 == 10'd19) || (ct_transmitted_buffer2 == 10'd29) 
	|| (ct_transmitted_buffer2 == 10'd39) || (ct_transmitted_buffer2 == 10'd49) || (ct_transmitted_buffer2 == 10'd59) 
	|| (ct_transmitted_buffer2 == 10'd69) || (ct_transmitted_buffer2 == 10'd79) || (ct_transmitted_buffer2 == 10'd89) 
	|| (ct_transmitted_buffer2 == 10'd99)))
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br2 + 18)) &&  (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_br2 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd8) ||(ct_transmitted_buffer2 == 10'd18) || (ct_transmitted_buffer2 == 10'd28) 
	|| (ct_transmitted_buffer2 == 10'd38) || (ct_transmitted_buffer2 == 10'd48) || (ct_transmitted_buffer2 == 10'd58) 
	|| (ct_transmitted_buffer2 == 10'd68) || (ct_transmitted_buffer2 == 10'd78) || (ct_transmitted_buffer2 == 10'd88) 
	|| (ct_transmitted_buffer2 == 10'd98)))
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_br2 + 18)) 																										// dikey sol
			|| (ctx >= (x_br2 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd7) ||(ct_transmitted_buffer2 == 10'd17) || (ct_transmitted_buffer2 == 10'd27) 
	|| (ct_transmitted_buffer2 == 10'd37) || (ct_transmitted_buffer2 == 10'd47) || (ct_transmitted_buffer2 == 10'd57) 
	|| (ct_transmitted_buffer2 == 10'd67) || (ct_transmitted_buffer2 == 10'd77) || (ct_transmitted_buffer2 == 10'd87) 
	|| (ct_transmitted_buffer2 == 10'd97))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_br2 + 24))	)  )																							// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd6) ||(ct_transmitted_buffer2 == 10'd16) || (ct_transmitted_buffer2 == 10'd26) 
	|| (ct_transmitted_buffer2 == 10'd36) || (ct_transmitted_buffer2 == 10'd46) || (ct_transmitted_buffer2 == 10'd56) 
	|| (ct_transmitted_buffer2 == 10'd66) || (ct_transmitted_buffer2 == 10'd76) || (ct_transmitted_buffer2 == 10'd86) 
	|| (ct_transmitted_buffer2 == 10'd96))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_br2 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br2 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd5) ||(ct_transmitted_buffer2 == 10'd15) || (ct_transmitted_buffer2 == 10'd25) 
	|| (ct_transmitted_buffer2 == 10'd35) || (ct_transmitted_buffer2 == 10'd45) || (ct_transmitted_buffer2 == 10'd55) 
	|| (ct_transmitted_buffer2 == 10'd65) || (ct_transmitted_buffer2 == 10'd75) || (ct_transmitted_buffer2 == 10'd85) 
	|| (ct_transmitted_buffer2 == 10'd95))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br2 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_br2 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd4) ||(ct_transmitted_buffer2 == 10'd14) || (ct_transmitted_buffer2 == 10'd24) 
	|| (ct_transmitted_buffer2 == 10'd34) || (ct_transmitted_buffer2 == 10'd44) || (ct_transmitted_buffer2 == 10'd54) 
	|| (ct_transmitted_buffer2 == 10'd64) || (ct_transmitted_buffer2 == 10'd74) || (ct_transmitted_buffer2 == 10'd84) 
	|| (ct_transmitted_buffer2 == 10'd94))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| (	((ctx < (x_br2 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_br2 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd3) ||(ct_transmitted_buffer2 == 10'd13) || (ct_transmitted_buffer2 == 10'd23) 
	|| (ct_transmitted_buffer2 == 10'd33) || (ct_transmitted_buffer2 == 10'd43) || (ct_transmitted_buffer2 == 10'd53) 
	|| (ct_transmitted_buffer2 == 10'd63) || (ct_transmitted_buffer2 == 10'd73) || (ct_transmitted_buffer2 == 10'd83) 
	|| (ct_transmitted_buffer2 == 10'd93))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_br2 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd2) ||(ct_transmitted_buffer2 == 10'd12) || (ct_transmitted_buffer2 == 10'd22) 
	|| (ct_transmitted_buffer2 == 10'd32) || (ct_transmitted_buffer2 == 10'd42) || (ct_transmitted_buffer2 == 10'd52) 
	|| (ct_transmitted_buffer2 == 10'd62) || (ct_transmitted_buffer2 == 10'd72) || (ct_transmitted_buffer2 == 10'd82) 
	|| (ct_transmitted_buffer2 == 10'd92))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_br2 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_br2 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd1) ||(ct_transmitted_buffer2 == 10'd11) || (ct_transmitted_buffer2 == 10'd21) 
	|| (ct_transmitted_buffer2 == 10'd31) || (ct_transmitted_buffer2 == 10'd41) || (ct_transmitted_buffer2 == 10'd51) 
	|| (ct_transmitted_buffer2 == 10'd61) || (ct_transmitted_buffer2 == 10'd71) || (ct_transmitted_buffer2 == 10'd81) 
	|| (ct_transmitted_buffer2 == 10'd91))) 
	begin
		if ((((ctx < (x_br2 + 22)) && (ctx >= (x_br2 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (  ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer2 == 10'd0) ||(ct_transmitted_buffer2 == 10'd10) || (ct_transmitted_buffer2 == 10'd20) 
	|| (ct_transmitted_buffer2 == 10'd30) || (ct_transmitted_buffer2 == 10'd40) || (ct_transmitted_buffer2 == 10'd50) 
	|| (ct_transmitted_buffer2 == 10'd60) || (ct_transmitted_buffer2 == 10'd70) || (ct_transmitted_buffer2 == 10'd80) 
	|| (ct_transmitted_buffer2 == 10'd90))) 
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_br2 + 18)) || (ctx >= (x_br2 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////


///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&  ((ct_transmitted_buffer3 == 10'd9) ||(ct_transmitted_buffer3 == 10'd19) || (ct_transmitted_buffer3 == 10'd29) 
	|| (ct_transmitted_buffer3 == 10'd39) || (ct_transmitted_buffer3 == 10'd49) || (ct_transmitted_buffer3 == 10'd59) 
	|| (ct_transmitted_buffer3 == 10'd69) || (ct_transmitted_buffer3 == 10'd79) || (ct_transmitted_buffer3 == 10'd89) 
	|| (ct_transmitted_buffer3 == 10'd99)))
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br3 + 18)) &&  (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_br3 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd8) ||(ct_transmitted_buffer3 == 10'd18) || (ct_transmitted_buffer3 == 10'd28) 
	|| (ct_transmitted_buffer3 == 10'd38) || (ct_transmitted_buffer3 == 10'd48) || (ct_transmitted_buffer3 == 10'd58) 
	|| (ct_transmitted_buffer3 == 10'd68) || (ct_transmitted_buffer3 == 10'd78) || (ct_transmitted_buffer3 == 10'd88) 
	|| (ct_transmitted_buffer3 == 10'd98)))
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_br3 + 18)) 																										// dikey sol
			|| (ctx >= (x_br3 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd7) ||(ct_transmitted_buffer3 == 10'd17) || (ct_transmitted_buffer3 == 10'd27) 
	|| (ct_transmitted_buffer3 == 10'd37) || (ct_transmitted_buffer3 == 10'd47) || (ct_transmitted_buffer3 == 10'd57) 
	|| (ct_transmitted_buffer3 == 10'd67) || (ct_transmitted_buffer3 == 10'd77) || (ct_transmitted_buffer3 == 10'd87) 
	|| (ct_transmitted_buffer3 == 10'd97)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_br3 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd6) ||(ct_transmitted_buffer3 == 10'd16) || (ct_transmitted_buffer3 == 10'd26) 
	|| (ct_transmitted_buffer3 == 10'd36) || (ct_transmitted_buffer3 == 10'd46) || (ct_transmitted_buffer3 == 10'd56) 
	|| (ct_transmitted_buffer3 == 10'd66) || (ct_transmitted_buffer3 == 10'd76) || (ct_transmitted_buffer3 == 10'd86) 
	|| (ct_transmitted_buffer3 == 10'd96))) 
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_br3 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br3 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd5) ||(ct_transmitted_buffer3 == 10'd15) || (ct_transmitted_buffer3 == 10'd25) 
	|| (ct_transmitted_buffer3 == 10'd35) || (ct_transmitted_buffer3 == 10'd45) || (ct_transmitted_buffer3 == 10'd55) 
	|| (ct_transmitted_buffer3 == 10'd65) || (ct_transmitted_buffer3 == 10'd75) || (ct_transmitted_buffer3 == 10'd85) 
	|| (ct_transmitted_buffer3 == 10'd95))) 
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br3 + 18)) && (cty < (y_t + 23)))																	// dikey sol
				|| ((ctx >= (x_br3 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd4) ||(ct_transmitted_buffer3 == 10'd14) || (ct_transmitted_buffer3 == 10'd24) 
	|| (ct_transmitted_buffer3 == 10'd34) || (ct_transmitted_buffer3 == 10'd44) || (ct_transmitted_buffer3 == 10'd54) 
	|| (ct_transmitted_buffer3 == 10'd64) || (ct_transmitted_buffer3 == 10'd74) || (ct_transmitted_buffer3 == 10'd84) 
	|| (ct_transmitted_buffer3 == 10'd94)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| (	((ctx < (x_br3 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_br3 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd3) ||(ct_transmitted_buffer3 == 10'd13) || (ct_transmitted_buffer3 == 10'd23) 
	|| (ct_transmitted_buffer3 == 10'd33) || (ct_transmitted_buffer3 == 10'd43) || (ct_transmitted_buffer3 == 10'd53) 
	|| (ct_transmitted_buffer3 == 10'd63) || (ct_transmitted_buffer3 == 10'd73) || (ct_transmitted_buffer3 == 10'd83) 
	|| (ct_transmitted_buffer3 == 10'd93)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_br3 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd2) ||(ct_transmitted_buffer3 == 10'd12) || (ct_transmitted_buffer3 == 10'd22) 
	|| (ct_transmitted_buffer3 == 10'd32) || (ct_transmitted_buffer3 == 10'd42) || (ct_transmitted_buffer3 == 10'd52) 
	|| (ct_transmitted_buffer3 == 10'd62) || (ct_transmitted_buffer3 == 10'd72) || (ct_transmitted_buffer3 == 10'd82) 
	|| (ct_transmitted_buffer3 == 10'd92)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_br3 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_br3 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd1) ||(ct_transmitted_buffer3 == 10'd11) || (ct_transmitted_buffer3 == 10'd21) 
	|| (ct_transmitted_buffer3 == 10'd31) || (ct_transmitted_buffer3 == 10'd41) || (ct_transmitted_buffer3 == 10'd51) 
	|| (ct_transmitted_buffer3 == 10'd61) || (ct_transmitted_buffer3 == 10'd71) || (ct_transmitted_buffer3 == 10'd81) 
	|| (ct_transmitted_buffer3 == 10'd91)) )
	begin
		if ((((ctx < (x_br3 + 22)) && (ctx >= (x_br3 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer3 == 10'd0) ||(ct_transmitted_buffer3 == 10'd10) || (ct_transmitted_buffer3 == 10'd20) 
	|| (ct_transmitted_buffer3 == 10'd30) || (ct_transmitted_buffer3 == 10'd40) || (ct_transmitted_buffer3 == 10'd50) 
	|| (ct_transmitted_buffer3 == 10'd60) || (ct_transmitted_buffer3 == 10'd70) || (ct_transmitted_buffer3 == 10'd80) 
	|| (ct_transmitted_buffer3 == 10'd90)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_br3 + 18)) || (ctx >= (x_br3 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////


///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  &&  ((ct_transmitted_buffer4 == 10'd9) ||(ct_transmitted_buffer4 == 10'd19) || (ct_transmitted_buffer4 == 10'd29) 
	|| (ct_transmitted_buffer4 == 10'd39) || (ct_transmitted_buffer4 == 10'd49) || (ct_transmitted_buffer4 == 10'd59) 
	|| (ct_transmitted_buffer4 == 10'd69) || (ct_transmitted_buffer4 == 10'd79) || (ct_transmitted_buffer4 == 10'd89) 
	|| (ct_transmitted_buffer4 == 10'd99)))
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 9 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br4 + 18)) &&  (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_br4 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd8) ||(ct_transmitted_buffer4 == 10'd18) || (ct_transmitted_buffer4 == 10'd28) 
	|| (ct_transmitted_buffer4 == 10'd38) || (ct_transmitted_buffer4 == 10'd48) || (ct_transmitted_buffer4 == 10'd58) 
	|| (ct_transmitted_buffer4 == 10'd68) || (ct_transmitted_buffer4 == 10'd78) || (ct_transmitted_buffer4 == 10'd88) 
	|| (ct_transmitted_buffer4 == 10'd98)))
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 8 çiz
		&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 				// yatay
			|| (	(ctx < (x_br4 + 18)) 																										// dikey sol
			|| (ctx >= (x_br4 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd7) ||(ct_transmitted_buffer4 == 10'd17) || (ct_transmitted_buffer4 == 10'd27) 
	|| (ct_transmitted_buffer4 == 10'd37) || (ct_transmitted_buffer4 == 10'd47) || (ct_transmitted_buffer4 == 10'd57) 
	|| (ct_transmitted_buffer4 == 10'd67) || (ct_transmitted_buffer4 == 10'd77) || (ct_transmitted_buffer4 == 10'd87) 
	|| (ct_transmitted_buffer4 == 10'd97)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 7 çiz
			&& (  (cty < (y_t + 14)) 																										// yatay
				|| (ctx >= (x_br4 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd6) ||(ct_transmitted_buffer4 == 10'd16) || (ct_transmitted_buffer4 == 10'd26) 
	|| (ct_transmitted_buffer4 == 10'd36) || (ct_transmitted_buffer4 == 10'd46) || (ct_transmitted_buffer4 == 10'd56) 
	|| (ct_transmitted_buffer4 == 10'd66) || (ct_transmitted_buffer4 == 10'd76) || (ct_transmitted_buffer4 == 10'd86) 
	|| (ct_transmitted_buffer4 == 10'd96)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 6 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	(ctx < (x_br4 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br4 + 24)) && (cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd5) ||(ct_transmitted_buffer4 == 10'd15) || (ct_transmitted_buffer4 == 10'd25) 
	|| (ct_transmitted_buffer4 == 10'd35) || (ct_transmitted_buffer4 == 10'd45) || (ct_transmitted_buffer4 == 10'd55) 
	|| (ct_transmitted_buffer4 == 10'd65) || (ct_transmitted_buffer4 == 10'd75) || (ct_transmitted_buffer4 == 10'd85) 
	|| (ct_transmitted_buffer4 == 10'd95)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 5 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) 			// yatay
				|| (	((ctx < (x_br4 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| ((ctx >= (x_br4 + 24)) &&(cty >= (y_t + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd4) ||(ct_transmitted_buffer4 == 10'd14) || (ct_transmitted_buffer4 == 10'd24) 
	|| (ct_transmitted_buffer4 == 10'd34) || (ct_transmitted_buffer4 == 10'd44) || (ct_transmitted_buffer4 == 10'd54) 
	|| (ct_transmitted_buffer4 == 10'd64) || (ct_transmitted_buffer4 == 10'd74) || (ct_transmitted_buffer4 == 10'd84) 
	|| (ct_transmitted_buffer4 == 10'd94)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))       		// 4 çiz
			&& ( ((cty < (y_t + 23)) && (cty >= (y_t + 21)))																			// yatay
				|| (	((ctx < (x_br4 + 18)) && (cty < (y_t + 23)))																		// dikey sol
				|| (ctx >= (x_br4 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd3) ||(ct_transmitted_buffer4 == 10'd13) || (ct_transmitted_buffer4 == 10'd23) 
	|| (ct_transmitted_buffer4 == 10'd33) || (ct_transmitted_buffer4 == 10'd43) || (ct_transmitted_buffer4 == 10'd53) 
	|| (ct_transmitted_buffer4 == 10'd63) || (ct_transmitted_buffer4 == 10'd73) || (ct_transmitted_buffer4 == 10'd83) 
	|| (ct_transmitted_buffer4 == 10'd93))) 
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 3 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 23)) && (cty >= (y_t + 21))) ) 						// yatay
			|| (ctx >= (x_br4 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd2) ||(ct_transmitted_buffer4 == 10'd12) || (ct_transmitted_buffer4 == 10'd22) 
	|| (ct_transmitted_buffer4 == 10'd32) || (ct_transmitted_buffer4 == 10'd42) || (ct_transmitted_buffer4 == 10'd52) 
	|| (ct_transmitted_buffer4 == 10'd62) || (ct_transmitted_buffer4 == 10'd72) || (ct_transmitted_buffer4 == 10'd82) 
	|| (ct_transmitted_buffer4 == 10'd92)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  		// 2 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30)) || ((cty < (y_t + 24)) && (cty >= (y_t + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_t + 24)) && (ctx >= (x_br4 + 24))) || (((cty >= (y_t + 22))) && (ctx < (x_br4 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd1) ||(ct_transmitted_buffer4 == 10'd11) || (ct_transmitted_buffer4 == 10'd21) 
	|| (ct_transmitted_buffer4 == 10'd31) || (ct_transmitted_buffer4 == 10'd41) || (ct_transmitted_buffer4 == 10'd51) 
	|| (ct_transmitted_buffer4 == 10'd61) || (ct_transmitted_buffer4 == 10'd71) || (ct_transmitted_buffer4 == 10'd81) 
	|| (ct_transmitted_buffer4 == 10'd91)) )
	begin
		if ((((ctx < (x_br4 + 22)) && (ctx >= (x_br4 + 20))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_t + 32)) && (cty >= (y_t+ 12))))  && ((ct_transmitted_buffer4 == 10'd0) ||(ct_transmitted_buffer4 == 10'd10) || (ct_transmitted_buffer4 == 10'd20) 
	|| (ct_transmitted_buffer4 == 10'd30) || (ct_transmitted_buffer4 == 10'd40) || (ct_transmitted_buffer4 == 10'd50) 
	|| (ct_transmitted_buffer4 == 10'd60) || (ct_transmitted_buffer4 == 10'd70) || (ct_transmitted_buffer4 == 10'd80) 
	|| (ct_transmitted_buffer4 == 10'd90)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_t + 32)) && (cty >= (y_t + 12))))                  			// 0 çiz
			&& (  ((cty < (y_t + 14)) || (cty >= (y_t + 30))) 																						// yatay
				|| ((ctx < (x_br4 + 18)) || (ctx >= (x_br4 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////



///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&  ((ct_dropped_buffer1 == 10'd9) ||(ct_dropped_buffer1 == 10'd19) || (ct_dropped_buffer1 == 10'd29) 
	|| (ct_dropped_buffer1 == 10'd39) || (ct_dropped_buffer1 == 10'd49) || (ct_dropped_buffer1 == 10'd59) 
	|| (ct_dropped_buffer1 == 10'd69) || (ct_dropped_buffer1 == 10'd79) || (ct_dropped_buffer1 == 10'd89) 
	|| (ct_dropped_buffer1 == 10'd99)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br1 + 18)) &&  (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_br1 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd8) ||(ct_dropped_buffer1 == 10'd18) || (ct_dropped_buffer1 == 10'd28) 
	|| (ct_dropped_buffer1 == 10'd38) || (ct_dropped_buffer1 == 10'd48) || (ct_dropped_buffer1 == 10'd58) 
	|| (ct_dropped_buffer1 == 10'd68) || (ct_dropped_buffer1 == 10'd78) || (ct_dropped_buffer1 == 10'd88) 
	|| (ct_dropped_buffer1 == 10'd98)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_br1 + 18)) 																										// dikey sol
			|| (ctx >= (x_br1 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd7) ||(ct_dropped_buffer1 == 10'd17) || (ct_dropped_buffer1 == 10'd27) 
	|| (ct_dropped_buffer1 == 10'd37) || (ct_dropped_buffer1 == 10'd47) || (ct_dropped_buffer1 == 10'd57) 
	|| (ct_dropped_buffer1 == 10'd67) || (ct_dropped_buffer1 == 10'd77) || (ct_dropped_buffer1 == 10'd87) 
	|| (ct_dropped_buffer1 == 10'd97)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_br1 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd6) ||(ct_dropped_buffer1 == 10'd16) || (ct_dropped_buffer1 == 10'd26) 
	|| (ct_dropped_buffer1 == 10'd36) || (ct_dropped_buffer1 == 10'd46) || (ct_dropped_buffer1 == 10'd56) 
	|| (ct_dropped_buffer1 == 10'd66) || (ct_dropped_buffer1 == 10'd76) || (ct_dropped_buffer1 == 10'd86) 
	|| (ct_dropped_buffer1 == 10'd96)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_br1 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br1 + 24)) && (cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd5) ||(ct_dropped_buffer1 == 10'd15) || (ct_dropped_buffer1 == 10'd25) 
	|| (ct_dropped_buffer1 == 10'd35) || (ct_dropped_buffer1 == 10'd45) || (ct_dropped_buffer1 == 10'd55) 
	|| (ct_dropped_buffer1 == 10'd65) || (ct_dropped_buffer1 == 10'd75) || (ct_dropped_buffer1 == 10'd85) 
	|| (ct_dropped_buffer1 == 10'd95)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br1 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_br1 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd4) ||(ct_dropped_buffer1 == 10'd14) || (ct_dropped_buffer1 == 10'd24) 
	|| (ct_dropped_buffer1 == 10'd34) || (ct_dropped_buffer1 == 10'd44) || (ct_dropped_buffer1 == 10'd54) 
	|| (ct_dropped_buffer1 == 10'd64) || (ct_dropped_buffer1 == 10'd74) || (ct_dropped_buffer1 == 10'd84) 
	|| (ct_dropped_buffer1 == 10'd94)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_br1 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_br1 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd3) ||(ct_dropped_buffer1 == 10'd13) || (ct_dropped_buffer1 == 10'd23) 
	|| (ct_dropped_buffer1 == 10'd33) || (ct_dropped_buffer1 == 10'd43) || (ct_dropped_buffer1 == 10'd53) 
	|| (ct_dropped_buffer1 == 10'd63) || (ct_dropped_buffer1 == 10'd73) || (ct_dropped_buffer1 == 10'd83) 
	|| (ct_dropped_buffer1 == 10'd93)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_br1 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd2) ||(ct_dropped_buffer1 == 10'd12) || (ct_dropped_buffer1 == 10'd22) 
	|| (ct_dropped_buffer1 == 10'd32) || (ct_dropped_buffer1 == 10'd42) || (ct_dropped_buffer1 == 10'd52) 
	|| (ct_dropped_buffer1 == 10'd62) || (ct_dropped_buffer1 == 10'd72) || (ct_dropped_buffer1 == 10'd82) 
	|| (ct_dropped_buffer1 == 10'd92)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_br1 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_br1 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd1) ||(ct_dropped_buffer1 == 10'd11) || (ct_dropped_buffer1 == 10'd21) 
	|| (ct_dropped_buffer1 == 10'd31) || (ct_dropped_buffer1 == 10'd41) || (ct_dropped_buffer1 == 10'd51) 
	|| (ct_dropped_buffer1 == 10'd61) || (ct_dropped_buffer1 == 10'd71) || (ct_dropped_buffer1 == 10'd81) 
	|| (ct_dropped_buffer1 == 10'd91)) )
	begin
		if ((((ctx < (x_br1 + 22)) && (ctx >= (x_br1 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (  ((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer1 == 10'd0) ||(ct_dropped_buffer1 == 10'd10) || (ct_dropped_buffer1 == 10'd20) 
	|| (ct_dropped_buffer1 == 10'd30) || (ct_dropped_buffer1 == 10'd40) || (ct_dropped_buffer1 == 10'd50) 
	|| (ct_dropped_buffer1 == 10'd60) || (ct_dropped_buffer1 == 10'd70) || (ct_dropped_buffer1 == 10'd80) 
	|| (ct_dropped_buffer1 == 10'd90)) )
	begin
		if ((((ctx < (x_br1 + 26)) && (ctx >= (x_br1 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  			// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_br1 + 18)) || (ctx >= (x_br1 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////


///////////// if counter received ends with 8 ///////////// 
else if (((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12)))) && ((ct_dropped_buffer2 == 10'd9) ||(ct_dropped_buffer2 == 10'd19) || (ct_dropped_buffer2 == 10'd29) 
	|| (ct_dropped_buffer2 == 10'd39) || (ct_dropped_buffer2 == 10'd49) || (ct_dropped_buffer2 == 10'd59) 
	|| (ct_dropped_buffer2 == 10'd69) || (ct_dropped_buffer2 == 10'd79) || (ct_dropped_buffer2 == 10'd89) 
	|| (ct_dropped_buffer2 == 10'd99)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br2 + 18)) && (cty < (y_d + 23)))																			// dikey sol
				|| (ctx >= (x_br2 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd8) ||(ct_dropped_buffer2 == 10'd18) || (ct_dropped_buffer2 == 10'd28) 
	|| (ct_dropped_buffer2 == 10'd38) || (ct_dropped_buffer2 == 10'd48) || (ct_dropped_buffer2 == 10'd58) 
	|| (ct_dropped_buffer2 == 10'd68) || (ct_dropped_buffer2 == 10'd78) || (ct_dropped_buffer2 == 10'd88) 
	|| (ct_dropped_buffer2 == 10'd98)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_br2 + 18)) 																										// dikey sol
			|| (ctx >= (x_br2 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd7) ||(ct_dropped_buffer2 == 10'd17) || (ct_dropped_buffer2 == 10'd27) 
	|| (ct_dropped_buffer2 == 10'd37) || (ct_dropped_buffer2 == 10'd47) || (ct_dropped_buffer2 == 10'd57) 
	|| (ct_dropped_buffer2 == 10'd67) || (ct_dropped_buffer2 == 10'd77) || (ct_dropped_buffer2 == 10'd87) 
	|| (ct_dropped_buffer2 == 10'd97)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_br2 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd6) ||(ct_dropped_buffer2 == 10'd16) || (ct_dropped_buffer2 == 10'd26) 
	|| (ct_dropped_buffer2 == 10'd36) || (ct_dropped_buffer2 == 10'd46) || (ct_dropped_buffer2 == 10'd56) 
	|| (ct_dropped_buffer2 == 10'd66) || (ct_dropped_buffer2 == 10'd76) || (ct_dropped_buffer2 == 10'd86) 
	|| (ct_dropped_buffer2 == 10'd96)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_br2 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br2 + 24)) && (cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd5) ||(ct_dropped_buffer2 == 10'd15) || (ct_dropped_buffer2 == 10'd25) 
	|| (ct_dropped_buffer2 == 10'd35) || (ct_dropped_buffer2 == 10'd45) || (ct_dropped_buffer2 == 10'd55) 
	|| (ct_dropped_buffer2 == 10'd65) || (ct_dropped_buffer2 == 10'd75) || (ct_dropped_buffer2 == 10'd85) 
	|| (ct_dropped_buffer2 == 10'd95)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br2 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_br2 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd4) ||(ct_dropped_buffer2 == 10'd14) || (ct_dropped_buffer2 == 10'd24) 
	|| (ct_dropped_buffer2 == 10'd34) || (ct_dropped_buffer2 == 10'd44) || (ct_dropped_buffer2 == 10'd54) 
	|| (ct_dropped_buffer2 == 10'd64) || (ct_dropped_buffer2 == 10'd74) || (ct_dropped_buffer2 == 10'd84) 
	|| (ct_dropped_buffer2 == 10'd94)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_br2 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_br2 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd3) ||(ct_dropped_buffer2 == 10'd13) || (ct_dropped_buffer2 == 10'd23) 
	|| (ct_dropped_buffer2 == 10'd33) || (ct_dropped_buffer2 == 10'd43) || (ct_dropped_buffer2 == 10'd53) 
	|| (ct_dropped_buffer2 == 10'd63) || (ct_dropped_buffer2 == 10'd73) || (ct_dropped_buffer2 == 10'd83) 
	|| (ct_dropped_buffer2 == 10'd93)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_br2 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd2) ||(ct_dropped_buffer2 == 10'd12) || (ct_dropped_buffer2 == 10'd22) 
	|| (ct_dropped_buffer2 == 10'd32) || (ct_dropped_buffer2 == 10'd42) || (ct_dropped_buffer2 == 10'd52) 
	|| (ct_dropped_buffer2 == 10'd62) || (ct_dropped_buffer2 == 10'd72) || (ct_dropped_buffer2 == 10'd82) 
	|| (ct_dropped_buffer2 == 10'd92)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_br2 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_br2 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd1) ||(ct_dropped_buffer2 == 10'd11) || (ct_dropped_buffer2 == 10'd21) 
	|| (ct_dropped_buffer2 == 10'd31) || (ct_dropped_buffer2 == 10'd41) || (ct_dropped_buffer2 == 10'd51) 
	|| (ct_dropped_buffer2 == 10'd61) || (ct_dropped_buffer2 == 10'd71) || (ct_dropped_buffer2 == 10'd81) 
	|| (ct_dropped_buffer2 == 10'd91)) )
	begin
		if ((((ctx < (x_br2 + 22)) && (ctx >= (x_br2 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer2 == 10'd0) ||(ct_dropped_buffer2 == 10'd10) || (ct_dropped_buffer2 == 10'd20) 
	|| (ct_dropped_buffer2 == 10'd30) || (ct_dropped_buffer2 == 10'd40) || (ct_dropped_buffer2 == 10'd50) 
	|| (ct_dropped_buffer2 == 10'd60) || (ct_dropped_buffer2 == 10'd70) || (ct_dropped_buffer2 == 10'd80) 
	|| (ct_dropped_buffer2 == 10'd90)) )
	begin
		if ((((ctx < (x_br2 + 26)) && (ctx >= (x_br2 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  			// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_br2 + 18)) || (ctx >= (x_br2 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&  ((ct_dropped_buffer3 == 10'd9) ||(ct_dropped_buffer3 == 10'd19) || (ct_dropped_buffer3 == 10'd29) 
	|| (ct_dropped_buffer3 == 10'd39) || (ct_dropped_buffer3 == 10'd49) || (ct_dropped_buffer3 == 10'd59) 
	|| (ct_dropped_buffer3 == 10'd69) || (ct_dropped_buffer3 == 10'd79) || (ct_dropped_buffer3 == 10'd89) 
	|| (ct_dropped_buffer3 == 10'd99)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br3 + 18)) && (cty < (y_d + 23)))																			// dikey sol
				|| (ctx >= (x_br3 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd8) ||(ct_dropped_buffer3 == 10'd18) || (ct_dropped_buffer3 == 10'd28) 
	|| (ct_dropped_buffer3 == 10'd38) || (ct_dropped_buffer3 == 10'd48) || (ct_dropped_buffer3 == 10'd58) 
	|| (ct_dropped_buffer3 == 10'd68) || (ct_dropped_buffer3 == 10'd78) || (ct_dropped_buffer3 == 10'd88) 
	|| (ct_dropped_buffer3 == 10'd98)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_br3 + 18)) 																										// dikey sol
			|| (ctx >= (x_br3 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd7) ||(ct_dropped_buffer3 == 10'd17) || (ct_dropped_buffer3 == 10'd27) 
	|| (ct_dropped_buffer3 == 10'd37) || (ct_dropped_buffer3 == 10'd47) || (ct_dropped_buffer3 == 10'd57) 
	|| (ct_dropped_buffer3 == 10'd67) || (ct_dropped_buffer3 == 10'd77) || (ct_dropped_buffer3 == 10'd87) 
	|| (ct_dropped_buffer3 == 10'd97)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_br3 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd6) ||(ct_dropped_buffer3 == 10'd16) || (ct_dropped_buffer3 == 10'd26) 
	|| (ct_dropped_buffer3 == 10'd36) || (ct_dropped_buffer3 == 10'd46) || (ct_dropped_buffer3 == 10'd56) 
	|| (ct_dropped_buffer3 == 10'd66) || (ct_dropped_buffer3 == 10'd76) || (ct_dropped_buffer3 == 10'd86) 
	|| (ct_dropped_buffer3 == 10'd96)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_br3 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br3 + 24)) && (cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd5) ||(ct_dropped_buffer3 == 10'd15) || (ct_dropped_buffer3 == 10'd25) 
	|| (ct_dropped_buffer3 == 10'd35) || (ct_dropped_buffer3 == 10'd45) || (ct_dropped_buffer3 == 10'd55) 
	|| (ct_dropped_buffer3 == 10'd65) || (ct_dropped_buffer3 == 10'd75) || (ct_dropped_buffer3 == 10'd85) 
	|| (ct_dropped_buffer3 == 10'd95)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br3 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_br3 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd4) ||(ct_dropped_buffer3 == 10'd14) || (ct_dropped_buffer3 == 10'd24) 
	|| (ct_dropped_buffer3 == 10'd34) || (ct_dropped_buffer3 == 10'd44) || (ct_dropped_buffer3 == 10'd54) 
	|| (ct_dropped_buffer3 == 10'd64) || (ct_dropped_buffer3 == 10'd74) || (ct_dropped_buffer3 == 10'd84) 
	|| (ct_dropped_buffer3 == 10'd94)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_br3 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_br3 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd3) ||(ct_dropped_buffer3 == 10'd13) || (ct_dropped_buffer3 == 10'd23) 
	|| (ct_dropped_buffer3 == 10'd33) || (ct_dropped_buffer3 == 10'd43) || (ct_dropped_buffer3 == 10'd53) 
	|| (ct_dropped_buffer3 == 10'd63) || (ct_dropped_buffer3 == 10'd73) || (ct_dropped_buffer3 == 10'd83) 
	|| (ct_dropped_buffer3 == 10'd93)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_br3 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd2) ||(ct_dropped_buffer3 == 10'd12) || (ct_dropped_buffer3 == 10'd22) 
	|| (ct_dropped_buffer3 == 10'd32) || (ct_dropped_buffer3 == 10'd42) || (ct_dropped_buffer3 == 10'd52) 
	|| (ct_dropped_buffer3 == 10'd62) || (ct_dropped_buffer3 == 10'd72) || (ct_dropped_buffer3 == 10'd82) 
	|| (ct_dropped_buffer3 == 10'd92)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_br3 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_br3 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd1) ||(ct_dropped_buffer3 == 10'd11) || (ct_dropped_buffer3 == 10'd21) 
	|| (ct_dropped_buffer3 == 10'd31) || (ct_dropped_buffer3 == 10'd41) || (ct_dropped_buffer3 == 10'd51) 
	|| (ct_dropped_buffer3 == 10'd61) || (ct_dropped_buffer3 == 10'd71) || (ct_dropped_buffer3 == 10'd81) 
	|| (ct_dropped_buffer3 == 10'd91)) )
	begin
		if ((((ctx < (x_br3 + 22)) && (ctx >= (x_br3 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  		// 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if (((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer3 == 10'd0) ||(ct_dropped_buffer3 == 10'd10) || (ct_dropped_buffer3 == 10'd20) 
	|| (ct_dropped_buffer3 == 10'd30) || (ct_dropped_buffer3 == 10'd40) || (ct_dropped_buffer3 == 10'd50) 
	|| (ct_dropped_buffer3 == 10'd60) || (ct_dropped_buffer3 == 10'd70) || (ct_dropped_buffer3 == 10'd80) 
	|| (ct_dropped_buffer3 == 10'd90)) )
	begin
		if ((((ctx < (x_br3 + 26)) && (ctx >= (x_br3 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  			// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_br3 + 18)) || (ctx >= (x_br3 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////


///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  &&  ((ct_dropped_buffer4 == 10'd9) ||(ct_dropped_buffer4 == 10'd19) || (ct_dropped_buffer4 == 10'd29) 
	|| (ct_dropped_buffer4 == 10'd39) || (ct_dropped_buffer4 == 10'd49) || (ct_dropped_buffer4 == 10'd59) 
	|| (ct_dropped_buffer4 == 10'd69) || (ct_dropped_buffer4 == 10'd79) || (ct_dropped_buffer4 == 10'd89) 
	|| (ct_dropped_buffer4 == 10'd99)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 9 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br4 + 18)) && (cty < (y_d + 23)))																			// dikey sol
				|| (ctx >= (x_br4 + 24))	)  ))																								// dikey sağ																begin
			begin	
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;									
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 8 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd8) ||(ct_dropped_buffer4 == 10'd18) || (ct_dropped_buffer4 == 10'd28) 
	|| (ct_dropped_buffer4 == 10'd38) || (ct_dropped_buffer4 == 10'd48) || (ct_dropped_buffer4 == 10'd58) 
	|| (ct_dropped_buffer4 == 10'd68) || (ct_dropped_buffer4 == 10'd78) || (ct_dropped_buffer4 == 10'd88) 
	|| (ct_dropped_buffer4 == 10'd98)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 8 çiz
		&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 				// yatay
			|| (	(ctx < (x_br4 + 18)) 																										// dikey sol
			|| (ctx >= (x_br4 + 24))	)  ))																									// dikey sağ
			begin			
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end


///////////// if counter received ends with 7 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd7) ||(ct_dropped_buffer4 == 10'd17) || (ct_dropped_buffer4 == 10'd27) 
	|| (ct_dropped_buffer4 == 10'd37) || (ct_dropped_buffer4 == 10'd47) || (ct_dropped_buffer4 == 10'd57) 
	|| (ct_dropped_buffer4 == 10'd67) || (ct_dropped_buffer4 == 10'd77) || (ct_dropped_buffer4 == 10'd87) 
	|| (ct_dropped_buffer4 == 10'd97)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 7 çiz
			&& (  (cty < (y_d + 14)) 																										// yatay
				|| (ctx >= (x_br4 + 24))	)  )																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 6 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd6) ||(ct_dropped_buffer4 == 10'd16) || (ct_dropped_buffer4 == 10'd26) 
	|| (ct_dropped_buffer4 == 10'd36) || (ct_dropped_buffer4 == 10'd46) || (ct_dropped_buffer4 == 10'd56) 
	|| (ct_dropped_buffer4 == 10'd66) || (ct_dropped_buffer4 == 10'd76) || (ct_dropped_buffer4 == 10'd86) 
	|| (ct_dropped_buffer4 == 10'd96)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 6 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	(ctx < (x_br4 + 18)) 																									// dikey sol	x18
				|| ((ctx >= (x_br4 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
		end
		

///////////// if counter received ends with 5 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd5) ||(ct_dropped_buffer4 == 10'd15) || (ct_dropped_buffer4 == 10'd25) 
	|| (ct_dropped_buffer4 == 10'd35) || (ct_dropped_buffer4 == 10'd45) || (ct_dropped_buffer4 == 10'd55) 
	|| (ct_dropped_buffer4 == 10'd65) || (ct_dropped_buffer4 == 10'd75) || (ct_dropped_buffer4 == 10'd85) 
	|| (ct_dropped_buffer4 == 10'd95)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 5 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) 			// yatay
				|| (	((ctx < (x_br4 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| ((ctx >= (x_br4 + 24)) &&(cty >= (y_d + 21)))	)  ))																	// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
   end

	
///////////// if counter received ends with 4 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd4) ||(ct_dropped_buffer4 == 10'd14) || (ct_dropped_buffer4 == 10'd24) 
	|| (ct_dropped_buffer4 == 10'd34) || (ct_dropped_buffer4 == 10'd44) || (ct_dropped_buffer4 == 10'd54) 
	|| (ct_dropped_buffer4 == 10'd64) || (ct_dropped_buffer4 == 10'd74) || (ct_dropped_buffer4 == 10'd84) 
	|| (ct_dropped_buffer4 == 10'd94)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))       		// 4 çiz
			&& ( ((cty < (y_d + 23)) && (cty >= (y_d + 21)))																			// yatay
				|| (	((ctx < (x_br4 + 18)) && (cty < (y_d + 23)))																		// dikey sol
				|| (ctx >= (x_br4 + 24))	)  ))																								// dikey sağ
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

	
///////////// if counter received ends with 3 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd3) ||(ct_dropped_buffer4 == 10'd13) || (ct_dropped_buffer4 == 10'd23) 
	|| (ct_dropped_buffer4 == 10'd33) || (ct_dropped_buffer4 == 10'd43) || (ct_dropped_buffer4 == 10'd53) 
	|| (ct_dropped_buffer4 == 10'd63) || (ct_dropped_buffer4 == 10'd73) || (ct_dropped_buffer4 == 10'd83) 
	|| (ct_dropped_buffer4 == 10'd93)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 3 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 23)) && (cty >= (y_d + 21))) ) 						// yatay
			|| (ctx >= (x_br4 + 24))) )																													// dikey
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;												//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 2 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd2) ||(ct_dropped_buffer4 == 10'd12) || (ct_dropped_buffer4 == 10'd22) 
	|| (ct_dropped_buffer4 == 10'd32) || (ct_dropped_buffer4 == 10'd42) || (ct_dropped_buffer4 == 10'd52) 
	|| (ct_dropped_buffer4 == 10'd62) || (ct_dropped_buffer4 == 10'd72) || (ct_dropped_buffer4 == 10'd82) 
	|| (ct_dropped_buffer4 == 10'd92)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  		// 2 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30)) || ((cty < (y_d + 24)) && (cty >= (y_d + 22))) ) 						// yatay çizgiler
			|| (((cty < (y_d + 24)) && (ctx >= (x_br4 + 24))) || (((cty >= (y_d + 22))) && (ctx < (x_br4 + 18)))  ) ))					// dikey çizgiler
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;		//
				r_green <= 8'd255;
			end
	end
	
	
///////////// if counter received ends with 1 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd1) ||(ct_dropped_buffer4 == 10'd11) || (ct_dropped_buffer4 == 10'd21) 
	|| (ct_dropped_buffer4 == 10'd31) || (ct_dropped_buffer4 == 10'd41) || (ct_dropped_buffer4 == 10'd51) 
	|| (ct_dropped_buffer4 == 10'd61) || (ct_dropped_buffer4 == 10'd71) || (ct_dropped_buffer4 == 10'd81) 
	|| (ct_dropped_buffer4 == 10'd91)) )
	begin
		if ((((ctx < (x_br4 + 22)) && (ctx >= (x_br4 + 20))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12)))))                  // 1 çiz
			begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else 
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end

///////////// if counter received ends with 0 ///////////// 
else  if ( ((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16)) && ((cty < (y_d + 32)) && (cty >= (y_d+ 12))))  && ((ct_dropped_buffer4 == 10'd0) ||(ct_dropped_buffer4 == 10'd10) || (ct_dropped_buffer4 == 10'd20) 
	|| (ct_dropped_buffer4 == 10'd30) || (ct_dropped_buffer4 == 10'd40) || (ct_dropped_buffer4 == 10'd50) 
	|| (ct_dropped_buffer4 == 10'd60) || (ct_dropped_buffer4 == 10'd70) || (ct_dropped_buffer4 == 10'd80) 
	|| (ct_dropped_buffer4 == 10'd90)) )
	begin
		if ((((ctx < (x_br4 + 26)) && (ctx >= (x_br4 + 16))) && ((cty < (y_d + 32)) && (cty >= (y_d + 12))))                  	// 0 çiz
			&& (  ((cty < (y_d + 14)) || (cty >= (y_d + 30))) 																						// yatay
				|| ((ctx < (x_br4 + 18)) || (ctx >= (x_br4 + 24)))  ))																					// dikey
				begin
				r_red <= 8'd0;    // black
				r_blue <= 8'd0;												
				r_green <= 8'd0;
			end
		else
			begin
				r_red <= 8'd255;    // white
				r_blue <= 8'd255;	  //
				r_green <= 8'd255;
			end
	end
	



					



				
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////					
				else 
					begin
						r_red <= 8'd255;    // white
						r_blue <= 8'd255;												//
						r_green <= 8'd255;
					end

			//////////////////////////////////////////////////////////////////////////////////////				SAGDAKI YAZILAR
end   // silme bunu, crucial			
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// COUNTERLAR GÖSTERİM

			
	////////////////////////////////////////////////////////////////////////////////////// 2(150  195) y=y+30, x=x+140

			else if (cty >= 70 && cty < 115)
				begin 
					if ((((cty < 72) || (cty >= 113)) && ((ctx < 420) && (ctx >= 340))) 									////// alt - üst çizgiler
					|| (((ctx < 342) && (ctx >= 340)) || ((ctx >= 418) && (ctx < 420)))	)								////// yan çizgiler
						begin
							r_red <= 8'd0;    // black
							r_blue <= 8'd0;																// output kutu sınırlar
							r_green <= 8'd0;
						end
					else if ((((cty >= 72) && (cty < 113)) && ((ctx < 418) && (ctx >= 342)))	)
						begin
							if (readed_data[0] == 0 )
								begin
									if ((ctx < 415) && (ctx >= 395) )
										begin
											if ((((ctx < (381 + 26)) && (ctx >= (381 + 16))) && ((cty < (72 + 32)) && (cty >= (72 + 12))))                  			// 0 çiz
												&& (  ((cty < (72 + 14)) || (cty >= (72 + 30))) 																						// yatay
													|| ((ctx < (381 + 18)) || (ctx >= (381 + 24)))  ))																					// dikey
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end		
								end
							else if (readed_data[0] == 1 )
								begin
									if ((ctx < 415) && (ctx >= 395) )
										begin
											if ((((ctx < (381 + 22)) && (ctx >= (381 + 20))) && ((cty < (72 + 32)) && (cty >= (72 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end		
							if (readed_data[1] == 0 )
								begin
									if ((ctx < 395) && (ctx >= 380) )
										begin
											if ((((ctx < (366 + 26)) && (ctx >= (366 + 16))) && ((cty < (72 + 32)) && (cty >= (72 + 12))))                  			// 0 çiz
												&& (  ((cty < (72 + 14)) || (cty >= (72 + 30))) 																						// yatay
													|| ((ctx < (366 + 18)) || (ctx >= (366 + 24)))  ))																					// dikey
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end		
								end
							else if (readed_data[1] == 1 )
								begin
									if ((ctx < 395) && (ctx >= 380) )
										begin
											if ((((ctx < (366 + 22)) && (ctx >= (366 + 20))) && ((cty < (72 + 32)) && (cty >= (72 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							if (readed_data[2] == 0 )
								begin
									if ((ctx < 380) && (ctx >= 365) )
										begin
											if ((((ctx < (351 + 26)) && (ctx >= (351 + 16))) && ((cty < (72 + 32)) && (cty >= (72 + 12))))                  			// 0 çiz
												&& (  ((cty < (72 + 14)) || (cty >= (72 + 30))) 																						// yatay
													|| ((ctx < (351 + 18)) || (ctx >= (351 + 24)))  ))																					// dikey
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end		
								end
							else if (readed_data[2] == 1 )
								begin
									if ((ctx < 380) && (ctx >= 365) )
										begin
											if ((((ctx < (351 + 22)) && (ctx >= (351 + 20))) && ((cty < (72 + 32)) && (cty >= (72 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end		
								end
							if (readed_data[3] == 0 )
								begin
									if ((ctx < 365) && (ctx >= 342) )
										begin
											if ((((ctx < (336 + 26)) && (ctx >= (336 + 16))) && ((cty < (72 + 32)) && (cty >= (72 + 12))))                  			// 0 çiz
												&& (  ((cty < (72 + 14)) || (cty >= (72 + 30))) 																						// yatay
													|| ((ctx < (336 + 18)) || (ctx >= (336 + 24)))  ))																					// dikey
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							else if (readed_data[3] == 1 )
								begin
									if ((ctx < 365) && (ctx >= 342) )
										begin
											if ((((ctx < (336 + 22)) && (ctx >= (336 + 20))) && ((cty < (72 + 32)) && (cty >= (72 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end	
						end
					else if ((ctx < 342) || (ctx >= 420 && ctx < 550) || (ctx >= 770))
						begin 
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;
							r_green <= 8'd255;
						end
					else if (ctx >= 342 && ctx < 418)
						begin 
							r_red <= 8'd255;    // purple													// burası için yapılcaklar: 1. purple bul o renkte olcak(deneme yanılma ile de yapılır),
							r_blue <= 8'd255;																	// 2. readed data buraya implement edilcek  
							r_green <= 8'd0;																	// yani içine 4 bit data yazdırılcak, geri kalanı purple renk.
						end 
				end 																										
			////////////////////////////////////////////////////////////////////////////////////// 2 y=y+30, x=x+140
			
						////////////////////////////////////////////////////////////////////////////////////// 13(435  410) y=y+30, x=x+140
			else if (cty >= 435 && cty < 480)
				begin 
					if ((((cty < 437) || (cty >= 478)) && ((ctx < 420) && (ctx >= 340))) 									////// alt - üst çizgiler
					|| (((ctx < 342) && (ctx >= 340)) || ((ctx >= 418) && (ctx < 420)))	)								////// yan çizgiler
						begin
							r_red <= 8'd0;    // black
							r_blue <= 8'd0;																// output kutu sınırlar
							r_green <= 8'd0;
						end	
					else if ((((cty >= 437) && (cty < 480)) && ((ctx < 418) && (ctx >= 342)))	)
						begin
							if (temp_number[0] == 0 )
								begin
									if ((ctx < 415) && (ctx >= 395) )
										begin
											if ((((ctx < (381 + 26)) && (ctx >= (381 + 16))) && ((cty < (437 + 32)) && (cty >= (437 + 12))))                  			// 0 çiz
												&& (  ((cty < (437 + 14)) || (cty >= (437 + 30))) 																						// yatay
													|| ((ctx < (381 + 18)) || (ctx >= (381 + 24)))  ))																					// dikey
													begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
									end
								end
							else if (temp_number[0] == 1 )
								begin
									if ((ctx < 415) && (ctx >= 395) )
										begin
											if ((((ctx < (381 + 22)) && (ctx >= (381 + 20))) && ((cty < (437 + 32)) && (cty >= (437 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							if (temp_number[1] == 0 )
								begin
									if ((ctx < 395) && (ctx >= 380) )
										begin
											if ((((ctx < (366 + 26)) && (ctx >= (366 + 16))) && ((cty < (437 + 32)) && (cty >= (437 + 12))))                  			// 0 çiz
												&& (  ((cty < (437 + 14)) || (cty >= (437 + 30))) 																						// yatay
													|| ((ctx < (366 + 18)) || (ctx >= (366 + 24)))  ))																					// dikey
													begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							else if (temp_number[1] == 1 )
								begin
									if ((ctx < 395) && (ctx >= 380) )
										begin
											if ((((ctx < (366 + 22)) && (ctx >= (366 + 20))) && ((cty < (437 + 32)) && (cty >= (437 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							if (temp_number[2] == 0 )
								begin	
									if ((ctx < 380) && (ctx >= 365) )
										begin
											if ((((ctx < (351 + 26)) && (ctx >= (351 + 16))) && ((cty < (437 + 32)) && (cty >= (437 + 12))))                  			// 0 çiz
												&& (  ((cty < (437 + 14)) || (cty >= (437 + 30))) 																						// yatay
													|| ((ctx < (351 + 18)) || (ctx >= (351 + 24)))  ))																					// dikey
													begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							else if (temp_number[2] == 1 )
								begin
									if ((ctx < 380) && (ctx >= 365) )
										begin
											if ((((ctx < (351 + 22)) && (ctx >= (351 + 20))) && ((cty < (437 + 32)) && (cty >= (437 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							if (temp_number[3] == 0 )
								begin
									if ((ctx < 365) && (ctx >= 342) )
										begin
											if ((((ctx < (336 + 26)) && (ctx >= (336 + 16))) && ((cty < (437 + 32)) && (cty >= (437 + 12))))                  			// 0 çiz
												&& (  ((cty < (437 + 14)) || (cty >= (437 + 30))) 																						// yatay
													|| ((ctx < (336 + 18)) || (ctx >= (336 + 24)))  ))																					// dikey
													begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
							else if (temp_number[3] == 1 )
								begin
									if ((ctx < 365) && (ctx >= 342) )
										begin
											if ((((ctx < (336 + 22)) && (ctx >= (336 + 20))) && ((cty < (437 + 32)) && (cty >= (437 + 12)))))                  		// 1 çiz
												begin
													r_red <= 8'd0;    // black
													r_blue <= 8'd0;												
													r_green <= 8'd0;
												end
											else 
												begin
													r_red <= 8'd255;    // purple													
													r_blue <= 8'd255;																	
													r_green <= 8'd0;
												end
										end
								end
						end
					else if ((ctx < 340) || (ctx >= 420 && ctx < 550) || (ctx >= 770))
						begin 
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;
							r_green <= 8'd255;
						end 
					else if (ctx >= 342 && ctx < 418)
						begin 
							r_red <= 8'd255;    // purple													
							r_blue <= 8'd255;																	
							r_green <= 8'd0;																	// yani içine 4 bit data yazdırılcak, geri kalanı purple.
						end 
				end	
				
			////////////////////////////////////////////////////////////////////////////////////// section 13 y=y+30, x=x+140
	


	
			////////////////////////////////////////////////////////////////////////////////////// 3(195  210) , 12(360  375) y=y+30, x=x+140
			else if ((cty >= 115 && cty < 135) || (cty >= 415 && cty < 435))
				begin 
					if (ctx >= 379 && ctx < 382)
						begin
							r_red <= 8'd0;    // black														// işaret eden çizgi ya da kablo, ne dersen o
							r_blue <= 8'd0;
							r_green <= 8'd0;
						end
					else if ((cty >= 115 && cty < 135) && (ctx >= 550 && ctx < 770))
						begin
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;																	// 3 için buraya yazı implement edilcek beyaz yerine (gerekiyorsa)
							r_green <= 8'd255;										
						end
					else if ((cty >= 415 && cty < 435) && (ctx >= 550 && ctx < 770))
						begin
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;																	// 12 için buraya yazı implement edilcek beyaz yerine (gerekiyorsa)
							r_green <= 8'd255;										
						end
					else
						begin 
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;
							r_green <= 8'd255;
						end 
				end 
			////////////////////////////////////////////////////////////////////////////////////// 3,12 y=y+30, x=x+140
			
			////////////////////////////////////////////////////////////////////////////////////// 4(210  225) & 11(345  360) y=y+30, x=x+140
			else if ((cty >= 135 && cty < 155) || (cty >= 395 && cty < 415))
				begin
					if (cty >= 395 && cty < 397)								 								// 11 kutuların en alt sınırı
						begin
							if ((ctx >= 240 && ctx < 280) || (ctx >= 320 && ctx < 360) || (ctx >= 400 && ctx < 440) || (ctx >= 480 && ctx < 520))
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;																// 11 alt sınırlar
									r_green <= 8'd0;
							end
							else
								begin
									r_red <= 8'd255;    // white
									r_blue <= 8'd255;																// 11 alt sınırın dışı white
									r_green <= 8'd255;
								end
						end
					else if ((cty >= 135 && cty < 137) && (ctx >= 260 && ctx < 502))		// 4 reade bağlayan kablo
						begin 
							r_red <= 8'd0;    // black
							r_blue <= 8'd0;																// 4 reade bağlayan kablo
							r_green <= 8'd0;
						end
					else if ((cty >= 413 && cty < 415) && (ctx >= 260 && ctx < 502))		// 4 input buffer bağlayan kablo
						begin 
							r_red <= 8'd0;    // black
							r_blue <= 8'd0;																// 4 input buffer bağlayan kablo
							r_green <= 8'd0;
						end
					else if ((cty >= 135 && cty < 137) && (ctx < 270 || ctx >= 500))
						begin
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;																// 4 kablonun dışı white
							r_green <= 8'd255;
						end
					else if ((ctx < 260) || (ctx >= 262 && ctx < 340) || (ctx >= 342 && ctx < 420) || (ctx >= 422 && ctx < 500) || (ctx >= 502 && ctx < 550) || (ctx >= 770))
						begin 
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;																	// 4,11 kalan beyaz kısımlar bunlar
							r_green <= 8'd255;
						end 
					else if ((ctx >= 260 && ctx < 262) || (ctx >= 340 && ctx < 342) || (ctx >= 420 && ctx < 422) || (ctx >= 500 && ctx < 502))
						begin
							r_red <= 8'd0;    // black														// 4,11 b1,b2,b3,b4 işaret eden çizgi ya da kablo, ne dersen o
							r_blue <= 8'd0;
							r_green <= 8'd0;
						end  
					else if ((cty >= 135 && cty < 155) && (ctx >= 550 && ctx < 770))
						begin
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;																	// 4 buraya yazı implement edilcek beyaz yerine (gerekiyorsa)
							r_green <= 8'd255;										
						end
					else if ((cty >= 395 && cty < 415) && (ctx >= 550 && ctx < 770))
						begin
							r_red <= 8'd255;    // white
							r_blue <= 8'd255;																	// 11 buraya yazı implement edilcek beyaz yerine (gerekiyorsa)
							r_green <= 8'd255;										
						end	
				end 
			////////////////////////////////////////////////////////////////////////////////////// 4,11 y=y+30, x=x+140
			
			////////////////////////////////////////////////////////////////////////////////////// 5(225  245), 6(245  265), 7(265  285), 8(285  305), 9(305  325), 10(325  345) y=y+30, x=x+140
			// else if ((cty >=   && cty <  ) || (cty >=   && cty <  ))
			/* yazı için yer ayrılması gerekiyorsa 
			*/
			else if (cty >= 155 && cty < 395) 																// 5,6,7,8,9,10 all in one
				begin
					if ((cty >= 155 && cty < 157)	 || (cty >= 195 && cty < 197) || (cty >= 235 && cty < 237) || (cty >= 275 && cty < 277) || (cty >= 315 && cty < 317) || (cty >= 355 && cty < 357))		
						begin																							// üst sınırların olduğu kısımlar
							if ((ctx >= 240 && ctx < 280) || (ctx >= 320 && ctx < 360) || (ctx >= 400 && ctx < 440) || (ctx >= 480 && ctx < 520))
								begin
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;																// üst sınırlar
									r_green <= 8'd0;
								end
							else
								begin
									r_red <= 8'd255;    // white
									r_blue <= 8'd255;																// üst sınırın dışı o çizgiler white
									r_green <= 8'd255;
								end
						end
					else if ((ctx >= 240 && ctx < 280) || (ctx >= 320 && ctx < 360) || (ctx >= 400 && ctx < 440) || (ctx >= 480 && ctx < 520))
						begin																							// kutu içleri ve yan kenarları
							if ((ctx >= 240 && ctx < 242) || (ctx >= 320 && ctx < 322) || (ctx >= 400 && ctx < 402) || (ctx >= 480 && ctx < 482) || (ctx >= 278 && ctx < 280) || (ctx >= 358 && ctx < 360) || (ctx >= 438 && ctx < 440) || (ctx >= 518 && ctx < 520))   // sağlar sağdan pivot, sollar soldan pivot
								begin																					// kutuların tüm yan kenarları
									r_red <= 8'd0;    // black
									r_blue <= 8'd0;																// yan sınırlar
									r_green <= 8'd0;
								end
	////////////////////////////////////////////////////////////////////////////////////////// kutuların içleri, ayrı ayrı renkler ve ayrılması gerekiyorsa yazılar için ayrılacak yer		
							else if (ctx >= 242 && ctx < 278)														// buffer 1 kutuları
								begin			
									if (cty >= 157 && cty < 195)																					////// buffer 1 box 6 == x1y6
										begin
											if (ct1 >= 6)
												begin
													case (buffer1[5])
														0:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30))) 
																	|| ((ctx < (x_b1 + 18)) || (ctx >= (x_b1 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b1 + 24)) && (ctx >= (x_b1 + 22))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 24)) && (cty >= (y_b6 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b6 + 24)) && (ctx >= (x_b1 + 24))) || (((cty >= (y_b6 + 22))) && (ctx < (x_b1 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 23)) && (cty >= (y_b6 + 21))) ) 						// yatay
																|| (ctx >= (x_b1 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end	
										end
									else if (cty >= 197 && cty < 235)																					////// buffer 1 box 5 == x1y5
										begin
											if (ct1 >=5)
												begin
													case (buffer1[4])
														0:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30))) 
																	|| ((ctx < (x_b1 + 18)) || (ctx >= (x_b1 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b1 + 24)) && (ctx >= (x_b1 + 22))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 24)) && (cty >= (y_b5 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b5 + 24)) && (ctx >= (x_b1 + 24))) || (((cty >= (y_b5 + 22))) && (ctx < (x_b1 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 23)) && (cty >= (y_b5 + 21))) ) 						// yatay
																|| (ctx >= (x_b1 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
													endcase										
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 237 && cty < 275)																					////// buffer 1 box 4 == x1y4
										begin
											if (ct1 >=4)
												begin
													case (buffer1[3])
														0:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30))) 
																	|| ((ctx < (x_b1 + 18)) || (ctx >= (x_b1 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b1 + 24)) && (ctx >= (x_b1 + 22))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 24)) && (cty >= (y_b4 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b4 + 24)) && (ctx >= (x_b1 + 24))) || (((cty >= (y_b4 + 22))) && (ctx < (x_b1 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 23)) && (cty >= (y_b4 + 21))) ) 						// yatay
																|| (ctx >= (x_b1 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 277 && cty < 315)																					////// buffer 1 box 3 == x1y3
										begin
											if (ct1 >=3)
												begin
													case (buffer1[2])
														0:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30))) 
																	|| ((ctx < (x_b1 + 18)) || (ctx >= (x_b1 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b1 + 24)) && (ctx >= (x_b1 + 22))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 24)) && (cty >= (y_b3 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b3 + 24)) && (ctx >= (x_b1 + 24))) || (((cty >= (y_b3 + 22))) && (ctx < (x_b1 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 23)) && (cty >= (y_b3 + 21))) ) 						// yatay
																|| (ctx >= (x_b1 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 317 && cty < 355)																					////// buffer 1 box 2 == x1y2
										begin
											if (ct1 >=2) 
												begin
													case (buffer1[1])
														0:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30))) 
																	|| ((ctx < (x_b1 + 18)) || (ctx >= (x_b1 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b1 + 24)) && (ctx >= (x_b1 + 22))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 24)) && (cty >= (y_b2 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b2 + 24)) && (ctx >= (x_b1 + 24))) || (((cty >= (y_b2 + 22))) && (ctx < (x_b1 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 23)) && (cty >= (y_b2 + 21))) ) 						// yatay
																|| (ctx >= (x_b1 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 357 && cty < 395)																					////// buffer 1 box 1 == x1y1
										begin
											if (ct1 >=1)
												begin 
														begin
															case (buffer1[0])
														0:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30))) 
																	|| ((ctx < (x_b1 + 18)) || (ctx >= (x_b1 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b1 + 24)) && (ctx >= (x_b1 + 22))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 24)) && (cty >= (y_b1 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b1 + 24)) && (ctx >= (x_b1 + 24))) || (((cty >= (y_b1 + 22))) && (ctx < (x_b1 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b1 + 26)) && (ctx >= (x_b1 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 23)) && (cty >= (y_b1 + 21))) ) 						// yatay
																|| (ctx >= (x_b1 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // red
																	r_blue <= 8'd0;												//
																	r_green <= 8'd0;
																end
														end
													endcase
														end
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
								end
						//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
							else if (ctx >= 322 && ctx <=358)												// buffer 2 kutuları
								begin
									if (cty >= 157 && cty < 195)																					////// buffer 2 box 6 == x2y6
										begin
											if (ct2 >= 6)
												begin
													case (buffer2[5])
														0:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30))) 
																	|| ((ctx < (x_b2 + 18)) || (ctx >= (x_b2 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b2 + 24)) && (ctx >= (x_b2 + 22))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 24)) && (cty >= (y_b6 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b6 + 24)) && (ctx >= (x_b2 + 24))) || (((cty >= (y_b6 + 22))) && (ctx < (x_b2 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 23)) && (cty >= (y_b6 + 21))) ) 						// yatay
																|| (ctx >= (x_b2 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end	
										end
									else if (cty >= 197 && cty < 235)																					////// buffer 2 box 5 == x2y5
										begin
											if (ct2 >= 5)
												begin
													case (buffer2[4])
														0:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30))) 
																	|| ((ctx < (x_b2 + 18)) || (ctx >= (x_b2 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b2 + 24)) && (ctx >= (x_b2 + 22))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 24)) && (cty >= (y_b5 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b5 + 24)) && (ctx >= (x_b2 + 24))) || (((cty >= (y_b5 + 22))) && (ctx < (x_b2 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 23)) && (cty >= (y_b5 + 21))) ) 						// yatay
																|| (ctx >= (x_b2 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
													endcase										
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 237 && cty < 275)																					////// buffer 2 box 4 == x2y4
										begin
											if (ct2 >= 4)
												begin
													case (buffer2[3])
														0:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30))) 
																	|| ((ctx < (x_b2 + 18)) || (ctx >= (x_b2 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b2 + 24)) && (ctx >= (x_b2 + 22))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 24)) && (cty >= (y_b4 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b4 + 24)) && (ctx >= (x_b2 + 24))) || (((cty >= (y_b4 + 22))) && (ctx < (x_b2 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 23)) && (cty >= (y_b4 + 21))) ) 						// yatay
																|| (ctx >= (x_b2 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 277 && cty < 315)																					////// buffer 2 box 3 == x2y3
										begin
											if (ct2 >= 3)
												begin
													case (buffer2[2])
														0:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30))) 
																	|| ((ctx < (x_b2 + 18)) || (ctx >= (x_b2 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b2 + 24)) && (ctx >= (x_b2 + 22))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 24)) && (cty >= (y_b3 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b3 + 24)) && (ctx >= (x_b2 + 24))) || (((cty >= (y_b3 + 22))) && (ctx < (x_b2 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 23)) && (cty >= (y_b3 + 21))) ) 						// yatay
																|| (ctx >= (x_b2 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 317 && cty < 355)																					////// buffer 2 box 2 == x2y2
										begin
											if (ct2 >= 2) 
												begin
													case (buffer2[1])
														0:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30))) 
																	|| ((ctx < (x_b2 + 18)) || (ctx >= (x_b2 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b2 + 24)) && (ctx >= (x_b2 + 22))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 24)) && (cty >= (y_b2 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b2 + 24)) && (ctx >= (x_b2 + 24))) || (((cty >= (y_b2 + 22))) && (ctx < (x_b2 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 23)) && (cty >= (y_b2 + 21))) ) 						// yatay
																|| (ctx >= (x_b2 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 357 && cty < 395)																					////// buffer 2 box 1 == x2y1
										begin
											if (ct2 >= 1)
												begin 
														begin
															case (buffer2[0])
														0:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30))) 
																	|| ((ctx < (x_b2 + 18)) || (ctx >= (x_b2 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														1:
														begin
															if ((((ctx < (x_b2 + 24)) && (ctx >= (x_b2 + 22))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														2:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 24)) && (cty >= (y_b1 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b1 + 24)) && (ctx >= (x_b2 + 24))) || (((cty >= (y_b1 + 22))) && (ctx < (x_b2 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
														3:
														begin
															if ((((ctx < (x_b2 + 26)) && (ctx >= (x_b2 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 23)) && (cty >= (y_b1 + 21))) ) 						// yatay
																|| (ctx >= (x_b2 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // blue
																	r_blue <= 8'd255;												//
																	r_green <= 8'd0;
																end
														end
													endcase
														end
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
								end
							//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
							else if (ctx >= 402 && ctx < 438)												// buffer 3 kutuları
								begin
									if (cty >= 157 && cty < 195)																					////// buffer 3 box 6 == x2y6
										begin
											if (ct3 >= 6)
												begin
													case (buffer3[5])
														0:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30))) 
																	|| ((ctx < (x_b3 + 18)) || (ctx >= (x_b3 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b3 + 24)) && (ctx >= (x_b3 + 22))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 24)) && (cty >= (y_b6 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b6 + 24)) && (ctx >= (x_b3 + 24))) || (((cty >= (y_b6 + 22))) && (ctx < (x_b3 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 23)) && (cty >= (y_b6 + 21))) ) 						// yatay
																|| (ctx >= (x_b3 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end	
										end
									else if (cty >= 197 && cty < 235)																					////// buffer 3 box 5 == x2y5
										begin
											if (ct3 >=5)
												begin
													case (buffer3[4])
														0:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30))) 
																	|| ((ctx < (x_b3 + 18)) || (ctx >= (x_b3 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b3 + 24)) && (ctx >= (x_b3 + 22))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 24)) && (cty >= (y_b5 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b5 + 24)) && (ctx >= (x_b3 + 24))) || (((cty >= (y_b5 + 22))) && (ctx < (x_b3 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 23)) && (cty >= (y_b5 + 21))) ) 						// yatay
																|| (ctx >= (x_b3 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase										
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 237 && cty < 275)																					////// buffer 3 box 4 == x2y4
										begin
											if (ct3 >=4)
												begin
													case (buffer3[3])
														0:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30))) 
																	|| ((ctx < (x_b3 + 18)) || (ctx >= (x_b3 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b3 + 24)) && (ctx >= (x_b3 + 22))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 24)) && (cty >= (y_b4 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b4 + 24)) && (ctx >= (x_b3 + 24))) || (((cty >= (y_b4 + 22))) && (ctx < (x_b3 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 23)) && (cty >= (y_b4 + 21))) ) 						// yatay
																|| (ctx >= (x_b3 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 277 && cty < 315)																					////// buffer 3 box 3 == x2y3
										begin
											if (ct3 >=3)
												begin
													case (buffer3[2])
														0:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30))) 
																	|| ((ctx < (x_b3 + 18)) || (ctx >= (x_b3 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b3 + 24)) && (ctx >= (x_b3 + 22))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 24)) && (cty >= (y_b3 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b3 + 24)) && (ctx >= (x_b3 + 24))) || (((cty >= (y_b3 + 22))) && (ctx < (x_b3 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 23)) && (cty >= (y_b3 + 21))) ) 						// yatay
																|| (ctx >= (x_b3 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 317 && cty < 355)																					////// buffer 3 box 2 == x2y2
										begin
											if (ct3 >=2) 
												begin
													case (buffer3[1])
														0:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30))) 
																	|| ((ctx < (x_b3 + 18)) || (ctx >= (x_b3 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b3 + 24)) && (ctx >= (x_b3 + 22))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 24)) && (cty >= (y_b2 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b2 + 24)) && (ctx >= (x_b3 + 24))) || (((cty >= (y_b2 + 22))) && (ctx < (x_b3 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 23)) && (cty >= (y_b2 + 21))) ) 						// yatay
																|| (ctx >= (x_b3 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 357 && cty < 395)																					////// buffer 3 box 1 == x2y1
										begin
											if (ct3 >=1)
												begin 
														begin
															case (buffer3[0])
														0:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30))) 
																	|| ((ctx < (x_b3 + 18)) || (ctx >= (x_b3 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b3 + 24)) && (ctx >= (x_b3 + 22))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 24)) && (cty >= (y_b1 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b1 + 24)) && (ctx >= (x_b3 + 24))) || (((cty >= (y_b1 + 22))) && (ctx < (x_b3 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b3 + 26)) && (ctx >= (x_b3 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 23)) && (cty >= (y_b1 + 21))) ) 						// yatay
																|| (ctx >= (x_b3 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd255;    // yellow
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
														end
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
								end
						//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
							else if (ctx >= 482 && ctx < 518)												// buffer 4 kutuları
								if (cty >= 157 && cty < 195)																					////// buffer 4 box 6 == x2y6
										begin
											if (ct4 >= 6)
												begin
													case (buffer4[5])
														0:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30))) 
																	|| ((ctx < (x_b4 + 18)) || (ctx >= (x_b4 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b4 + 24)) && (ctx >= (x_b4 + 22))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 24)) && (cty >= (y_b6 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b6 + 24)) && (ctx >= (x_b4 + 24))) || (((cty >= (y_b6 + 22))) && (ctx < (x_b4 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b6 + 32)) && (cty >= (y_b6 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b6 + 14)) || (cty >= (y_b6 + 30)) || ((cty < (y_b6 + 23)) && (cty >= (y_b6 + 21))) ) 						// yatay
																|| (ctx >= (x_b4 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end	
										end
									else if (cty >= 197 && cty < 235)																					////// buffer 4 box 5 == x2y5
										begin
											if (ct4 >=5)
												begin
													case (buffer4[4])
														0:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30))) 
																	|| ((ctx < (x_b4 + 18)) || (ctx >= (x_b4 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b4 + 24)) && (ctx >= (x_b4 + 22))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 24)) && (cty >= (y_b5 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b5 + 24)) && (ctx >= (x_b4 + 24))) || (((cty >= (y_b5 + 22))) && (ctx < (x_b4 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b5 + 32)) && (cty >= (y_b5 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b5 + 14)) || (cty >= (y_b5 + 30)) || ((cty < (y_b5 + 23)) && (cty >= (y_b5 + 21))) ) 						// yatay
																|| (ctx >= (x_b4 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase										
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 237 && cty < 275)																					////// buffer 4 box 4 == x2y4
										begin
											if (ct4 >=4)
												begin
													case (buffer4[3])
														0:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30))) 
																	|| ((ctx < (x_b4 + 18)) || (ctx >= (x_b4 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b4 + 24)) && (ctx >= (x_b4 + 22))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 24)) && (cty >= (y_b4 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b4 + 24)) && (ctx >= (x_b4 + 24))) || (((cty >= (y_b4 + 22))) && (ctx < (x_b4 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b4 + 32)) && (cty >= (y_b4 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b4 + 14)) || (cty >= (y_b4 + 30)) || ((cty < (y_b4 + 23)) && (cty >= (y_b4 + 21))) ) 						// yatay
																|| (ctx >= (x_b4 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 277 && cty < 315)																					////// buffer 4 box 3 == x2y3
										begin
											if (ct4 >=3)
												begin
													case (buffer4[2])
														0:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30))) 
																	|| ((ctx < (x_b4 + 18)) || (ctx >= (x_b4 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b4 + 24)) && (ctx >= (x_b4 + 22))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 24)) && (cty >= (y_b3 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b3 + 24)) && (ctx >= (x_b4 + 24))) || (((cty >= (y_b3 + 22))) && (ctx < (x_b4 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b3 + 32)) && (cty >= (y_b3 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b3 + 14)) || (cty >= (y_b3 + 30)) || ((cty < (y_b3 + 23)) && (cty >= (y_b3 + 21))) ) 						// yatay
																|| (ctx >= (x_b4 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 317 && cty < 355)																					////// buffer 4 box 2 == x2y2
										begin
											if (ct4 >=2) 
												begin
													case (buffer4[1])
														0:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30))) 
																	|| ((ctx < (x_b4 + 18)) || (ctx >= (x_b4 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b4 + 24)) && (ctx >= (x_b4 + 22))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 24)) && (cty >= (y_b2 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b2 + 24)) && (ctx >= (x_b4 + 24))) || (((cty >= (y_b2 + 22))) && (ctx < (x_b4 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b2 + 32)) && (cty >= (y_b2 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b2 + 14)) || (cty >= (y_b2 + 30)) || ((cty < (y_b2 + 23)) && (cty >= (y_b2 + 21))) ) 						// yatay
																|| (ctx >= (x_b4 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
									else if (cty >= 357 && cty < 395)																					////// buffer 4 box 1 == x2y1
										begin
											if (ct4 >=1)
												begin 
														begin
															case (buffer4[0])
														0:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  			// 0 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30))) 
																	|| ((ctx < (x_b4 + 18)) || (ctx >= (x_b4 + 24)))  ))
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														1:
														begin
															if ((((ctx < (x_b4 + 24)) && (ctx >= (x_b4 + 22))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12)))))                  		// 1 çiz
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														2:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 2 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 24)) && (cty >= (y_b1 + 22))) ) 						// yatay çizgiler
																|| (((cty < (y_b1 + 24)) && (ctx >= (x_b4 + 24))) || (((cty >= (y_b1 + 22))) && (ctx < (x_b4 + 18)))  ) ))					// dikey çizgiler
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
														3:
														begin
															if ((((ctx < (x_b4 + 26)) && (ctx >= (x_b4 + 16))) && ((cty < (y_b1 + 32)) && (cty >= (y_b1 + 12))))                  		// 3 çiz
																&& (  ((cty < (y_b1 + 14)) || (cty >= (y_b1 + 30)) || ((cty < (y_b1 + 23)) && (cty >= (y_b1 + 21))) ) 						// yatay
																|| (ctx >= (x_b4 + 24))) )																													// dikey
																begin
																	r_red <= 8'd0;    // black
																	r_blue <= 8'd0;												
																	r_green <= 8'd0;
																end
															else 
																begin
																	r_red <= 8'd0;    // green
																	r_blue <= 8'd0;												// buraya yazı implement edilcek
																	r_green <= 8'd255;
																end
														end
													endcase
														end
												end
											else 
												begin
													r_red <= 8'd255;    // white
													r_blue <= 8'd255;																	
													r_green <= 8'd255;										
												end
										end
								end
						//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////						
						else if (ctx >= 550 && ctx < 770)
							begin
								r_red <= 8'd255;    // white
								r_blue <= 8'd255;																	// buraya yazı implement edilcek beyaz yerine (gerekiyorsa)
								r_green <= 8'd255;										
							end
						else
							begin
								r_red <= 8'd255;    // white
								r_blue <= 8'd255;																	// buraya yazı implement edilcek beyaz yerine (gerekiyorsa)
								r_green <= 8'd255;	
							end
					end 		////////////////////////////////////////////////////////////////////////////////////// [5,10]		
		end						// end  of kutular 
									// end pattern generate

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// color output assignments
	// only output the colors if the counters are within the adressable video time constraints
	assign o_red = (ctx > 144 && ctx <= 783 && cty > 35 && cty <= 514) ? r_red : 8'h0;
	assign o_blue = (ctx > 144 && ctx <= 783 && cty > 35 && cty <= 514) ? r_blue : 8'h0;
	assign o_green = (ctx > 144 && ctx <= 783 && cty > 35 && cty <= 514) ? r_green : 8'h0;
	// end color output assignments
	
endmodule  // VGA_image_gen






