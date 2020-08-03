`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2020 09:00:35
// Design Name: 
// Module Name: hazard_detection_unit
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


module hazard_detection_unit
#(
    parameter LEN       = 32,
    parameter NB_ADDR   = 5
)
(
    input [NB_ADDR - 1 : 0] i_rs_id,
    input [NB_ADDR - 1 : 0] i_rt_id,
    input [NB_ADDR - 1 : 0] i_rt_ex,
    input                   i_MemRead,
    output                  o_stall_flag    
);

    assign o_stall_flag = ((i_MemRead == 1) & ((i_rs_id == i_rt_ex) | (i_rt_id == i_rt_ex))) ? 1'b1 : 1'b0; 

endmodule
