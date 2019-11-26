`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 09:50:59 PM
// Design Name: 
// Module Name: control
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


module control
    #( parameter    NB_INSTRUC      = 16,
                    NB_OPCODE       = 5,
                    NB_OPERAND      = 11,
                    NB_ADRR         = 11
    )
    (
        // INPUTS
        input                           i_clk,
        input                           i_rst,
        input   [NB_INSTRUC - 1 : 0]    i_instruc,
        // OUTPUTS
        output  [NB_OPERAND - 1 : 0]    o_operand,
        output  [NB_ADRR -1 : 0]        o_addr,
        // Instruction decoder OUTPUTS
        output  [1 : 0]                 o_SelA,
        output                          o_SelB,
        output                          o_WrAcc,
        output                          o_op,       //operation
        output                          o_WrRam,
        output                          o_RdRam
    );

    wire [NB_OPCODE - 1 : 0] opcode;
    wire WrPC;

    reg [NB_ADRR - 1 : 0] pc;

    assign opcode[NB_OPCODE - 1 : 0] = i_instruc[NB_OPCODE - 1 -: NB_OPCODE];
    assign o_operand[NB_OPERAND - 1 : 0] = i_instruc[NB_OPERAND - 1 : 0];

    // Program Counter

    always @(posedge i_clk) begin
        if (!i_rst) begin
            pc <= {NB_ADRR{1'b0}};
        end
        else if (WrPC) begin
            pc <= pc + 1'b1;
        end
    end

    assign o_addr = pc;

    // MODULO - Instruction decoder

    instruction_decoder #(
        .NB_OPCODE  (NB_OPCODE)
    )
    u_instruction_decoder (
        // INPUTS
        .i_rst      (i_rst),
        .i_opcode   (opcode),
        // OUTPUTS
        .o_WrPC     (WrPC),
        .o_SelA     (o_SelA),
        .o_SelB     (o_SelB),
        .o_WrAcc    (o_WrAcc),
        .o_op       (o_op),
        .o_WrRam    (o_WrRam),
        .o_RdRam    (o_RdRam)
    );

endmodule
