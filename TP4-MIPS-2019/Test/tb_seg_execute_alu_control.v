`timescale 1ns / 1ps

module tb_seg_execute_alu_control();

    localparam NB_DATA   = 10;
    localparam NB_ALUCTL = 4;
    localparam NB_OP     = 2;
    localparam NB_FUNC   = 6;
    
    // INPUTS
    reg  [NB_FUNC - 1: 0]    i_funct;
    reg  [NB_OP - 1: 0]      i_ALUOp;
    // OUTPUTS
    wire [NB_ALUCTL - 1: 0]  o_ALUctl;

    // INPUTS
    reg  [NB_DATA - 1: 0]    i_data_a;
    reg  [NB_DATA - 1: 0]    i_data_b;
    // OUTPUTS
    wire [NB_DATA - 1: 0]    o_ALUOut;
    wire                     o_zero;

    initial begin
        i_funct = 0;
        i_ALUOp = 0;
        #10
        i_ALUOp = 2'b01;
        #10
        i_ALUOp = 2'b11;
        #10
        i_ALUOp = 2'b10;
        #10 i_funct = 4'b0000;
        #10 i_funct = 4'b0010;
        #10 i_funct = 4'b0100;
        #10 i_funct = 4'b0101;
        #10 i_funct = 4'b0110;  // XOR
        #10 i_funct = 4'b0111;  // NOR
        #10 i_funct = 4'b1010;  // SLT
        #10
        i_ALUOp = 2'b11;
        #10
        i_ALUOp = 2'b10;
        #10 i_funct = 4'b0000;
        #10 i_funct = 4'b0001;
        #10 i_funct = 4'b0010;
        #10 i_funct = 4'b0011;
        #10 i_funct = 4'b0100;
        #10 i_funct = 4'b0101;
        #10 i_funct = 4'b0110;
        #10 i_funct = 4'b0111;
        #10 i_funct = 4'b1000;
        #10 i_funct = 4'b1001;
        #10 i_funct = 4'b1010;
        #10 i_funct = 4'b1011;
        #10 i_funct = 4'b1100;
        #10 i_funct = 4'b1101;
        #10 i_funct = 4'b1110;
        #10 i_funct = 4'b1111;
        #10 $finish;
    end

    always begin
        #5
        i_data_a = $random;
        i_data_b = $random;
    end

    seg_execute_alu_control 
    #(
        .NB_ALUCTL (NB_ALUCTL ),
        .NB_OP     (NB_OP     ),
        .NB_FUNC   (NB_FUNC   )
    )
    u_seg_execute_alu_control(
    	.i_funct  (i_funct  ),
        .i_ALUOp  (i_ALUOp  ),
        .o_ALUctl (o_ALUctl )
    );

    seg_execute_alu 
    #(
        .NB_DATA   (NB_DATA   ),
        .NB_ALUCTL (NB_ALUCTL )
    )
    u_seg_execute_alu(
    	.i_ALUctl (o_ALUctl ),
        .i_data_a (i_data_a ),
        .i_data_b (i_data_b ),
        .o_ALUOut (o_ALUOut ),
        .o_zero   (o_zero   )
    );
    
    

endmodule
