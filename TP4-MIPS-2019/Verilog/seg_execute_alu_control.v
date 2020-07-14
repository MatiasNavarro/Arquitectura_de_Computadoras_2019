`timescale 1ns / 1ps

module seg_execute_alu_control
    #( parameter 
        NB_ALUCTL   = 4,
        NB_OP       = 4,
        NB_FUNC     = 6
    )
    (
        input   wire    [NB_FUNC - 1: 0]    i_funct,
        input   wire    [NB_OP - 1: 0]      i_ALUOp,
        output  reg     [NB_ALUCTL - 1: 0]  o_ALUctl
    );

    always @(*) begin
        casez (i_ALUOp)
            4'b0000:  //LW o SW
                o_ALUctl = 4'b0010;                 //ADDU

            4'b0001:  //BRANCH 
                o_ALUctl = 4'b0110;                 //SUBU
            
            4'b0010: begin    //R-Type
                casez (i_funct)
                    6'b000000: o_ALUctl = 4'b1011;  //SLL
                    6'b000010: o_ALUctl = 4'b1100;  //SRL
                    6'b000011: o_ALUctl = 4'b1101;  //SRA
                    6'b000100: o_ALUctl = 4'b1011;  //SLLV
                    6'b000110: o_ALUctl = 4'b1100;  //SRLV
                    6'b000111: o_ALUctl = 4'b1101;  //SRAV
                    6'b100001: o_ALUctl = 4'b0010;  //ADDU
                    6'b100011: o_ALUctl = 4'b0110;  //SUBU
                    6'b100100: o_ALUctl = 4'b0000;  //AND
                    6'b100101: o_ALUctl = 4'b0001;  //OR
                    6'b100110: o_ALUctl = 4'b1001;  //XOR
                    6'b100111: o_ALUctl = 4'b1010;  //NOR
                    6'b101010: o_ALUctl = 4'b0111;  //SLT
                    
                    default: o_ALUctl = 4'b0010;    //ADDU
                endcase
            end
            
            4'b0011:
                o_ALUctl = 4'b0011;                 //ADDI

            4'b0100:
                o_ALUctl = 4'b0000;                 //ANDI
            
            4'b0101:
                o_ALUctl = 4'b0001;                 //ORI
            
            4'b0110:
                o_ALUctl = 4'b1001;                 //XORI
            
            4'b0111:
                o_ALUctl = 4'b1000;                 //LUI
            
            4'b1000:
                o_ALUctl = 4'b0111;                 //SLTI
            
            default: o_ALUctl = 4'b0010;            //ADDU
        endcase
    end

endmodule
