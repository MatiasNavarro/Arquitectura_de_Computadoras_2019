`timescale 1ns / 1ps

module tb_control();

    parameter NB_INSTRUC      = 16;
    parameter NB_OPCODE       = 5;
    parameter NB_OPERAND      = 11;
    parameter NB_ADDR         = 11;

    // INPUTS
    reg                          i_clk;
    reg                          i_rst;
    reg [NB_INSTRUC - 1 : 0]     i_instruc;
    // OUTPUTS
    wire [NB_OPERAND - 1 : 0]    o_operand;
    wire [NB_ADDR -1 : 0]        o_addr;
    // Instruction decoder OUTPUTS
    wire [1 : 0]                 o_SelA;
    wire                         o_SelB;
    wire                         o_WrAcc;
    wire                         o_op;       //operation
    wire                         o_WrRam;
    wire                         o_RdRam;


    initial begin
        i_clk = 1'b0;
        i_rst = 1'b0;
        i_instruc = {NB_INSTRUC{1'b0}};

        #10 i_rst = 1'b1; // Desactivo la accion del reset.

        #10 i_instruc = 16'b0000000000011101;
        #10 i_instruc = 16'b0000100000011101;
        #10 i_instruc = 16'b0001000000011101;
        #10 i_instruc = 16'b0001100000011101;
        #10 i_instruc = 16'b0010000000000000;
        #10 i_instruc = 16'b0010100000000000;
        #10 i_instruc = 16'b0011000000000000;
        #10 i_instruc = 16'b0011100000000000;
        #10 i_instruc = 16'b0000000000000000;
        #10 i_instruc = 16'b0000100000000000;
        #10 i_instruc = 16'b0001000000000000;
        #10 i_instruc = 16'b0001100000000000;
        #10 i_instruc = 16'b0010000000000000;
        #10 i_instruc = 16'b0010100000011101;
        #10 i_instruc = 16'b0011000000011101;
        #10 i_instruc = 16'b0011100000011101;
        #10 i_instruc = 16'b0000000000011101;
        
        #10 $finish;
    end

    always #1 i_clk = ~i_clk;

    control #(
        .NB_INSTRUC (NB_INSTRUC),
        .NB_OPCODE  (NB_OPCODE),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR  	(NB_ADDR)
    )
    tb_control (
        // INPUTS
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .i_instruc  (i_instruc),
        // OUTPUTS
        .o_operand  (o_operand),
        .o_addr     (o_addr),
        .o_SelA     (o_SelA),
        .o_SelB     (o_SelB),
        .o_WrAcc    (o_WrAcc),
        .o_op       (o_op),
        .o_WrRam    (o_WrRam),
        .o_RdRam    (o_RdRam)
    );

endmodule
