`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2019 18:04:45
// Design Name: 
// Module Name: ALU
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


module ALU
  #(
  //PARAMETROS
  parameter NB_DATA = 8,
            NB_OP   = 6
  )
(
  //INPUTS
  input wire        [NB_OP-1: 0]        i_operation,
  input wire signed [NB_DATA - 1: 0]    i_data_a,
  input wire signed [NB_DATA - 1: 0]    i_data_b,
  //OUTPUTS
  output reg signed [NB_DATA - 1: 0]    o_result
);

always @(*) begin
  case (i_operation)
    6'b100000: o_result = i_data_a + i_data_b;      //Suma
    6'b100010: o_result = i_data_a - i_data_b;      //Resta
    6'b100100: o_result = i_data_a & i_data_b;      //AND
    6'b100101: o_result = i_data_a | i_data_b;      //OR
    6'b100110: o_result = i_data_a ^ i_data_b;      //XOR
    6'b000011: o_result = i_data_a >>> i_data_b;    //
    6'b000010: o_result = i_data_a >> i_data_b;     //
    6'b100111: o_result = ~(i_data_a | i_data_b);   //
    default: o_result = i_data_a;
  endcase
end

endmodule