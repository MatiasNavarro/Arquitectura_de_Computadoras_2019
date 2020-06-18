`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2020 16:06:37
// Design Name: 
// Module Name: ALU_Control
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


module ALU_Control 
    #(
        parameter NB_OPCODE     = 6,
        parameter NB_ALU_CODE   = 4,
        parameter NB_ALUOP      = 2
    )
    (
        //Inputs
        input       [NB_OPCODE-1:0]     i_funct,
        input       [NB_ALUOP-1:0]      i_ALUOp,
        //Outpus
        output  reg [NB_ALU_CODE-1:0]   o_ALUCode
    );
    
    always @(*) 
	begin
		case(i_ALUOp)
            2'b00 : o_ALUCode = 4'b0010;   //I-Type (LW o SW) 
			2'b01 : o_ALUCode = 4'b0110;   //J-Type (Beq) 
			2'b10 : //R-type 
			begin 
				case(i_funct)
					6'b100000 : o_ALUCode = 4'b0010; // ADD
					6'b100010 : o_ALUCode = 4'b0110; // SUB
					6'b100100 : o_ALUCode = 4'b0000; // AND
					6'b100101 : o_ALUCode = 4'b0001; // OR
					6'b101010 : o_ALUCode = 4'b1000; // Set on less than
					default   : o_ALUCode = 4'b0000;
				endcase
			end			
			default: o_ALUCode = 4'b0000;	
		endcase
	end
    
    
endmodule
