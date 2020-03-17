`timescale 1ns / 1ps

module seg_execute
    #( parameter    NB_ADDR         = 11,
                    NB_DATA         = 16,
                    NB_CTRL_WB      = 2,
                    NB_CTRL_M       = 3,
                    NB_CTRL_EX      = 4
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_DATA - 1 : 0]        i_PC,
        input wire [NB_INSTRUC - 1 : 0]     i_read_data_1,
        input wire [NB_DATA - 1 : 0]        i_read_data_2,
        input wire [NB_DATA - 1 : 0]        i_instruction_15_0,
        input wire [NB_DATA - 1 : 0]        i_instruction_20_16,
        input wire [NB_DATA - 1 : 0]        i_instruction_15_11,
        input wire [NB_CTRL_WB + NB_CTRL_M + NB_CTRL_EX - 1 : 0] i_control,
        // OUTPUTS
        output wire [NB_DATA - 1 : 0]       o_PC,
        output wire [NB_INSTRUC - 1 : 0]    o_ALU_result,
        output wire                         o_ALU_zero,
        output wire [NB_DATA - 1 : 0]       o_read_data_2,
        output wire [NB_DATA - 1 : 0]       o_instruction_20_16_o_15_11,
        output wire [NB_CTRL_WB + NB_CTRL_M - 1 : 0] o_control
    );

endmodule
