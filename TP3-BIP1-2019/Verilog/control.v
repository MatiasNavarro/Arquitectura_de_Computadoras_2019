`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 09:50:59 PM
// Design Name: 
// Module Name: control
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


module control
    #( parameter    NB_INSTRUC      = 16,
                NB_OPCODE       = 5,
                NB_OPERAND      = 11,
                NB_ADRR         = 11
    )
    (
    input i_clk,
    input i_rst,
    input [NB_INSTRUC-1:0] i_instruc,
    output [10:0] o_addr,
    output [NB_OPERAND-1:0] o_operand,
    output [1:0] o_selA,
    output o_selB,
    output o_wrAcc,
    output o_op,
    output o_wrRam,
    output o_rdRam
    );

    wire [NB_OPCODE-1:0] opcode,

endmodule
