`timescale 1ns / 1ps

module seg_execute
    #( parameter    LEN             = 32,
       parameter    NB_ALUOP        = 4,
       parameter    NB_ALUCTL       = 4,
       parameter    NB_ADDR         = 5,
       parameter    NB_FUNC         = 6,
       parameter    NB_CTRL_WB      = 2,
       parameter    NB_CTRL_M       = 3,
       parameter    NB_CTRL_EX      = 7
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [LEN - 1 : 0]            i_PC,
        input wire [LEN - 1 : 0]            i_read_data_1,
        input wire [LEN - 1 : 0]            i_read_data_2,
        input wire [LEN - 1 : 0]            i_addr_ext,         // instruction[15:0] extendida a 32 bits
        input wire [NB_ADDR - 1 : 0]        i_rt,               // instruction[20:16]
        input wire [NB_ADDR - 1 : 0]        i_rd,               // instruction[15:11]
        // Control input
        input wire [NB_CTRL_WB - 1 : 0]     i_ctrl_wb_bus,
        input wire [NB_CTRL_M - 1 :  0]     i_ctrl_mem_bus,
        input wire [NB_CTRL_EX - 1 : 0]     i_ctrl_exc_bus,
        // OUTPUTS
        output wire [LEN - 1 : 0]           o_PC_branch,        // Branch o Jump
        output wire [LEN - 1 : 0]           o_ALU_result,       // Address (Data Memory)
        output wire [LEN - 1 : 0]           o_write_data,
        output reg  [NB_ADDR - 1 : 0]       o_write_register,
        output wire                         o_ALU_zero,
        // Control outputs
        output wire [NB_CTRL_WB - 1 : 0]    o_ctrl_wb_bus,
        output wire [NB_CTRL_M - 1 : 0]     o_ctrl_mem_bus
    );

    // Control wires
    wire        [NB_ALUOP - 1 : 0]  ALUOp;
    wire                            ALUSrc;
    // Program Counter Register
    reg         [LEN - 1 : 0]       reg_PC;
    // ALU Registers
    reg signed  [LEN - 1 : 0]       data_b;
    wire        [NB_ALUCTL - 1 : 0] ALUctl;
    wire        [NB_FUNC - 1 : 0]   funct;
     
    assign funct            = i_addr_ext[NB_FUNC-1:0];
    // Execute bits [Jump, ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
    assign Jump             = i_ctrl_exc_bus[NB_ALUOP + 2];
    assign ALUSrc           = i_ctrl_exc_bus[NB_ALUOP + 1];
    assign ALUOp            = i_ctrl_exc_bus[NB_ALUOP : 1];
    assign RegDst           = i_ctrl_exc_bus[0];
    // Outputs 
    assign o_PC_branch      = reg_PC;
    assign o_write_data     = i_read_data_2;
    // Control bus
    assign o_ctrl_wb_bus    = i_ctrl_wb_bus;
    assign o_ctrl_mem_bus   = i_ctrl_mem_bus;
    
    // Program Counter Logic
    always @(posedge i_clk) begin
        if (!i_rst) begin
            reg_PC <= {LEN{1'b0}};
        end else begin
            reg_PC <= i_PC + (i_addr_ext << 2);
        end
    end
    
    always @(*) begin
        // MUX ALUSrc
        data_b = (ALUSrc) ? i_addr_ext : i_read_data_2 ;    // ALUSrc = 1 (i_addr_ext) ALUSrc = 0 (i_read_data_2) 
        // MUX RegDst
        o_write_register = (RegDst) ? i_rd : i_rt;          // RegDst = 1 -> 15-11 (rd) | RegDst = 0 -> 20-16 (rt)
    end
    
    // ALU
    seg_execute_alu_control 
    #(
        .NB_ALUCTL (NB_ALUCTL),
        .NB_OP     (NB_ALUOP),
        .NB_FUNC   (NB_FUNC)
    )
    u_seg_execute_alu_control(
    	.i_funct  (funct),
        .i_ALUOp  (ALUOp),
        .o_ALUctl (ALUctl)
    );
    
    seg_execute_alu
    #(
        .LEN        (LEN),
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
