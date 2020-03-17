`timescale 1ns / 1ps

module seg_instruction_fetch
    #( parameter    NB_INSTRUC      = 16,
                    NB_ADDR         = 11,
                    NB_DATA         = 16,
                    //PROGRAM MEMORY
                    RAM_WIDTH_PROGRAM       = 16,
                    RAM_DEPTH_PROGRAM       = 2048,
                    RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY",
                    INIT_FILE_PROGRAM       = "/home/martin/git/Arquitectura_de_Computadoras_2019/TP3-BIP1-2019/Test/init_ram_program.mem"
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_ADDR - 1 : 0]        i_PC1,
        input wire [NB_ADDR - 1 : 0]        i_PC2,
        input wire                          i_PCSrc,
        // OUTPUTS
        output wire [NB_INSTRUC - 1 : 0]    o_instruction,
        output wire [NB_ADDR - 1 : 0]       o_PC
    );

        
    //PROGRAM MEMORY
    mem_instruction #(
        .RAM_WIDTH          (RAM_WIDTH_PROGRAM),
        .RAM_DEPTH          (RAM_DEPTH_PROGRAM),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE_PROGRAM),
        .INIT_FILE          (INIT_FILE_PROGRAM)
    )
    u_mem_instruction
    (
        .i_addr     (addr_program_mem),
        .i_clk      (i_clk),
        .o_data     (instruc)
    );

endmodule
