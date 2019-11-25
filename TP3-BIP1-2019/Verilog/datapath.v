`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 09:50:59 PM
// Design Name: 
// Module Name: datapath
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

module datapath
#(
    parameter   NB_DATA     = 15,
                NB_OPERAND  = 11
)
(
    //Inputs
    input   [1:0]               i_selA,
    input                       i_selB,
    input                       i_WrAcc,
    input                       i_Op,
    input   [NB_OPERAND-1:0]    i_Operand,
    input   [NB_DATA-1:0]       i_data_memory,
    //Outputs
    output  [NB_OPERAND-1:0]    o_Addr,
    output  [NB_DATA-1:0]       o_data_memory
);

endmodule