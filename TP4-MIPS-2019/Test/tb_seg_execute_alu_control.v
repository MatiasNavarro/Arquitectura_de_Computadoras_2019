`timescale 1ns / 1ps

module tb_seg_execute_alu_control();

    localparam NB_ALUCTL = 4;
    localparam NB_OP     = 4;
    localparam NB_FUNC   = 6;
    
    // INPUTS
    reg  [NB_FUNC - 1: 0]       i_funct;
    reg  [NB_OP - 1: 0]         i_ALUOp;
    // OUTPUTS
    wire [NB_ALUCTL - 1: 0]     o_ALUctl;

    initial 
    begin
        i_funct = 0;
        i_ALUOp = 0;
        
        #10 //LW o SW
        i_ALUOp = 4'b0000;
        
        #10 //BRANCH
        i_ALUOp = 4'b0001;

        #10 //R-Type
        i_ALUOp = 4'b0010;
        #10 i_funct = 6'b000000;    //SLL
        #10 i_funct = 6'b000010;    //SRL
        #10 i_funct = 6'b000011;    //SRA
        #10 i_funct = 6'b000100;    //SLLV
        #10 i_funct = 6'b000110;    //SRLV 
        #10 i_funct = 6'b000111;    //SRAV
        #10 i_funct = 6'b100001;    //ADDU
        #10 i_funct = 6'b100011;    //SUBU
        #10 i_funct = 6'b100100;    //AND
        #10 i_funct = 6'b100101;    //OR
        #10 i_funct = 6'b100110;    //XOR
        #10 i_funct = 6'b100111;    //NOR
        #10 i_funct = 6'b101010;    //SLT

        #10 //ADDI
        i_ALUOp = 4'b0011;
        
        #10 //ANDI
        i_ALUOp = 4'b0100;
        
        #10 //ORI
        i_ALUOp = 4'b0101;
        
        #10 //XORI
        i_ALUOp = 4'b0110;

        #10 //LUI
        i_ALUOp = 4'b0111;

        #10 //SLTI
        i_ALUOp = 4'b1000;

        #10 $finish;
    end

    seg_execute_alu_control 
    #(
        .NB_ALUCTL (NB_ALUCTL ),
        .NB_OP     (NB_OP     ),
        .NB_FUNC   (NB_FUNC   )
    )
    u_seg_execute_alu_control
    (
    	.i_funct  (i_funct  ),
        .i_ALUOp  (i_ALUOp  ),
        .o_ALUctl (o_ALUctl )
    );

endmodule
