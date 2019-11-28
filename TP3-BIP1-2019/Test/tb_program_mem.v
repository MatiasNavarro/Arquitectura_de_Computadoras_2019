`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2019 09:27:49
// Design Name: 
// Module Name: tb_program_mem
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


module tb_program_mem();
    parameter   RAM_WIDTH = 16;                         // Specify RAM data width
    parameter   RAM_DEPTH = 2048;                       // Specify RAM depth (number of entries)
    parameter   RAM_PERFORMANCE = "LOW_LATENCY";   // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    parameter   INIT_FILE = "/home/martin/git/Arquitectura_de_Computadoras_2019/TP3-BIP1-2019/Test/init_ram_program.mem";        // Specify name/location of RAM initialization file if using one (leave blank if not)
    
    //Todo puerto de salida del modulo es un cable.
    //Todo puerto de estimulo o generacion de entrada es un registro.
    
    //Inputs
    reg [16-1:0]            i_addr;         // Address bus, width determined from RAM_DEPTH
    reg                     i_clk;          // Clock
    //Outputs
    wire [RAM_WIDTH-1:0]    o_data;         // RAM output data
    
    initial begin
        i_clk   = 1'b0;
                                     
        i_addr  = 16'h0000;         //Leo la posicion de memoria 0000h
        #5
        i_addr  = 16'h0001;         //Leo la posicion de memoria 0001h
        #5                                                          
        i_addr  = 16'h0002;         //Leo la posicion de memoria 0005h
        #5                                                          
        i_addr  = 16'h0003;         //Leo la posicion de memoria 000Ah
        #5
        i_addr  = 16'h0004;
        #5
        i_addr  = 16'h0005;
        #5
        i_addr  = 16'h0006;
        #5
        i_addr  = 16'h0007;
        #5
        i_addr  = 16'h0008;
        #5
        i_addr  = 16'h0009;
        #5
        i_addr  = 16'h000A;
        #5
        i_addr  = 16'h000B;
        #5
        i_addr  = 16'h000C;
        #5
        i_addr  = 16'h000D;
        
        #1 $finish;
    end
    
    always #2.5 i_clk = ~i_clk;     //Simulacion del clock
    
    program_mem #(
        .RAM_WIDTH          (RAM_WIDTH),
        .RAM_DEPTH          (RAM_DEPTH),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE),
        .INIT_FILE          (INIT_FILE)
    )
    u_program_mem
    (
        .i_addr     (i_addr),
        .i_clk      (i_clk),
        .o_data     (o_data)
    );
    
endmodule
