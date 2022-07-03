`timescale 1 ns / 1 ps  //all run instances are taken as in nanoseconds, simulation precision is 1 ps

module test_bench_read_algorithm (next_read, readed_data, time_to_read, counter_read, buffer1_12bit, buffer2_12bit, buffer3_12bit,  buffer4_12bit);


	
	output [3:0] next_read; // data will be readed next
	output [3:0] readed_data; // output that you have read and display in your screen
	
	output time_to_read;
	output [28:0] counter_read;
	
	output [11:0] buffer1_12bit;
	output [11:0] buffer2_12bit;
	output [11:0] buffer3_12bit;
	output [11:0] buffer4_12bit;
	
	reg clk;
	reg start;
	reg reset;
	reg button0; // input button for 4-bit binary data entrance as 0
	reg button1; // input button for 4-bit binary data entrance as 1
	
	
	readalgorithm DUT (.clk(clk), .start(start), .reset(reset), .button0(button0), .button1(button1), .readed_data(readed_data), 
							 .number_to_store(number_to_store), .next_read(next_read), .time_to_read(), .buffer1_12bit(buffer1_12bit),
							 .buffer2_12bit(buffer2_12bit), .buffer3_12bit(buffer3_12bit), .buffer4_12bit(buffer4_12bit));
	
	
	initial 
		begin
			reset <= 1'b1;
			start <= 1'b1;
			button0 <= 1'b1;
			button1 <= 1'b1;
		end
	
	always  //clock generator
		begin
			clk <= 0;
			#0.5; //15 ns delay
			clk <= 1;
			#0.5; //15 ns delay and go back to clock = 0 state
		end
	
	always 
		begin
			
			#50;	
			start = 1'b0;
			#50;
			start = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			button1 = 1'b0;
			#50;
			button1 = 1'b1;
			#50;
			
			button1 = 1'b0;
			#50;
			button1 = 1'b1;
			#50;
			
			
			
			
			
			
			start = 1'b0;
			#50;
			start = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			button1 = 1'b0;
			#50;
			button1 = 1'b1;
			#50;
			
			
			
			start = 1'b0;
			#50;
			start = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			button1 = 1'b0;
			#50;
			button1 = 1'b1;
			#50;
			
			button0 = 1'b0;
			#50;
			button0 = 1'b1;
			#50;
			
			
			
			#5000000; //30 ns for stability again (not necessary)
		
		end
	
endmodule
