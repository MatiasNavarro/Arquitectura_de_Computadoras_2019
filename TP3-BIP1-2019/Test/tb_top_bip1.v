`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 10:22:29 PM
// Design Name: 
// Module Name: tb_top_bip1
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


module tb_top_bip1();

    parameter NB_INSTRUC      = 16;
    parameter NB_OPCODE       = 5;
    parameter NB_OPERAND      = 11;
    parameter NB_ADDR         = 11;
    parameter NB_DATA         = 16;
    // PROGRAM MEMORY
    parameter RAM_WIDTH_PROGRAM       = 16;
    parameter RAM_DEPTH_PROGRAM       = 2048;
    parameter RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY";
    parameter INIT_FILE_PROGRAM       = "";
    // DATA MEMORY
    parameter RAM_WIDTH_DATA          = 16;
    parameter RAM_DEPTH_DATA          = 1024; 
    parameter RAM_PERFORMANCE_DATA    = "LOW_LATENCY";
    parameter INIT_FILE_DATA          = "init_ram.mem";

    //inputs
    reg i_clk;
    reg i_rst;

    initial begin
        i_clk = 1'b0;
        i_rst = 1'b0;

        #10 i_rst = 1'b1; // Desactivo la accion del reset.
        
        #100 $finish;
    end

    always #1 i_clk = ~i_clk;

    //PROGRAM MEMORY
    top_bip1 #(
        // CPU
        .NB_INSTRUC (NB_INSTRUC),
        .NB_OPCODE  (NB_OPCODE),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR    (NB_ADDR),
        .NB_DATA    (NB_DATA),
        // PROGRAM MEMORY
        .RAM_WIDTH_PROGRAM  (RAM_WIDTH_PROGRAM),
        .RAM_DEPTH_PROGRAM  (RAM_DEPTH_PROGRAM),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE_PROGRAM),
        .INIT_FILE_PROGRAM  (INIT_FILE_PROGRAM),
        // DATA MEMORY
        .RAM_WIDTH          (RAM_WIDTH_DATA),
        .RAM_DEPTH          (RAM_DEPTH_DATA),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE_DATA),
        .INIT_FILE          (INIT_FILE_DATA)
    )
    tb_top_bip1
    (
        .i_clk      (i_clk),
        .i_rst     (i_rst)
    );

endmodule
