`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 09:50:59 PM
// Design Name: 
// Module Name: program_mem
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

module data_mem
#(
    parameter   NB_DATA     = 15,
                NB_OPERAND  = 11
)
(
    //Inputs
    input   [NB_OPERAND-1:0]    i_Addr,
    //Outputs
    output  [NB_DATA-1:0]       out_Data
);

endmodule