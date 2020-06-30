`timescale 1ns / 1ps


//Todo puerto de salida del modulo es un cable.
//Todo puerto de estimulo o generacion de entrada es un registro.
module tb_seg_instruction_fetch();

	parameter LEN             = 32;
    parameter NB_DATA         = 16;
    //PROGRAM MEMORY
    parameter RAM_WIDTH_PROGRAM       = 32;
    parameter RAM_DEPTH_PROGRAM       = 2048;
    parameter RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY";
    parameter INIT_FILE_PROGRAM       = "init_mem_instruction_fetch.mem";
    
    // INPUTS
    reg                 i_clk;
    reg                 i_rst;
    //reg [LEN - 1 : 0]   i_PC_add;       //PC+4
    reg [LEN - 1 : 0]   i_PC_branch;    //PC Branch(Jump) 
    reg                 i_PCSrc;
    // OUTPUTS
    wire [LEN - 1 : 0]  o_instruction;
    wire [LEN - 1 : 0]  o_PC;

    initial begin
        i_clk       = 1'b0;
        i_rst       = 1'b0;
        //i_PC_add    = {LEN{1'b0}};
        i_PC_branch = {LEN{1'b0}};
        i_PCSrc = 1'b0;
        
        #10 
        i_rst = 1'b1;

        #10
        i_PCSrc     = 1'b1;
        //i_PC_add    = 1;
        i_PC_branch = 2;

        #10
        i_PCSrc     = 1'b0;
        //i_PC_add    = 1;
        i_PC_branch = 2;

//        #10 i_PC_branch = 10;
        
//        #10
//        i_PC_branch = 0;
//        i_PCSrc = 1'b1;
        
//        #2 i_PCSrc = 1'b0;
        
        #10 $finish;
    end

    always #1 i_clk = ~i_clk;

    seg_instruction_fetch #(
        .LEN                        (LEN),
        .RAM_WIDTH_PROGRAM 			(RAM_WIDTH_PROGRAM),
        .RAM_DEPTH_PROGRAM 			(RAM_DEPTH_PROGRAM),
        .RAM_PERFORMANCE_PROGRAM 	(RAM_PERFORMANCE_PROGRAM),
        .INIT_FILE_PROGRAM 			(INIT_FILE_PROGRAM)
    )
    tb_seg_instruction_fetch
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        //.i_PC_add           (i_PC_add),
        .i_PC_branch        (i_PC_branch),
        .i_PCSrc            (i_PCSrc),
        //Output
        .o_instruction      (o_instruction),
        .o_PC               (o_PC)
    );

endmodule
