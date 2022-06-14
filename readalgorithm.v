module readalgorithm (clk, clock, start, reset, button0, button1, temp_number, readd);

	input clk;
	input clock;
	input start;
	input reset;
	input button0; // input button for 4-bit binary data entrance as 0
	input button1; // input button for 4-bit binary data entrance as 1
	
	output reg [3:0] temp_number;
	output reg [3:0] readd; // output that you have read and display in your screen
	
	integer buffer_number, number_to_store, i;
	
	reg button0_is_pressed; // input buttons --> 0 (inactive, not pressed)
	reg button1_is_pressed; // input buttons --> 1 (active, pressed)

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

	reg [9:0] ct_dropped;
	reg [9:0] ct_received;
	reg [9:0] ct_transmitted;
	
	// define weights of buffers for data transfer
	reg [5:0] weight1;
	reg [5:0] weight2;
	reg [5:0] weight3;
	reg [5:0] weight4;

	reg [3:0] nextread;


	initial begin
		ct_inp = 3'd0;
		allow_for_input = 1'd0;
		button0_is_pressed = 1'd0; // initially input button0 is inactive --> 0
		button1_is_pressed = 1'd0; // initially input button1 is inactive --> 0
		
		ct1 = 3'd0; 
		ct2 = 3'd0; 
		ct3 = 3'd0; 
		ct4 = 3'd0; 
			
		ct_dropped = 10'd0;
		ct_received = 10'd0;
		ct_transmitted = 10'd0;
		
		// weight of each buffer for data read according to counter(ct1,ct2,ct3,ct4)
		weight1 = 6'd0;
		weight2 = 6'd0;
		weight3 = 6'd0;
		weight4 = 6'd0;
	end


