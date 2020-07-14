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
    parameter NB_OPCODE     = 6;
    parameter NB_CTRL_EX    = 7;
    parameter NB_CTRL_M     = 3;
    parameter NB_CTRL_WB    = 2;
    
    // Entradas.
    reg                         i_rst;
    reg [NB_OPCODE-1:0]         i_opcode;
    reg [NB_OPCODE-1:0]         i_funct;
    
    // Salidas.
    wire  [NB_CTRL_WB-1:0]      o_ctrl_wb_bus;
    wire  [NB_CTRL_M-1:0]       o_ctrl_mem_bus;
    wire  [NB_CTRL_EX-1:0]      o_ctrl_exc_bus;

    
    initial    
    begin
    #1
    i_opcode = 0;
    // Test: Prueba reset.
    #10 i_rst  = 1'b0;        // Reset.
    #10 i_rst  = 1'b1;      // Desactivo el reset.
    
    //R-TYPE ------------------------------------------
    #10 i_opcode    = 6'b000000;
        i_funct     = 6'b000000;
    #10 i_funct     = 6'b000010;
    #10 i_funct     = 6'b000011;
    #10 i_funct     = 6'b001000;
    #10 i_funct     = 6'b001001;
    #10 i_funct     = 6'b100000;  
    
    //LOAD TYPE ---------------------------------------
    #10 i_opcode    = 6'b100000;   //LB
    #10 i_opcode    = 6'b100001;   //LH
    #10 i_opcode    = 6'b100011;   //LW
    #10 i_opcode    = 6'b100111;   //LWU
    #10 i_opcode    = 6'b100100;   //LBU
    #10 i_opcode    = 6'b100101;   //LHU
    
    //STORE TYPE ---------------------------------------
    #10 i_opcode    = 6'b101000;   //SB
    #10 i_opcode    = 6'b101001;   //SH
    #10 i_opcode    = 6'b101011;   //SW
    
    //INMEDIATE ---------------------------------------
    #10 i_opcode    = 6'b001000;   //ADDI
    #10 i_opcode    = 6'b001100;   //ANDI
    #10 i_opcode    = 6'b001101;   //ORI
    #10 i_opcode    = 6'b001110;   //XORI
    #10 i_opcode    = 6'b001111;   //LUI
    #10 i_opcode    = 6'b001010;   //SLTI
    
    //BRANCH - JUMP ---------------------------------------
    #10 i_opcode    = 6'b000100;   //BEQ
    #10 i_opcode    = 6'b000101;   //BNQ
    #10 i_opcode    = 6'b000010;   //JUMP (Salto incondicional) 
    #10 i_opcode    = 6'b000011;   //JAL          
    
    #10 $finish;
    end
    
    //Modulo para pasarle los estimulos del banco de pruebas.
    control
    #(
    .NB_OPCODE          (NB_OPCODE      ),
    .NB_CTRL_EX         (NB_CTRL_EX     ),
    .NB_CTRL_M          (NB_CTRL_M      ),
    .NB_CTRL_WB         (NB_CTRL_WB     )
    )
    u_control
    (
    .i_rst              (i_rst          ),
    .i_opcode           (i_opcode       ),
    .i_funct            (i_funct        ),
    .o_ctrl_wb_bus      (o_ctrl_wb_bus  ),
    .o_ctrl_mem_bus     (o_ctrl_mem_bus ),
    .o_ctrl_exc_bus     (o_ctrl_exc_bus )
    );

endmodule
