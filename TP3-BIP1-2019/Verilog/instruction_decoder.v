`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 10:45:24 PM
// Design Name: 
// Module Name: instruction_decoder
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


module instruction_decoder #(
        parameter NB_OPCODE = 5
    )
    (
        // INPUTS
        input           i_rst,
        input           i_opcode,
        // OUTPUTS
        output          o_WrPC,
        output [1 : 0]  o_SelA,
        output          o_SelB,
        output          o_WrAcc,
        output          o_op,       //operation
        output          o_WrRam,
        output          o_RdRam
    );

    localparam [NB_OPCODE - 1 : 0]
        HLT     = 5'b00000,
        STO     = 5'b00001,
        LD      = 5'b00010,
        LDI     = 5'b00011,
        ADD     = 5'b00100,
        ADDI    = 5'b00101,
        SUB     = 5'b00110,
        SUBI    = 5'b00111;

    always @(*) begin

        if (!i_rst) begin
            o_WrPC = 1'b0;
        end
        else begin
            o_WrPC = 1'b1;
        end

        o_SelA = 2'b00;
        o_SelB = 1'b0;
        o_op = 1'b0;
        o_WrAcc = 1'b0;
        o_WrRam = 1'b0;
        o_RdRam = 1'b0;

        case(i_opcode)
            HLT:
                o_WrPC = 1'b0;
            STO:
                o_WrRam = 1'b1;
            LD:
                o_WrAcc = 1'b1;
            LDI:
                o_WrAcc = 1'b1;
                o_SelA = 2'b01;
            ADD:
                o_SelA = 2'b10;
                o_SelB = 1'b0;
                o_RdRam = 1'b1;
                o_WrAcc = 1'b1;
            ADDI:
                o_WrAcc = 1'b1;
                o_SelA = 2'b10;
                o_SelB = 1'b1;
            SUB:
                o_SelA = 2'b10;
                o_SelB = 1'b0;
                o_RdRam = 1'b1;
                o_WrAcc = 1'b1;
                o_op = 1'b1;
            SUBI:
                o_WrAcc = 1'b1;
                o_SelA = 2'b10;
                o_SelB = 1'b1;
                o_op = 1'b1;
            default:
                o_WrPC = 1'b0;
        endcase
    end

endmodule