/*

1-reset your temprorary input number under reset section 			--> temp_number <= 4'd0;
2-put a section to your part --> if you enter less than 3 number  --> how to behave to it
3-check ct_transmitted / works properly ? 
4-if I enter 3 bit or less number - keep ct_transmitted in case of 3 or less bit data entrance

5- check last part of mehmet input process
6- check slicing algorithm
7- nextread[1:0] <= [1:0] buffer4[ct3-1];             // [1:0] bunu denemeli, çalışıyorsa böyle yazılabilir, yoksa ya bufferları 2bit store edecek şekilde ayarlamalı ya da burda bi geçiş variableı atamalı.
*/

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
				temp_number[4'd3 - ct_inp] <= 1'd0;
				ct_transmitted <= ct_transmitted + 10'd1; 
				button0_is_pressed <= 1'd1; 
				ct_inp <= ct_inp + 3'd1;
			end 
			else if (button1 == 1'd0 && button1_is_pressed == 1'd0) begin // if button1 is pressed && previously not pressed to button1 --> increase counter
				temp_number[4'd3 - ct_inp] <= 1'd1;
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
		
		else if (ct_inp == 3'd4 && reset == 1'd1) begin // if counter reaches 4, set it to 0 again
			buffer_number <= temp_number[3:2]+1; // determine your target buffer number {1,2,3,4}
			number_to_store <= temp_number[1:0]; // get your decimal number from binary input
			case(buffer_number)
				/////////////////////// CASE1 ///////////////////////
				1:begin 
					if (ct1 <= 5) begin
						buffer1[3'd5-ct1] <= number_to_store; // start storing from index 5
						ct1 <= ct1 + 3'd1;
					end
					else if (ct1 == 6) begin
						ct1 <= 3'd6; // since 1 input comes while 6 box is full, slide one
						for(i=0; i < 5; i=i+1) begin
							buffer1[3'd5-i] <= buffer1[3'd4-i];
						end
						buffer1[3'd0] <= number_to_store;
					end
				end
				/////////////////////// CASE2 ///////////////////////
				2:begin
					if (ct2 <= 5) begin
						buffer2[3'd5-ct2] <= number_to_store;  // start storing from index 5
						ct2 <= ct2 + 3'd1;
					end
					else if (ct2 == 6) begin
						ct2 <=3'd6; // since 1 input comes while 6 box is full, slide one
						for(i=0; i < 5; i=i+1) begin
							buffer2[3'd5-i] <= buffer2[3'd4-i];
						end
						buffer2[3'd0] <= number_to_store;
					end
				end
				/////////////////////// CASE3 ///////////////////////
				3:begin
					if (ct3 <= 5) begin
						buffer3[3'd5-ct3] <= number_to_store;  // start storing from index 5
						ct3 <= ct3 + 3'd1;
					end
					else if (ct3 == 6) begin
						ct3 <= 3'd6; // since 1 input comes while 6 box is full, slide one
						for(i=0; i < 5; i=i+1) begin
							buffer3[3'd5-i] <= buffer3[3'd4-i];
						end
						buffer3[3'd0] <= number_to_store;
					end
				end
				/////////////////////// CASE4 ///////////////////////
				4:begin
					if (ct4 <= 5) begin
						buffer4[3'd5-ct4] <= number_to_store;  // start storing from index 5
						ct4 <= ct4 + 3'd1;
					end
					else if (ct4 == 6) begin
						ct4 <= 3'd6; // since 1 input comes while 6 box is full, slide one
						for(i=0; i < 5; i=i+1) begin
							buffer4[3'd5-i] <= buffer4[3'd4-i];
						end
						buffer4[3'd0] <= number_to_store;
					end
				end
			endcase
			
			
			// check below part !!!!!!!!!!!!!!!!!
			ct_inp <= 3'd0;
			allow_for_input <= 1'd0; // after reset your counter, do not allow input entrance until pressing start button
			
			
			
		end
	end
	//// Mehmet input read end ///

// buraya alternatif olarak şunu ekleyeyim, clock kullanmanın sıkıntı olacağı bir durum olursa
//diye şu da denenebilir:

/* buna 8 durumu da tanımlayıp, temporary bir önceki reg array atarsak 3 bitlik, önceki temp array ile sonraki negedge kıyaslaması ile tekrarlamaları ve kısa-uzun basmaları da counter ile 4 kez basmayı da çözebiliriz sanki. Bir de ct_inpi 2 bitten 4 ya da 5 bite çıkarmak lazım her halükarda kendini sıfırlayıp 5-6. inputu almasın diye. ( bunu senin kodu incelemeden önce yazdım, belki bunlara çözüm bulmuş da olabilirsin, aklıma gelmişken yazdım)
always @(negedge button0 or negedge button1 or negedge start) 
	begin
		if (start == 0 && button0 == 1 && button 1 == 1)
			begin
				ct_inp <= 5'd0;
			end
		else if (start == 1 && button0 == 0 && button 1 == 1)
			begin
				if(ct_inp < 4)
					begin
						temp_number[ct_inp] = 0;   // o noktadaki değer 
						ct_inp <= ct_inp + 5'd1;  // counterı bir arttır
					end	
			end
		else if (start == 1 && button0 == 1 && button 1 == 0)
			begin
				if(ct_inp < 4)
					begin
						temp_number[ct_inp] = 1;   // o noktadaki değer 
						ct_inp <= ct_inp + 5'd1;  // counterı bir arttır
					end	
			end
	
	end
*/


	











// inputu alırken ct_transmitted ı atırmayı unutma,
// inputu shift registera koyarken oranın ct'si 6 ise bi dropladık demektir, o zamaan da ct_dropped ı artırmayı unutma
// Atakan da outputu alırken aldığında ct_received ı artırmayı unutmamalı 



/* shift registerın çalışması
*/

// outputu veren algoritma kısmı:

// Ön hazırlığı, counter sayısı low endde iken Low Latency Queuing (LLQ) ve high endde iken Weighted Fair Queuing (WFQ) kullanmak adına oluşturduğumuz weight table:
// https://drive.google.com/file/d/1LQx3YkdhjFqTKIQLKil2dWDvc9J3KFp7/view?usp=sharing   burdaki gibi düzenlendi 
always @(*) begin
	case(ct1)
		3'd0: weight1<= 6'd0 ;
		3'd1: weight1<= 6'd9 ;
		3'd2: weight1<= 6'd13 ;
		3'd3: weight1<= 6'd15 ;
		3'd4: weight1<= 6'd16 ;
		3'd5: weight1<= 6'd17 ;
		3'd6: weight1<= 6'd19 ;
	endcase
	
	case(ct2)
		3'd0: weight1<= 6'd0 ;
		3'd1: weight2<= 6'd6 ;
		3'd2: weight2<= 6'd8 ;
		3'd3: weight2<= 6'd12 ;
		3'd4: weight2<= 6'd14 ;
		3'd5: weight2<= 6'd18 ;
		3'd6: weight2<= 6'd21 ;
	endcase
	
	case(ct3)
		3'd0: weight1<= 6'd0 ;
		3'd1: weight3<= 6'd3 ;
		3'd2: weight3<= 6'd5 ;
		3'd3: weight3<= 6'd7 ;
		3'd4: weight3<= 6'd11 ;
		3'd5: weight3<= 6'd19 ;
		3'd6: weight3<= 6'd23 ;
	endcase
	
	case(ct4)
		3'd0: weight1<= 6'd0 ;
		3'd1: weight4<= 6'd1 ;
		3'd2: weight4<= 6'd2 ;
		3'd3: weight4<= 6'd4 ;
		3'd4: weight4<= 6'd10 ;
		3'd5: weight4<= 6'd22 ;
		3'd6: weight4<= 6'd24 ;
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
				nextread[1:0] <= [1:0] buffer4[ct3-1];             // bunu denemeli, çalışıyorsa böyle yazılabilir, yoksa ya bufferları 2bit store edecek şekilde ayarlamalı ya da burda bi geçiş variableı atamalı.
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

// her şey hazır olduğuna göre her clock cycleda asenkron olarak hazırda tuttuğumuz nextreadi okuyalım.
always @(posedge clock) 
	begin
		readd [3:0] <= nextread [3:0];
		ct_received <= ct_received + 1;	
/*			if(nextread[1:0] == 11)
				begin
					for()
					buffer4[1] <= buffer4[2]
				end
*/
	end

endmodule





