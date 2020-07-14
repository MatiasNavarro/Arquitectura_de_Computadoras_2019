`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2020 19:20:50
// Design Name: 
// Module Name: tb_seg_execute_alu
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


module tb_seg_execute_alu();
    
    localparam LEN          = 32;
    localparam NB_ALUCTL    = 4;
    
    // INPUTS
    reg  [NB_ALUCTL - 1: 0]     i_ALUctl;
    reg  [LEN - 1: 0]           i_data_a;
    reg  [LEN - 1: 0]           i_data_b;
    // OUTPUTS
    wire [LEN - 1: 0]    o_ALUOut;
    wire                 o_zero;

    initial 
    begin
        i_ALUctl    = 0;
        i_data_a    = 0;
        i_data_b    = 0;

        #10
        i_data_a    = 32'h00001111; 
        i_data_b    = 32'h11110000;
        #10
        i_ALUctl = 4'b0000;  //AND  - ANDI 
        #10
        i_ALUctl = 4'b0001;  //OR   - ORI
        #10
        i_ALUctl = 4'b0010;  //ADDU - LOAD
        #10
        i_ALUctl = 4'b0011;  //ADDI
        #10
        i_data_a    = 32'h11111111; 
        i_data_b    = 32'h11110000;
        i_ALUctl = 4'b0110;  //SUBU
        #10
        i_data_a    = 3; 
        i_data_b    = 2;
        i_ALUctl = 4'b0111;  //SLT  - SLTI
        #10
        i_ALUctl = 4'b1000;  //LUI
        #10
        i_ALUctl = 4'b1001;  //XOR  - XORI
        #10
        i_ALUctl = 4'b1010;  //NOR
        #10
        i_data_a    = 32'h00001111; 
        i_data_b    = 2;
        i_ALUctl = 4'b1011;  //SLL  - SLLV   (shift left)
        #10
        i_data_a    = 32'h11110000; 
        i_data_b    = 2;
        i_ALUctl = 4'b1100;  //SRL  - SRLV   (right logico)
        #10
        i_ALUctl = 4'b1101;  //SRA  - SRAV   (right aritmetico)

        #10 $finish;
    end

    seg_execute_alu 
    #(
        .LEN        (LEN        ),
        .NB_ALUCTL  (NB_ALUCTL  )
    )
    u_seg_execute_alu
    (
    	.i_ALUctl   (i_ALUctl    ),
        .i_data_a   (i_data_a   ),
        .i_data_b   (i_data_b   ),
        .o_ALUOut   (o_ALUOut   ),
        .o_zero     (o_zero     )
    );

endmodule
