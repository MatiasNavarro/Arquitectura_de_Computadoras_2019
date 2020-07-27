`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2020 09:00:35
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit
#(
    parameter LEN       = 32,
    parameter NB_ADDR   = 5
)
(
    input   [NB_ADDR - 1 : 0]   i_rs_id_ex,
    input   [NB_ADDR - 1 : 0]   i_rt_id_ex,
    input   [NB_ADDR - 1 : 0]   i_write_reg_ex_mem,
    input   [NB_ADDR - 1 : 0]   i_write_reg_mem_wb,
    input                       i_reg_write_ex_mem,
    input                       i_reg_write_mem_wb,
    output  [1:0]               o_muxA_alu,
    output  [1:0]               o_muxB_alu
);

    always @(*)
    begin
        if((i_reg_write_mem_wb==1'b1) & (i_rs_id_ex==i_write_reg_mem_wb) & (i_reg_write_ex_mem==1'b0 | i_write_reg_ex_mem!=i_rs_id_ex))
            o_muxA_alu = 2'b10;
        else if(i_reg_write_ex_mem==1'b1 & (i_rs_id_ex==i_write_reg_ex_mem))
            o_muxA_alu = 2'b01;
        else
            o_muxA_alu = 2'b00;
            
        if((i_reg_write_mem_wb==1'b1) & (i_rt_id_ex==i_write_reg_mem_wb) & (i_reg_write_ex_mem==1'b0 | i_write_reg_ex_mem!=i_rt_id_ex))
            o_muxB_alu = 2'b10;
        else if(i_reg_write_ex_mem==1'b1 & (i_rt_id_ex==i_write_reg_ex_mem))
            o_muxB_alu = 2'b01;
        else
            o_muxB_alu = 2'b00;
    end

endmodule