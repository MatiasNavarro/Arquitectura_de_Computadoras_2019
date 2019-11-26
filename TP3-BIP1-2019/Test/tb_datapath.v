`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2019 01:09:05
// Design Name: 
// Module Name: tb_datapath
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


module tb_datapath();
    		
    
    //Todo puerto de salida del modulo es un cable.
    //Todo puerto de estimulo o generacion de entrada es un registro.
    parameter NB_DATA_01    = 16;   // Cantidad de bits del operando con extension de signo.
    parameter NB_OPERAND_01 = 11;   // Cantidad de bits del operando.
    parameter NB_ADDR_01    = 11;   // Cantidad de bits del addr.
    parameter NB_OPCODE_01  = 5;    // Cantidad de bits del opcode.
    
    
    // Entradas.
    reg                         i_clk_01;
    reg                         i_rst_01;
    reg [1:0]                   i_SelA_01;
    reg                         i_SelB_01;
    reg                         i_WrAcc_01;
    reg                         i_op_01;
    reg [NB_OPERAND_01-1:0]     i_operand_01;
    reg [NB_DATA_01-1:0]        i_data_memory_01;                      
    
    // Salidas.
    wire [NB_ADDR_01-1:0]       o_addr_01;
    wire [NB_DATA_01-1:0]       o_data_memory_01;
    
    
    initial    begin
    #1
    i_clk_01    = 0;
    i_SelA_01   = 2'b00;
    i_SelB_01   = 1'b0;
    i_op_01     = 1'b0;
    i_WrAcc_01  = 1'b0;
    i_operand_01        = 0;
    i_data_memory_01    = 0;
    
    i_rst_01    = 1'b0;
    
    #10 i_rst_01 = 1'b1; // Desactivo la accion del reset.
                        //Estado inicial (No deberia hacer nada)


    // Test: Prueba reset.
    #10 i_rst_01    = 1'b0;        // Reset.
    #10   i_rst_01  = 1'b1;      // Desactivo el reset.
    
    
    //LDI
    #100
    i_SelA_01   = 2'b01;
    i_WrAcc_01  = 1'b1;
    i_op_01     = 1'b1;
    i_operand_01        = 1;
    i_data_memory_01    = 2;
    
    
    
    //ADD
    #100
    i_SelA_01   = 2'b10;
    i_SelB_01   = 1'b0;
    i_op_01     = 1'b0;
    i_WrAcc_01  = 1'b1;
    i_operand_01        = 3;
    i_data_memory_01    = 4;
    
    
    //ADDI
    #100
    i_SelA_01   = 2'b10;
    i_SelB_01   = 1'b1;
    i_op_01     = 1'b0;
    i_WrAcc_01  = 1'b1;
    i_operand_01        = 5;
    i_data_memory_01    = 6;
    
    
    //SUB
    #100
    i_SelA_01   = 2'b10;
    i_SelB_01   = 1'b0;
    i_op_01     = 1'b1;
    i_WrAcc_01  = 1'b1;
    i_operand_01        = 7;
    i_data_memory_01    = 8;
    
    //SUBI
    #100
    i_SelA_01   = 2'b10;
    i_SelB_01   = 1'b1;
    i_op_01     = 1'b1;
    i_WrAcc_01  = 1'b1;
    i_operand_01        = 9;
    i_data_memory_01    = 10;
    
    #10 $finish;
    end
    
    always #2.5 i_clk_01 = ~i_clk_01;  // Simulacion de clock
    
    //Modulo para pasarle los estimulos del banco de pruebas.
    datapath
    #(
    .NB_DATA    (NB_DATA_01),
    .NB_OPERAND (NB_OPERAND_01),
    .NB_ADDR    (NB_ADDR_01),
    .NB_OPCODE  (NB_OPCODE_01)
    
    )
    u_datapath_01
    (
    .i_clk          (i_clk_01),
    .i_rst          (i_rst_01),
    .i_SelA         (i_SelA_01),
    .i_SelB         (i_SelB_01),
    .i_WrAcc        (i_WrAcc_01),
    .i_op           (i_op_01),
    .i_operand      (i_operand_01),
    .i_data_memory  (i_data_memory_01),
    .o_addr         (o_addr_01),
    .o_data_memory  (o_data_memory_01)            
    );
    
endmodule
