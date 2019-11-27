`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2019 08:28:54 PM
// Design Name: 
// Module Name: tb_instruction_decoder
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


module tb_instruction_decoder();

    parameter NB_OPCODE = 5;

    // INPUTS
    reg                     i_rst;
    reg [NB_OPCODE - 1 : 0] i_opcode;
    // OUTPUTS
    wire         o_WrPC;
    wire [1 : 0] o_SelA;
    wire         o_SelB;
    wire         o_WrAcc;
    wire         o_op;       //operation
    wire         o_WrRam;
    wire         o_RdRam;

    initial begin
        i_rst = 1'b0;
        i_opcode = {NB_OPCODE{1'b0}};

        #10 i_rst = 1'b1; // Desactivo la accion del reset.

        #10 i_opcode = 5'b00000;
        #10 i_opcode = 5'b00001;
        #10 i_opcode = 5'b00010;
        #10 i_opcode = 5'b00011;
        #10 i_opcode = 5'b00100;
        #10 i_opcode = 5'b00101;
        #10 i_opcode = 5'b00110;
        #10 i_opcode = 5'b00111;
        #10 i_opcode = 5'b00000;
        
        #10 $finish;
    end

    instruction_decoder #(
        .NB_OPCODE  (NB_OPCODE)
    )
    tb_instruction_decoder (
        // INPUTS
        .i_rst      (i_rst),
        .i_opcode   (i_opcode),
        // OUTPUTS
        .o_WrPC     (o_WrPC),
        .o_SelA     (o_SelA),
        .o_SelB     (o_SelB),
        .o_WrAcc    (o_WrAcc),
        .o_op       (o_op),
        .o_WrRam    (o_WrRam),
        .o_RdRam    (o_RdRam)
    );

endmodule
