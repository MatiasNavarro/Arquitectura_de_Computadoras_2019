`timescale 1ns / 1ps

module seg_execute_alu
    #( parameter 
        LEN     = 32,
        NB_ALUCTL   = 4
    )
    (
        input wire  [NB_ALUCTL - 1: 0]  i_ALUctl,
        input wire  [LEN - 1: 0]    i_data_a,
        input wire  [LEN - 1: 0]    i_data_b,
        output reg  [LEN - 1: 0]    o_ALUOut,
        output wire                 o_zero
    );
    
    wire [LEN - 1: 0]  sub_ab;
	wire [LEN - 1: 0]  add_ab;
	wire               oflow_sub;
	wire               slt;

    assign o_zero = (o_ALUOut == 0) ? 1'b1 : 1'b0; //ALUOut=0 -> Activo o_zero 

	assign sub_ab = i_data_a - i_data_b;
	// assign add_ab = i_data_a + i_data_b;
	assign oflow_sub = (i_data_a[LEN - 1] == i_data_b[LEN - 1] && sub_ab[LEN - 1] != i_data_a[LEN - 1]) ? 1 : 0;
	assign slt = oflow_sub ? ~(i_data_a[LEN - 1]) : i_data_a[LEN - 1];

    always @(*) begin
        case (i_ALUctl)
            4'b0000: o_ALUOut = i_data_a & i_data_b;
            4'b0001: o_ALUOut = i_data_a | i_data_b;
            4'b0010: o_ALUOut = i_data_a + i_data_b;
            4'b0110: o_ALUOut = i_data_a - i_data_b;
            4'b0111: o_ALUOut = {{LEN - 1 {1'b0}}, slt};    // SLT
            // 4'b0111: o_ALUOut = i_data_a < i_data_b ? 1 : 0;    // SLT
            4'b1100: o_ALUOut = ~(i_data_a | i_data_b);         // NOR
            4'b1101: o_ALUOut = i_data_a ^ i_data_b;            // XOR
            default: o_ALUOut = 0;
        endcase
    end
  
endmodule
