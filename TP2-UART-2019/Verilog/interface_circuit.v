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
	parameter  DBIT  = 8,  // # buffer bits
	           NB_OP = 6   // Operation bits
	            
) 
(   //INPUT
	input                     i_clk,
 	input                     i_reset,
 	input                     rx_done_tick,
 	input      [DBIT-1:0]     rx_data_in,
 	input      [DBIT-1:0]     alu_data_in,
    //OUTPUT
 	output reg                tx_start,
	output reg [DBIT-1 : 0]   data_a,
	output reg [DBIT-1 : 0]   data_b,
	output reg [NB_OP-1 : 0]  operation,
 	output     [DBIT-1:0]     data_out 
); 
	reg [1 : 0] counter_in = 2'b 00;
	
	assign data_out = alu_data_in;
	
	always @(posedge i_clk) 
	begin
		if (!i_reset) 
			begin 
				data_a      <= 0;
				data_b      <= 0;
				operation   <= 0;
				counter_in  <= 0;
				tx_start    <= 1'b 0;		
			end 
		
		else
			begin		 	
				if (rx_done_tick) 
					begin
						case (counter_in)
							2'b 00: data_a     <= rx_data_in;
							2'b 01: data_b     <= rx_data_in;
							2'b 10: operation  <= rx_data_in;
						endcase		
						counter_in <= counter_in + 1'b 1;		
					end
			
				if (counter_in == 2'b 11)           //Si el contador llega a 11 vuelve al estado inicial i.e counter_in = 0
					begin
						counter_in <= 0;	
						tx_start   <= 1'b 1;
					end
				else
					begin
						tx_start <= 1'b 0;				
					end		
			end 
    end
endmodule
