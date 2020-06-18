`timescale 1ns / 1ps

module seg_execute
    #( parameter    NB_ADDR         = 32,
                    NB_DATA         = 32,
                    NB_OP           = 2,
                    NB_ALUCTL       = 4,
                    NB_FUNC         = 6,
                    NB_CTRL_WB      = 2,
                    NB_CTRL_M       = 3,
                    NB_CTRL_EX      = 4
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_ADDR - 1 : 0]        i_PC,
        input wire [NB_DATA - 1 : 0]        i_read_data_1,
        input wire [NB_DATA - 1 : 0]        i_read_data_2,
        input wire [NB_ADDR - 1 : 0]        i_instruction_15_0,
        input wire [20 - 16 : 0]            i_instruction_20_16,
        input wire [15 - 11 : 0]            i_instruction_15_11,
        input wire [NB_CTRL_WB + NB_CTRL_M + NB_CTRL_EX - 1 : 0] i_control,
        // OUTPUTS
        output wire [NB_ADDR - 1 : 0]       o_PC,
        output wire [NB_DATA - 1 : 0]       o_ALU_result,
        output wire                         o_ALU_zero,
        output wire [NB_DATA - 1 : 0]       o_read_data_2,
        output reg  [20 - 16 : 0]           o_instruction_20_16_o_15_11,
        output wire [NB_CTRL_WB + NB_CTRL_M - 1 : 0] o_control
    );

    // Control wires
    wire RegDst;
    wire [NB_OP - 1 : 0] ALUOp;
    wire ALUSrc;
    // Program Counter Register
    reg [NB_ADDR - 1 : 0] reg_PC;
    // ALU Registers
    reg signed [NB_DATA - 1 : 0] data_b;
    wire [NB_ALUCTL - 1 : 0] ALUctl;
    wire [NB_FUNC - 1 : 0] funct;

    // Program Counter Logic
    always @(posedge i_clk) begin
        if (!i_rst) begin
            reg_PC <= {NB_ADDR{1'b0}};
        end else begin
            reg_PC <= i_PC + (i_instruction_15_0 << 2);
        end
    end

    assign o_PC = reg_PC;
    assign RegDst           = i_control[NB_CTRL_WB + NB_CTRL_M];
    assign ALUOp            = i_control[NB_CTRL_WB + NB_CTRL_M + 2 : NB_CTRL_WB + NB_CTRL_M + 1];
    assign ALUSrc           = i_control[NB_CTRL_WB + NB_CTRL_M +  1 + NB_OP];
    assign funct            = i_instruction_15_0[NB_FUNC - 1 : 0];
    assign o_read_data_2    = i_read_data_2;
    assign o_control        = i_control[NB_CTRL_WB + NB_CTRL_M - 1 : 0];
    
    always @(*) begin
        if (!ALUSrc) begin
            data_b = i_read_data_2;
        end else begin
            data_b = i_instruction_15_0[NB_DATA - 1 : 0];
        end
        if (!RegDst) begin
            o_instruction_20_16_o_15_11 = i_instruction_20_16;
        end else begin
            o_instruction_20_16_o_15_11 = i_instruction_15_11;
        end
    end
    
    // ALU
    seg_execute_alu_control 
    #(
        .NB_ALUCTL (NB_ALUCTL),
        .NB_OP     (NB_OP),
        .NB_FUNC   (NB_FUNC)
    )
    u_seg_execute_alu_control(
    	.i_funct  (funct),
        .i_ALUOp  (ALUOp),
        .o_ALUctl (ALUctl)
    );
    
    seg_execute_alu
    #(
        .NB_DATA    (NB_DATA),
        .NB_ALUCTL  (NB_ALUCTL)
    )
    u_seg_execute_alu(
    	.i_ALUctl (ALUctl),
        .i_data_a (i_read_data_1),
        .i_data_b (data_b),
        .o_ALUOut (o_ALU_result),
        .o_zero   (o_ALU_zero)
    );

endmodule
