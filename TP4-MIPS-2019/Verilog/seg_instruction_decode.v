`timescale 1ns / 1ps

module seg_instruction_decode
    #( parameter    NB_INSTRUC      = 16,
                    NB_OPCODE       = 5,
                    NB_OPERAND      = 11,
                    NB_ADDR         = 11,
                    NB_DATA         = 16
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_INSTRUC - 1 : 0]     i_read_data_1,
        input wire [NB_DATA - 1 : 0]        i_PC,
        // OUTPUTS
        output wire [NB_DATA - 1 : 0]       o_PC,
        output wire [NB_INSTRUC - 1 : 0]    o_read_data_1,
        output wire [NB_DATA - 1 : 0]       o_read_data_2,
        output wire [NB_DATA - 1 : 0]       o_instruction_15_0,
        output wire [NB_DATA - 1 : 0]       o_instruction_20_16,
        output wire [NB_DATA - 1 : 0]       o_instruction_15_11
    );

    wire [NB_OPERAND - 1 : 0]   operand;
    wire [1 : 0]                SelA;
    wire                        SelB;
    wire                        WrAcc;
    wire                        op;

    control #(
        .NB_INSTRUC (NB_INSTRUC),
        .NB_OPCODE  (NB_OPCODE),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR    (NB_ADDR)
    )
    u_control (
        // INPUTS
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .i_instruc  (i_instruc),
        // OUTPUTS
        .o_operand  (operand),
        .o_addr     (o_addr_program_mem),
        .o_SelA     (SelA),
        .o_SelB     (SelB),
        .o_WrAcc    (WrAcc),
        .o_op       (op),
        .o_WrRam    (o_WrRam),
        .o_RdRam    (o_RdRam)
    );

    //Modulo para pasarle los estimulos del banco de pruebas.
    registers #(
        .NB_DATA    (NB_DATA),
        .NB_OPCODE  (NB_OPCODE),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR    (NB_ADDR)
        
    )
    u_registers (
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_SelA         (SelA),
        .i_SelB         (SelB),
        .i_WrAcc        (WrAcc),
        .i_op           (op),
        .i_operand      (operand),
        .i_data_memory  (i_data_memory),
        .o_addr         (o_addr_data_mem),
        .o_data_memory  (o_data_memory)
    );

endmodule
