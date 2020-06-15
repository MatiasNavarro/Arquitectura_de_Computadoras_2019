`timescale 1ns / 1ps

module seg_execute_alu_control
    #( parameter 
        NB_ALUCTL   = 4,
        NB_OP       = 2,
        NB_FUNC     = 6
    )
    (
        input wire [NB_FUNC - 1: 0]    i_funct,
        input wire [NB_OP - 1: 0]      i_ALUOp,
        output reg [NB_ALUCTL - 1: 0]  o_ALUctl
    );

    assign o_zero = (o_ALUctl == 0);

    always @(*) begin
        casez (i_ALUOp)
            2'b00: o_ALUctl = 4'b0010;
            2'b?1: o_ALUctl = 4'b0110;
            2'b1?: begin
                casez (i_funct)
                    6'b??0000: o_ALUctl = 4'b0010;
                    6'b??0010: o_ALUctl = 4'b0110;
                    6'b??0100: o_ALUctl = 4'b0000;
                    6'b??0101: o_ALUctl = 4'b0001;
                    6'b??0110: o_ALUctl = 4'b1101;  // XOR
                    6'b??0111: o_ALUctl = 4'b1100;  // NOR
                    6'b??1010: o_ALUctl = 4'b0111;  // SLT
                    default: o_ALUctl = 0;
                endcase
            end
            default: o_ALUctl = 0;
        endcase
    end

endmodule
