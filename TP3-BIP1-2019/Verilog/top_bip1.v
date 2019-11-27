`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 09:40:54 PM
// Design Name: 
// Module Name: top_bip1
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


module top_bip1
    #(parameter //CPU
                NB_INSTRUC      = 16,
                NB_OPCODE       = 5,
                NB_OPERAND      = 11,
                NB_ADDR         = 11,
                NB_DATA         = 16,
                
                //PROGRAM MEMORY
                RAM_WIDTH_PROGRAM       = 16,
                RAM_DEPTH_PROGRAM       = 2048,
                RAM_PERFORMANCE_PROGRAM = "HIGH_PERFORMANCE",
                INIT_FILE_PROGRAM       = "",
                
                //DATA MEMORY
                RAM_WIDTH_DATA          = 16,
                RAM_DEPTH_DATA          = 1024, 
                RAM_PERFORMANCE_DATA    = "LOW_LATENCY",
                INIT_FILE_DATA          = "" ,
                                
                //UART
                DBIT = 8,                   // # data bits
                SB_TICK = 16,               // # ticks for stop bits, 16/24/32
                                            // for 1/1.5/2 stop bits
                BAUDRATE_DIVISOR = 651,      // baud rate divisor
                BAUDRATE_DIVISOR_BITS = 10,  // # bits of BAUDRATE_DIVISOR
                NB_OP = 6                   //Bit number for operation
      )
      (
        //inputs
        input   i_clk,
        input   i_rst,
        //Uart
        input   RsRx,
        output  RsTx
      );
        
        //Wire CPU - Memory
        wire    [NB_ADDR-1:0]       addr_program_mem;
        wire    [NB_INSTRUC-1:0]    instruc;
        wire                        RdRam;
        wire                        WrRam;
        wire    [NB_ADDR-1:0]       addr_data_mem;
        wire    [NB_DATA-1:0]       in_data_memory;
        wire    [NB_DATA-1:0]       out_data_memory;
        //Wire CPU 
        wire    [NB_DATA - 1 : 0]   i_data_memory;
        //Wire Program Memory
        //Wire Data Memory
        //Wire UART
        wire    i_uart;
        wire    o_uart;
        
        
        //CPU
        CPU #(
            .NB_INSTRUC (NB_INSTRUC),
            .NB_OPCODE  (NB_OPCODE),
            .NB_OPERAND (NB_OPERAND),
            .NB_ADDR    (NB_ADDR),
            .NB_DATA    (NB_DATA)     
        )
        u_CPU
        (
            //Input
            .i_clk              (i_clk),
            .i_rst              (i_rst),
            .i_instruc          (instruc),
            .i_data_memory      (out_data_memory),
            //Output
            //.o_operand
            .o_addr_program_mem (addr_program_mem),
            .o_addr_data_mem    (addr_data_mem),
            .o_data_memory      (in_data_memory),
            .o_WrRam            (WrRam),
            .o_RdRam            (RdRam)
        );
        
        //PROGRAM MEMORY
        program_mem #(
            .RAM_WIDTH          (RAM_WIDTH_PROGRAM),
            .RAM_DEPTH          (RAM_DEPTH_PROGRAM),
            .RAM_PERFORMANCE    (RAM_PERFORMANCE_PROGRAM),
            .INIT_FILE          (INIT_FILE_PROGRAM)
        )
        u_program_mem
        (
            .i_addr     (addr_program_mem),
            .i_clk      (i_clk),
            .o_data     (instruc)
        );
        
        //DATA MEMORY
        data_mem #(
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
        
        //UART
        uart #(
            .DBIT                   (DBIT),
            .SB_TICK                (SB_TICK),
            .BAUDRATE_DIVISOR       (BAUDRATE_DIVISOR),
            .BAUDRATE_DIVISOR_BITS  (BAUDRATE_DIVISOR_BITS),
            .NB_OP                  (NB_OP)
        )
        u_uart
        (
            .i_clk  (i_clk),
            .i_rst  (i_rst),
            .RsRx   (i_uart),
            .RsTx   (o_uart)            
        );
        
        assign RsTx = o_uart;
    
endmodule
