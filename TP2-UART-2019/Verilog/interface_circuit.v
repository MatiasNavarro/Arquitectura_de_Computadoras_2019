`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2019 14:30:10
// Design Name: 
// Module Name: interface_circuit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module interface_circuit
#(
	parameter LEN_DATA = 8 // # buffer bits 
) 
( 
	input i_clk,
 	input reset,
 	//Rx
 	input rx_done_tick,
 	input [LEN_DATA-1:0] rx_data_in,
 	input [LEN_DATA-1:0] alu_data_in,
    //Tx
 	output reg tx_start,
	output reg [LEN_DATA-1 : 0] i_data_a,
	output reg [LEN_DATA-1 : 0] i_data_b,
	output reg [5 : 0] i_operation,
 	output [LEN_DATA-1:0] data_out 
); 
	reg [1 : 0] counter_in = 2'b 00;
	
	assign data_out = alu_data_in;
	
	always @(posedge i_clk , posedge reset) 
	begin
		if (reset) 
			begin 
				i_data_a    = 0;
				i_data_b    = 0;
				i_operation = 0;
				counter_in  = 0;
				tx_start    = 1'b 0;	
				// data_out = 0;		
			end 
		
		else
			begin		 	
				if (rx_done_tick) 
					begin
						case (counter_in)
							2'b 00: i_data_a     = rx_data_in;
							2'b 01: i_data_b     = rx_data_in;
							2'b 10: i_operation  = rx_data_in;
						endcase		
						counter_in = counter_in + 1'b 1;		
					end
			
				if (counter_in == 2'b 11)
					begin
						counter_in = 0;
						// data_out = alu_data_in; 			
						tx_start = 1'b 1;
					end
				else
					begin
						tx_start = 1'b 0;				
					end		
			end 
    end
endmodule
