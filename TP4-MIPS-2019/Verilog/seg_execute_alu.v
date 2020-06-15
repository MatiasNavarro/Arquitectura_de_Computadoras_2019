`timescale 1ns / 1ps

module seg_execute_alu
    #( parameter 
        NB_DATA     = 32,
        NB_ALUCTL   = 4
    )
    (
        input wire  [NB_ALUCTL - 1: 0]  i_ALUctl,
        input wire  [NB_DATA - 1: 0]    i_data_a,
        input wire  [NB_DATA - 1: 0]    i_data_b,
        output reg  [NB_DATA - 1: 0]    o_ALUOut,
        output wire                     o_zero
    );

    assign o_zero = (o_ALUOut == 0);

    always @(*) begin
        case (i_ALUctl)
            4'b0000: o_ALUOut = i_data_a & i_data_b;
            4'b0001: o_ALUOut = i_data_a | i_data_b;
            4'b0010: o_ALUOut = i_data_a + i_data_b;
            4'b0110: o_ALUOut = i_data_a - i_data_b;
            4'b0111: o_ALUOut = i_data_a < i_data_b ? 1 : 0;  // SLT
            4'b1100: o_ALUOut = ~(i_data_a | i_data_b);       // NOR
            4'b1101: o_ALUOut = i_data_a ^ i_data_b;          // XOR
            default: o_ALUOut = 0;
        endcase
    end
  
endmodule
