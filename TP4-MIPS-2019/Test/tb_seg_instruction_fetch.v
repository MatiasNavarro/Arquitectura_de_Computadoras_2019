`timescale 1ns / 1ps

module tb_seg_instruction_fetch();

	parameter LEN                     = 32;
    //PROGRAM MEMORY
    parameter RAM_WIDTH_PROGRAM       = 32;
    parameter RAM_DEPTH_PROGRAM       = 32;
    parameter RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY";
    // parameter INIT_FILE_PROGRAM       = "C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\init_mem_instruction_fetch.mem";
    parameter INIT_FILE_PROGRAM       = "";
    
    // INPUTS
    reg                 i_clk;
    reg                 i_rst;
    reg [LEN - 1 : 0]   i_PC_branch;
    reg [LEN - 1 : 0]   i_PC_dir_jump;
    reg                 i_PCSrc;
    reg                 i_jump;
    reg                 i_stall_flag;
    reg                 i_preload_flag;
    reg [LEN - 1 : 0]   i_preload_address;
    reg [LEN - 1 : 0]   i_preload_instruction;
    // OUTPUTS
    wire [LEN - 1 : 0]  o_instruction;
    wire [LEN - 1 : 0]  o_PC;

    initial begin
        i_clk = 1'b0;
        i_rst = 1'b0;
        i_PC_branch = {LEN{1'b0}};
        i_PC_dir_jump = {LEN{1'b0}};
        i_PCSrc = 1'b0;
        i_jump = 1'b0;
        i_stall_flag = 1'b0;
        i_preload_flag = 1'b0;
        i_preload_address = {LEN{1'b0}};
        i_preload_instruction = {LEN{1'b0}};

        // Etaba pre-carga
        #4
        i_preload_flag = 1;
        i_preload_address = 0;
        i_preload_instruction = 32'hAB8B0000;
        #4
        i_preload_address = 1;
        i_preload_instruction = 32'hAB8B0001;
        #4
        i_preload_address = 2;
        i_preload_instruction = 32'hAB8B0002;
        #4
        i_preload_address = 3;
        i_preload_instruction = 32'hAB8B0003;
        #4
        i_preload_address = 6;
        i_preload_instruction = 32'hAB8B0006;

        #4 
        i_preload_flag = 0;
        i_rst = 1'b1;

        // Fin de estapa de carga
        
        #10 i_rst = 1'b1;

        #30
        i_PCSrc = 1'b1;
        i_PC_branch = 3;

        #10
        i_PCSrc = 1'b0;
        i_PC_branch = 2;

        #10 i_PC_branch = 10;
        #10
        i_PC_branch = 0;
        i_PCSrc = 1'b1;
        #2 i_PCSrc = 1'b0;
        
        #10 $finish;
    end

    always #1 i_clk = ~i_clk;

    seg_instruction_fetch 
    #(
        .LEN                     (LEN                     ),
        .RAM_WIDTH_PROGRAM       (RAM_WIDTH_PROGRAM       ),
        .RAM_DEPTH_PROGRAM       (RAM_DEPTH_PROGRAM       ),
        .RAM_PERFORMANCE_PROGRAM (RAM_PERFORMANCE_PROGRAM ),
        .INIT_FILE_PROGRAM       (INIT_FILE_PROGRAM       )
    )
    u_seg_instruction_fetch(
    	.i_clk                 (i_clk                 ),
        .i_rst                 (i_rst                 ),
        .i_PC_branch           (i_PC_branch           ),
        .i_PC_dir_jump         (i_PC_dir_jump         ),
        .i_PCSrc               (i_PCSrc               ),
        .i_jump                (i_jump                ),
        .i_stall_flag          (i_stall_flag          ),
        .i_preload_flag        (i_preload_flag        ),
        .i_preload_address     (i_preload_address     ),
        .i_preload_instruction (i_preload_instruction ),
        .o_instruction         (o_instruction         ),
        .o_PC                  (o_PC                  )
    );
    

endmodule
