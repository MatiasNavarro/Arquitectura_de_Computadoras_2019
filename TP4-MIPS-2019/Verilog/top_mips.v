`timescale 1ns / 1ps

module top_mips
    #( parameter    //CPU
                    NB_INSTRUC      = 16,
                    NB_OPCODE       = 5,
                    NB_OPERAND      = 11,
                    NB_ADDR         = 11,
                    NB_DATA         = 16,
                    
                    //PROGRAM MEMORY
                    RAM_WIDTH_PROGRAM       = 16,
                    RAM_DEPTH_PROGRAM       = 2048,
                    RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY",
                    INIT_FILE_PROGRAM       = "/home/martin/git/Arquitectura_de_Computadoras_2019/TP3-BIP1-2019/Test/init_ram_program.mem",
                    
                    //DATA MEMORY
                    RAM_WIDTH_DATA          = 16,
                    RAM_DEPTH_DATA          = 1024, 
                    RAM_PERFORMANCE_DATA    = "LOW_LATENCY",
                    INIT_FILE_DATA          = "/home/martin/git/Arquitectura_de_Computadoras_2019/TP3-BIP1-2019/Test/init_ram_data.mem" 
    )
    (
    //inputs
    input   i_clk,
    input   i_rst,
    //outputs
    output wire [NB_DATA - 1 : 0] o_led
    );

    //Wire CPU - Memory
    wire    [NB_ADDR-1:0]       addr_program_mem;
    wire    [NB_INSTRUC-1:0]    instruc;
    wire                        RdRam;
    wire                        WrRam;
    wire    [NB_ADDR-1:0]       addr_data_mem;
    wire    [NB_DATA-1:0]       in_data_memory;
    wire    [NB_DATA-1:0]       out_data_memory;

    assign o_led [8 - 1 : 0] = in_data_memory [8-1:0];
    assign o_led [NB_DATA - 1 : 8] = addr_program_mem [8-1:0];

    //CPU
    seg_instruction_fetch #(
        .NB_INSTRUC (NB_INSTRUC),
        .NB_OPCODE  (NB_OPCODE),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR    (NB_ADDR),
        .NB_DATA    (NB_DATA),
        .RAM_WIDTH_PROGRAM 			(RAM_WIDTH_PROGRAM),
        .RAM_DEPTH_PROGRAM 			(RAM_DEPTH_PROGRAM),
        .RAM_PERFORMANCE_PROGRAM 	(RAM_PERFORMANCE_PROGRAM),
        .INIT_FILE_PROGRAM 			(INIT_FILE_PROGRAM)
    )
    u_seg_instruction_fetch
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_instruc          (instruc),
        .i_data_memory      (out_data_memory),
        //Output
        .o_addr_program_mem (addr_program_mem),
        .o_addr_data_mem    (addr_data_mem),
        .o_data_memory      (in_data_memory),
        .o_WrRam            (WrRam),
        .o_RdRam            (RdRam)
    );

    seg_execute #(
        .NB_ADDR    (NB_ADDR),
        .NB_DATA    (NB_DATA),
        .NB_CTRL_WB (NB_CTRL_WB),
        .NB_CTRL_M  (NB_CTRL_M),
        .NB_CTRL_EX (NB_CTRL_EX)
    )
    u_seg_execute
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_PC              (i_PC),
        .i_read_data_1              (i_read_data_1),
        .i_read_data_2              (i_read_data_2),
        .i_instruction_15_0              (i_instruction_15_0),
        .i_instruction_20_16              (i_instruction_20_16),
        .i_instruction_15_11              (i_instruction_15_11),
        .i_control              (i_control),
        //Output
        .o_PC        (o_PC),
        .o_ALU_result          (o_ALU_result),
        .o_ALU_zero      (o_ALU_zero),
        .o_read_data_2          (o_read_data_2),
        .o_instruction_20_16_o_15_11          (o_instruction_20_16_o_15_11),
        .o_control          (o_control)
    );

    seg_memory_access #(
        .NB_ADDR    (NB_ADDR),
        .NB_DATA    (NB_DATA),
        .NB_CTRL_WB (NB_CTRL_WB),
        .NB_CTRL_M  (NB_CTRL_M),
        .RAM_WIDTH_DATA          (RAM_WIDTH_DATA),
        .RAM_DEPTH_DATA          (RAM_DEPTH_DATA),
        .RAM_PERFORMANCE_DATA    (RAM_PERFORMANCE_DATA),
        .INIT_FILE_DATA          (INIT_FILE_DATA)
    )
    u_seg_memory_access
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_ALU_result       (i_ALU_result),
        .i_read_data_2      (i_read_data_2),
        .i_instruction_20_16_o_15_11      (i_instruction_20_16_o_15_11),
        .i_control          (i_control),
        //Output
        .o_read_data        (o_read_data),
        .o_address          (o_address),
        .o_instruction_20_16_o_15_11      (o_instruction_20_16_o_15_11),
        .o_control          (o_control)
    );

    seg_write_back #(
        .NB_DATA    (NB_DATA),
        .NB_DATA    (NB_CTRL_WB)
    )
    u_seg_write_back
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_read_data        (i_read_data),
        .i_address          (i_address),
        .i_control          (i_control),
        //Output
        .o_write_data       (o_write_data)
    );
    
endmodule
