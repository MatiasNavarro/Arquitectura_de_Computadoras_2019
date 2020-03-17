`timescale 1ns / 1ps

module registers
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
        output wire [NB_ADDR -1 : 0]        o_addr_program_mem,
        output wire [NB_ADDR - 1 : 0]       o_addr_data_mem,
        output wire [NB_DATA - 1 : 0]       o_data_memory,
        output wire                         o_WrRam,
        output wire                         o_RdRam
    );

endmodule
