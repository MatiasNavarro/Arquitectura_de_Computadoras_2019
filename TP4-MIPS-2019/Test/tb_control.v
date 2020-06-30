`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2020 15:25:21
// Design Name: 
// Module Name: tb_control
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


module tb_control#();
 	
    //Todo puerto de salida del modulo es un cable.
    //Todo puerto de estimulo o generacion de entrada es un registro.
   // Cantidad de bits del opcode. (6 bits MSB de la instruccion)   
   // Cantidad de bits del output al ALU OP (Control de ALU)
    parameter NB_EXC_BUS_01    = 3;
    parameter NB_MEM_BUS_01    = 3;
    parameter NB_OPCODE_01     = 6;
    parameter NB_ALU_CODE_01   = 4;
    parameter NB_ALUOP_01      = 2;
    parameter NB_WB_BUS_01     = 2;
    
    // Entradas.
    //reg                         i_rst_01;
    reg [NB_OPCODE_01-1:0]      i_opcode_01;
    //reg [NB_OPCODE_01-1:0]      i_funct_01;
    
    // Salidas.
    wire  [NB_WB_BUS_01-1:0]    o_wb_bus_01;
    wire  [NB_MEM_BUS_01-1:0]   o_mem_bus_01;
    wire  [NB_EXC_BUS_01-1:0]   o_exc_bus_01;
    wire  [NB_ALUOP_01-1:0]     o_alu_op_01;

    
    initial    
    begin
    #1
    i_opcode_01 = {NB_OPCODE_01-1{1'b0}};

    // Test: Prueba reset.
//    #10 i_rst_01  = 1'b0;        // Reset.
//    #10 i_rst_01  = 1'b1;      // Desactivo el reset.
    //R-Format
    #10 i_opcode_01 = 6'b000000;
//    #10 i_rst_01  = 1'b0;       // Reset.
//    #10 i_rst_01  = 1'b1;       // Desactivo el reset.
    
    //LW
    #10 i_opcode_01 = 6'b100011;
//    #10 i_rst_01  = 1'b0;       // Reset.
//    #10 i_rst_01  = 1'b1;       // Desactivo el reset.
    
    //SW
    #10 i_opcode_01 = 6'b101011;
//    #10 i_rst_01  = 1'b0;       // Reset.
//    #10 i_rst_01  = 1'b1;       // Desactivo el reset.    
    
    //BEQ
    #10 i_opcode_01 = 6'b000100;
//    #10 i_rst_01  = 1'b0;       // Reset.
//    #10 i_rst_01  = 1'b1;       // Desactivo el reset.      
    
    #10 $finish;
    end
    
    //always #2.5 i_clk_01 = ~i_clk_01;  // Simulacion de clock
    
    //Modulo para pasarle los estimulos del banco de pruebas.
    control
    #(
    .NB_EXC_BUS      (NB_EXC_BUS_01),
    .NB_MEM_BUS      (NB_MEM_BUS_01),
    .NB_OPCODE       (NB_OPCODE_01),
    .NB_ALU_CODE     (NB_ALU_CODE_01),
    .NB_ALUOP        (NB_ALUOP_01), 
    .NB_WB_BUS       (NB_WB_BUS_01)
    )
    u_control_01
    (
    .i_rst          (i_rst_01),
    .i_opcode       (i_opcode_01),
    .i_funct        (i_funct_01),
    .o_wb_bus       (o_wb_bus_01),
    .o_mem_bus      (o_mem_bus_01),
    .o_exc_bus      (o_exc_bus_01)
    );

endmodule
