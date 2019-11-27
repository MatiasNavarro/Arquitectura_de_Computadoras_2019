`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2019 10:12:19 PM
// Design Name: 
// Module Name: CPU
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


module CPU
    #( parameter    NB_INSTRUC      = 16,
                    NB_OPCODE       = 5,
                    NB_OPERAND      = 11,
                    NB_ADDR         = 11,
                    NB_DATA         = 16
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_INSTRUC - 1 : 0]     i_instruc,
        input wire [NB_DATA - 1 : 0]        i_data_memory,
        // OUTPUTS
        output wire [NB_OPERAND - 1 : 0]    o_operand,
        output wire [NB_ADDR -1 : 0]        o_addr_program_mem,
        output wire [NB_ADDR - 1 : 0]       o_addr_data_mem,
        output wire [NB_DATA - 1 : 0]       o_data_memory,
        output wire                         o_WrRam,
        output wire                         o_RdRam
    );

    wire [NB_OPERAND - 1 : 0]   operand;
    wire [1 : 0]                SelA;
    wire                        SelB;
    wire                        WrAcc;
    wire                        op;

    control #(
        .NB_INSTRUC (NB_INSTRUC),
        .NB_OPCODE  (NB_OPCODE),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR    (NB_ADDR)
    )
    tb_control (
        // INPUTS
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .i_instruc  (i_instruc),
        // OUTPUTS
        .o_operand  (operand),
        .o_addr     (o_addr_program_mem),
        .o_SelA     (SelA),
        .o_SelB     (SelB),
        .o_WrAcc    (WrAcc),
        .o_op       (op),
        .o_WrRam    (o_WrRam),
        .o_RdRam    (o_RdRam)
    );

    //Modulo para pasarle los estimulos del banco de pruebas.
    datapath #(
        .NB_DATA    (NB_DATA),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR    (NB_ADDR),
        .NB_OPCODE  (NB_OPCODE)
    )
    tb_datapath (
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_SelA         (SelA),
        .i_SelB         (SelB),
        .i_WrAcc        (WrAcc),
        .i_op           (op),
        .i_operand      (operand),
        .i_data_memory  (i_data_memory),
        .o_addr         (o_addr_data_mem),
        .o_data_memory  (o_data_memory)
    );

endmodule
