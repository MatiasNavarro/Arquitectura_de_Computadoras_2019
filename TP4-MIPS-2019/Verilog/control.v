`timescale 1ns / 1ps

module control
    #(
        parameter NB_OPCODE     = 6,
        parameter NB_ALUOP      = 2
     )
    (
        //Inputs
        input                   i_clk,
        input                   i_rst,
        input   [NB_OPCODE-1:0] i_opcode,
        //Outputs
        output reg                 o_RegDst,
        output reg                 o_Branch,
        output reg                 o_MemRead,
        output reg                 o_MemtoReg,
        output reg [NB_ALUOP-1:0]  o_ALUOp,
        output reg                 o_MemWrite,
        output reg                 o_ALUSrc,
        output reg                 o_RegWrite
    );
    
    always@(*)
    begin
        case(i_opcode)
            6'b 000000: // R-Fotmat
            begin
                o_RegDst      = 1;
                o_ALUSrc      = 0;
                o_MemtoReg    = 0;
                o_RegWrite    = 1;
                o_MemRead     = 0;
                o_MemWrite    = 0;
                o_Branch      = 0;
                o_ALUOp       = 2'b10;
             end
                
            6'b 100011: //LW
            begin
                o_RegDst      = 0;
                o_ALUSrc      = 1;
                o_MemtoReg    = 1;
                o_RegWrite    = 1;
                o_MemRead     = 1;
                o_MemWrite    = 0;
                o_Branch      = 0;
                o_ALUOp       = 2'b00;
            end
                            
            6'b 101011: //SW
            begin
                o_RegDst      = 0;
                o_ALUSrc      = 1;
                o_MemtoReg    = 0;
                o_RegWrite    = 0;
                o_MemRead     = 0;
                o_MemWrite    = 1;
                o_Branch      = 0;
                o_ALUOp       = 2'b00;
            end
                            
            6'b 000100: //BEQ
            begin
                o_RegDst      = 0;
                o_ALUSrc      = 0;
                o_MemtoReg    = 0;
                o_RegWrite    = 0;
                o_MemRead     = 0;
                o_MemWrite    = 0;
                o_Branch      = 1;
                o_ALUOp       = 2'b01;
            end
            
        endcase
    end

endmodule
