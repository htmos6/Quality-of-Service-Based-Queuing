// nm1, nm2, nm3, nm4, nm5, nm6 will be deleted at the end
module readalgorithm (clk, clock, start, reset, button0, button1, temp_number, readed_data, nm1, nm2, nm3, nm4, nm5, nm6);

	input clk;
	input clock;
	input start;
	input reset;
	input button0; // input button for 4-bit binary data entrance as 0
	input button1; // input button for 4-bit binary data entrance as 1
	
	output reg [3:0] temp_number; // 4-bit input which iss kept temporarily in here !
	output reg [3:0] readed_data; // output that you have read and display in your screen
	output reg [3:0] nm1, nm2, nm3, nm4, nm5, nm6;
	
	reg [3:0] number_to_store; // decimal 4-bit number --> created from taken input
	
	reg button0_is_pressed; // input buttons --> 0 (inactive, not pressed)
	reg button1_is_pressed; // input buttons --> 1 (active, pressed)
	reg number_is_definite; // Is stored is definite ?

	reg allow_for_input; // this allows always block to take input until next start button pressing
	 
	reg [31:0] buffer1 [0:5]; // define buffer1
	reg [31:0] buffer2 [0:5]; // define buffer2
	reg [31:0] buffer3 [0:5]; // define buffer3
	reg [31:0] buffer4 [0:5]; // define buffer4

	reg [2:0] ct_inp; // define counter for input
	reg [2:0] ct1; // define counter 1
	reg [2:0] ct2; // define counter 2
	reg [2:0] ct3; // define counter 3
	reg [2:0] ct4; // define counter 4
	reg [2:0] i;

	reg [9:0] ct_dropped;
	reg [9:0] ct_received;
	reg [9:0] ct_transmitted;
	
	// define weights of buffers for data transfer
	reg [5:0] weight1;
	reg [5:0] weight2;
	reg [5:0] weight3;
	reg [5:0] weight4;

	reg [3:0] nextread; // data will be readed next


	initial begin
		ct_inp = 3'd0;
		allow_for_input = 1'd0;
		button0_is_pressed = 1'd0; // initially input button0 is inactive --> 0
		button1_is_pressed = 1'd0; // initially input button1 is inactive --> 0
		
		ct1 = 3'd0; 
		ct2 = 3'd0; 
		ct3 = 3'd0; 
		ct4 = 3'd0; 
		i = 3'd0;
			
		ct_dropped = 10'd0;
		ct_received = 10'd0;
		ct_transmitted = 10'd0;
		
		number_is_definite = 1'd0;
		
		// weight of each buffer for data read according to counter(ct1,ct2,ct3,ct4)
		weight1 = 6'd0;
		weight2 = 6'd0;
		weight3 = 6'd0;
		weight4 = 6'd0;
		
	end

	//// Mehmet input read ///
	always @(posedge clk) begin
	
		if (reset == 1'd0) begin // if you press to reset , turn back to initial conditions
			ct_inp <= 3'd0;
			allow_for_input <= 1'd0; // if people do not press start button --> do not allow for input entrance
			button0_is_pressed <= 1'd0; // initially input button0 is inactive --> 0
			button1_is_pressed <= 1'd0; // initially input button1 is inactive --> 0
		end
		
		if (start == 1'd0 && reset == 1'd1) begin // when people press start button, take just 4-bit until next start button.
			ct_inp <= 3'd0;
			allow_for_input <= 1'd1;
			button0_is_pressed <= 1'd0;
			button1_is_pressed <= 1'd0;
		end
		
		if (ct_inp <= 3'd3 && allow_for_input == 1'd1 && reset == 1'd1) begin
			if (button0 == 1'd0 && button0_is_pressed == 1'd0) begin // if button0 is pressed && previously not pressed to button0 --> increase counter
				temp_number[3'd3 - ct_inp] <= 1'd0;
				ct_transmitted <= ct_transmitted + 10'd1; 
				button0_is_pressed <= 1'd1; 
				ct_inp <= ct_inp + 3'd1;
			end 
			else if (button1 == 1'd0 && button1_is_pressed == 1'd0) begin // if button1 is pressed && previously not pressed to button1 --> increase counter
				temp_number[3'd3 - ct_inp] <= 1'd1;
				ct_transmitted <= ct_transmitted + 10'd1; 
				button1_is_pressed <= 1'd1;
				ct_inp <= ct_inp + 3'd1;
			end 
			else if (button0 == 1'd1 && button0_is_pressed == 1'd1) begin // if button0 is returned to 1 --> can be used as an input again
				button0_is_pressed <= 1'd0;
			end
			else if (button1 == 1'd1 && button1_is_pressed == 1'd1) begin // if button1 is returned to 1 --> can be used as an input again
				button1_is_pressed <= 1'd0;
			end
		end
		
		else if (ct_inp == 3'd4 && reset == 1'd1 && number_is_definite == 1'd0) begin
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
		
		else if (ct_inp == 3'd4 && reset == 1'd1 && number_is_definite == 1'd1) begin // if counter reaches 4, set it to 0 again
			if (temp_number[3:2] == 2'b00) begin // Store inside buffer 1
				number_is_definite = 1'd0;
				if (ct1 <= 5) begin
					buffer1[3'd5-ct1] <= number_to_store; // start storing from index 5
					ct1 <= ct1 + 3'd1;
				end
				else if (ct1 == 6) begin
					ct1 <= 3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer1[3'd5-i] <= buffer1[3'd4-i];
						end
					buffer1[3'd0] <= number_to_store;
				end
			end
			else if (temp_number[3:2] == 2'b01) begin // Store inside buffer 2
				number_is_definite = 1'd0;
				if (ct2 <= 5) begin
					buffer2[3'd5-ct2] <= number_to_store;  // start storing from index 5
					ct2 <= ct2 + 3'd1;
				end
				else if (ct2 == 6) begin
					ct2 <=3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer2[3'd5-i] <= buffer2[3'd4-i];
						end
					buffer2[3'd0] <= number_to_store;
				end
			end
			else if (temp_number[3:2] == 2'b10) begin // Store inside buffer 3
					number_is_definite = 1'd0;
					if (ct3 <= 5) begin
						buffer3[3'd5-ct3] <= number_to_store;  // start storing from index 5
						ct3 <= ct3 + 3'd1;
					end
					else if (ct3 == 6) begin
						ct3 <= 3'd6; // since 1 input comes while 6 box is full, slide one
						ct_dropped <= ct_dropped + 10'd1;
							for(i=3'd0; i < 3'd5; i=i+3'd1) begin
								buffer3[3'd5-i] <= buffer3[3'd4-i];
							end
						buffer3[3'd0] <= number_to_store;
					end
			end
			else if (temp_number[3:2] == 2'b11) begin // Store inside buffer 4
				number_is_definite = 1'd0;
				if (ct4 <= 5) begin
					buffer4[3'd5-ct4] <= number_to_store;  // start storing from index 5
					ct4 <= ct4 + 3'd1;
				end
				else if (ct4 == 6) begin
					ct4 <= 3'd6; // since 1 input comes while 6 box is full, slide one
					ct_dropped <= ct_dropped + 10'd1;
						for(i=3'd0; i < 3'd5; i=i+3'd1) begin
							buffer4[3'd5-i] <= buffer4[3'd4-i];
						end
					buffer4[3'd0] <= number_to_store;
				end
			end
			ct_inp <= 3'd0;
			allow_for_input <= 1'd0; // after reset your counter, do not allow input entrance until pressing start button
		end
	end
//// Mehmet input read end ///


/*
To Do List 
1-Do we need to reset temprorary input number under reset section --> (temp_number <= 4'd0) --> actually no ? 
2-Put a section if you enter less than 3 number  --> how to behave ? 
3-if I enter 3 bit or less number --> keep ct_transmitted same as what is as before the input
5- nextread[1:0] <= [1:0] buffer4[ct3-1];             
[1:0] bunu denemeli, çalışıyorsa böyle yazılabilir, yoksa ya bufferları 2bit store edecek şekilde ayarlamalı ya da burda bi geçiş variableı atamalı.

Priority To do List
1-How to extract next read 
2-Weight equalities is done as non-blocking inside always block. Ask Atakan.

Done List
1-İnputu alırken ct_transmitted ı atırmayı unutma, --> done
2-İnputu shift registera koyarken oranın ct'si 6 ise bi dropladık demektir, o zamaan da ct_dropped ı artırmayı unutma --> done
*/


/*
	Atakan da outputu alırken aldığında ct_received ı artırmayı unutmamalı 
	shift registerın çalışması
	Ön hazırlığı, counter sayısı low endde iken Low Latency Queuing (LLQ) ve high endde iken Weighted Fair Queuing (WFQ) kullanmak adına oluşturduğumuz weight table:
	https://drive.google.com/file/d/1LQx3YkdhjFqTKIQLKil2dWDvc9J3KFp7/view?usp=sharing   burdaki gibi düzenlendi 
*/

always @(*) begin
	case(ct1)
		3'd0: weight1<= 6'd0;
		3'd1: weight1<= 6'd9;
		3'd2: weight1<= 6'd13;
		3'd3: weight1<= 6'd15;
		3'd4: weight1<= 6'd16;
		3'd5: weight1<= 6'd17;
		3'd6: weight1<= 6'd19;
	endcase
	
	case(ct2)
		3'd0: weight1<= 6'd0;
		3'd1: weight2<= 6'd6;
		3'd2: weight2<= 6'd8;
		3'd3: weight2<= 6'd12;
		3'd4: weight2<= 6'd14;
		3'd5: weight2<= 6'd18;
		3'd6: weight2<= 6'd21;
	endcase
	
	case(ct3)
		3'd0: weight1<= 6'd0;
		3'd1: weight3<= 6'd3;
		3'd2: weight3<= 6'd5;
		3'd3: weight3<= 6'd7;
		3'd4: weight3<= 6'd11;
		3'd5: weight3<= 6'd19;
		3'd6: weight3<= 6'd23;
	endcase
	
	case(ct4)
		3'd0: weight1<= 6'd0;
		3'd1: weight4<= 6'd1;
		3'd2: weight4<= 6'd2;
		3'd3: weight4<= 6'd4;
		3'd4: weight4<= 6'd10;
		3'd5: weight4<= 6'd22;
		3'd6: weight4<= 6'd24;
	endcase
	
	if (ct3 == 3'd5 && ct1==3'd6) begin
		if (ct2<3'd5) 
			begin
				weight1 <= 6'd20;
			end
		else 
			begin
				weight3 <= 6'd20;
			end
	end
end


always @(*) 
	begin
		if (weight4 > weight3 && weight4 > weight2 && weight4 > weight1) 
			begin
				nextread[3:2] <= 2'b11;
				nextread[1:0] <= buffer4[ct4-1];					/// bura kontrol edilcek 3:2 yazıldığından doğru mu yazcak ters mi diye 
			end
		
		else if (weight3 > weight4 && weight3 > weight2 && weight3 > weight1) 
			begin
				nextread[3:2] <= 2'b10;
				nextread[1:0] <= buffer4[ct3-1];             // bunu denemeli, çalışıyorsa böyle yazılabilir, yoksa ya bufferları 2bit store edecek şekilde ayarlamalı ya da burda bi geçiş variableı atamalı.
			end
		
		else if (weight2 > weight4 && weight2 > weight3 && weight2 > weight1) 
			begin
				nextread[3:2] <= 2'b01;
				nextread[1:0] <= buffer4[ct2-1];
			end
			
		else if (weight1 > weight4 && weight1 > weight3 && weight1 > weight2) 
			begin
				nextread[3:2] <= 2'b00;
				nextread[1:0] <= buffer4[ct1-1];
			end	
		else if (weight1 == weight2 && weight2 == weight3 && weight3 == weight4)
			begin
				nextread[3:0] <= 4'd0;
			end
		else if (ct1 == 3'd0 && ct2 == 3'd0 && ct3 == 3'd0 && ct4 == 3'd0)			// bu kısım gereksiz olabilir ama ne olur ne olmaz dursun
			begin
				nextread[3:0] <= 4'd0;																// sıfırlama kararını uyguladık burda, inputumuz olmadan almak isterse sonradan hata da tanımlayabiliriz. Mesela outputu 4 bit yerine 5 bit alıp son bit 1 ise hata göster, 0 ise sıkıntı yok gibi belki.
			end
	end

	
	
always @(posedge clock) // Every clock cycle read data wherewe keep inside the nextread register
	begin
		readed_data [3:0] <= nextread [3:0];
		ct_received <= ct_received + 1;	
//		if(nextread[1:0] == 11) begin
//				for() begin
//					buffer4[1] <= buffer4[2]
//				end
// 	end
	end

	
// Check that you shift your output
always @(*) begin
	nm1 = buffer1[5];
	nm2 = buffer1[4];
	nm3 = buffer1[3];
	nm4 = buffer1[2];
	nm5 = buffer1[1];
	nm6 = buffer1[0];
end
// Check that you shift your output
endmodule
