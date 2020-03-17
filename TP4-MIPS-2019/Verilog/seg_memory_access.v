`timescale 1ns / 1ps

module seg_memory_access
    #( parameter    NB_ADDR         = 11,
                    NB_DATA         = 16,
                    NB_CTRL_WB      = 2,
                    NB_CTRL_M       = 3,
                    //DATA MEMORY
                    RAM_WIDTH_DATA          = 16,
                    RAM_DEPTH_DATA          = 1024, 
                    RAM_PERFORMANCE_DATA    = "LOW_LATENCY",
                    INIT_FILE_DATA          = "/home/martin/git/Arquitectura_de_Computadoras_2019/TP3-BIP1-2019/Test/init_ram_data.mem"
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_INSTRUC - 1 : 0]     i_ALU_result,
        input wire [NB_DATA - 1 : 0]        i_read_data_2,
        input wire [NB_DATA - 1 : 0]        i_instruction_20_16_o_15_11,
        input wire [NB_CTRL_WB + NB_CTRL_M - 1 : 0] i_control,
        // OUTPUTS
        output wire [NB_ADDR -1 : 0]        o_read_data,
        output wire [NB_ADDR - 1 : 0]       o_address,
        output wire [NB_DATA - 1 : 0]       o_instruction_20_16_o_15_11,
        output wire [NB_CTRL_WB - 1 : 0]    o_control
    );

    //DATA MEMORY
    mem_data #(
        .RAM_WIDTH          (RAM_WIDTH_DATA),
        .RAM_DEPTH          (RAM_DEPTH_DATA),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE_DATA),
        .INIT_FILE          (INIT_FILE_DATA)
    )
    u_data_mem
    (
        .i_addr     (addr_data_mem),
        .i_data     (in_data_memory),
        .i_clk      (i_clk),
        .wea        (WrRam),
        .o_data     (out_data_memory)
    );

endmodule
