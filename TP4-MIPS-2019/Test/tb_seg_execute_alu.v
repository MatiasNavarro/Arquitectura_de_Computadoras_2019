`timescale 1ns / 1ps

module tb_seg_execute_alu();
  
    localparam NB_DATA     = 5;
    localparam NB_ALUCTL   = 4;

    // INPUTS
    reg  [NB_ALUCTL - 1: 0]  i_ALUctl;
    reg  [NB_DATA - 1: 0]    i_data_a;
    reg  [NB_DATA - 1: 0]    i_data_b;
    // OUTPUTS
    wire [NB_DATA - 1: 0]    o_ALUOut;
    wire                     o_zero;
  
    initial begin
        i_ALUctl = 6'b100000;
        i_data_a = {NB_DATA{1'b0}};
        i_data_b = {NB_DATA{1'b0}};
        #20
        i_ALUctl = 4'b0010;
        #20
        i_ALUctl = 4'b0110;
        #20
        i_ALUctl = 4'b0010;
        #20
        i_ALUctl = 4'b0110;
        #20
        i_ALUctl = 4'b0000;
        #20
        i_ALUctl = 4'b0001;
        #20
        i_ALUctl = 4'b0111;
        #40 $finish;
    end

    always begin
    #1
        i_data_a = $random;
        i_data_b = $random;
    end

    seg_execute_alu 
    #(
        .NB_DATA   (NB_DATA   ),
        .NB_ALUCTL (NB_ALUCTL )
    )
    u_seg_execute_alu(
    	.i_ALUctl (i_ALUctl ),
        .i_data_a (i_data_a ),
        .i_data_b (i_data_b ),
        .o_ALUOut (o_ALUOut ),
        .o_zero   (o_zero   )
    );

endmodule