`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 09:50:59 PM
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
 	input                     i_rx_done_tick,
 	input      [DBIT-1:0]     i_rx_data_in,
 	input      [DBIT-1:0]     i_alu_data_in,
    //OUTPUT
	output reg [DBIT-1 : 0]   o_data_a,
	output reg [DBIT-1 : 0]   o_data_b,
	output reg [NB_OP-1 : 0]  o_operation,
 	output reg                o_tx_start,
 	output     [DBIT-1:0]     o_data_out 
);
	reg [1 : 0] counter_in = 2'b00;
	
	assign o_data_out = i_alu_data_in;
	
	always @(posedge i_clk) 
	begin
        if (!i_reset)  begin 
            o_data_a      <= 0;
            o_data_b      <= 0;
            o_operation   <= 0;
            counter_in    <= 0;
            o_tx_start    <= 1'b0;
        end else begin
            if (i_rx_done_tick) begin
                case (counter_in)
                    2'b 00: o_data_a     = i_rx_data_in;
                    2'b 01: o_data_b     = i_rx_data_in;
                    2'b 10: o_operation  = i_rx_data_in;
                endcase		
                counter_in = counter_in + 1'b1;		
            end
            if (counter_in == 2'b11) begin //Si el contador llega a 11 vuelve al estado inicial i.e counter_in = 0 
                counter_in = 0;	
                o_tx_start   = 1'b1;
            end else begin
                o_tx_start = 1'b0;
            end
        end
	end
endmodule
