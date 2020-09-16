`timescale 1ns / 1ps

module seg_execute
    #( parameter    LEN             = 32,
       parameter    NB_ALUOP        = 4,
       parameter    NB_ALUCTL       = 4,
       parameter    NB_ADDR         = 5,
       parameter    NB_FUNC         = 6,
       parameter    NB_CTRL_WB      = 2,
       parameter    NB_CTRL_M       = 9,
       parameter    NB_CTRL_EX      = 6
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
        input wire                          i_flush,
        // Control input
        input wire [NB_CTRL_WB - 1 : 0]     i_ctrl_wb_bus,
        input wire [NB_CTRL_M - 1 :  0]     i_ctrl_mem_bus,
        input wire [NB_CTRL_EX - 1 : 0]     i_ctrl_exc_bus,
        // Forwarding
        input wire [1:0]                    i_muxA_forwarding,
        input wire [1:0]                    i_muxB_forwarding, 
        input wire [LEN - 1 : 0]            i_rd_mem_forwarding,
        input wire [LEN - 1 : 0]            i_rd_wb_forwarding, 
        // OUTPUTS
        output wire [LEN - 1 : 0]           o_PC_branch,        // Branch
        output wire [LEN - 1 : 0]           o_ALU_result,       // Address (Data Memory)
        output wire [LEN - 1 : 0]           o_write_data,
        output wire [NB_ADDR - 1 : 0]       o_write_register,
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
    wire        [LEN - 1 : 0]       data_b;
    wire        [NB_ALUCTL - 1 : 0] ALUctl;
    wire        [NB_FUNC - 1 : 0]   funct;

    // MUX Forwarding
    wire        [LEN - 1 : 0]       muxA_Alu;
    wire        [LEN - 1 : 0]       muxB_Alu;
    
    assign funct            = i_addr_ext[NB_FUNC-1:0];
    // Execute bits [ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
    assign ALUSrc           = i_ctrl_exc_bus[NB_ALUOP + 1];
    assign ALUOp            = i_ctrl_exc_bus[NB_ALUOP : 1];
    assign RegDst           = i_ctrl_exc_bus[0];
    // Outputs 
    assign o_PC_branch      = reg_PC;
    // Control bus
    assign o_ctrl_wb_bus    = (i_flush) ? 0 : i_ctrl_wb_bus;
    assign o_ctrl_mem_bus   = (i_flush) ? 0 : i_ctrl_mem_bus;
    
    // Program Counter Logic
    always @(posedge i_clk) begin
        if (!i_rst) begin
            reg_PC <= {LEN{1'b0}};
        end else begin
            reg_PC <= i_PC + i_addr_ext;
        end
    end

    // MUX Forwarding A
    assign muxA_Alu = (i_muxA_forwarding == 2'b00) ? i_read_data_1 :
                      (i_muxA_forwarding == 2'b01) ? i_rd_mem_forwarding :
                      (i_muxA_forwarding == 2'b10) ? i_rd_wb_forwarding :
                      i_read_data_1;

    // MUX Forwarding B
    assign muxB_Alu = (i_muxB_forwarding == 2'b00) ? i_read_data_2 :
                      (i_muxB_forwarding == 2'b01) ? i_rd_mem_forwarding :
                      (i_muxB_forwarding == 2'b10) ? i_rd_wb_forwarding :
                      i_read_data_2;

    assign o_write_data = muxB_Alu;

    // MUX ALUSrc
    assign data_b = (ALUSrc) ? i_addr_ext : muxB_Alu ;         // ALUSrc = 1 (i_addr_ext) ALUSrc = 0 (muxB_Alu)
    // MUX RegDst
    assign o_write_register = (RegDst) ? i_rd : i_rt;          // RegDst = 1 -> 15-11 (rd) | RegDst = 0 -> 20-16 (rt)
    
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
        .i_data_a (muxA_Alu),
        .i_data_b (data_b),
        .o_ALUOut (o_ALU_result),
        .o_zero   (o_ALU_zero)
    );

endmodule
