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
        input wire                      i_rst,
        input wire [NB_OPCODE - 1 : 0]  i_opcode,
        // OUTPUTS
        output reg         o_WrPC,
        output reg [1 : 0] o_SelA,
        output reg         o_SelB,
        output reg         o_WrAcc,
        output reg         o_op,       //operation
        output reg         o_WrRam,
        output reg         o_RdRam
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

        // SET VALORES POR DEFECTO
        // o_WrPC = 1 por defecto asi escribe el PC+1
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
            HLT: begin
                o_WrPC = 1'b0;
            end
            STO: begin
                o_WrRam = 1'b1;
            end
            LD: begin
                // o_SelA = 2'b00;
                o_WrAcc = 1'b1;
                o_RdRam = 1'b1;
            end
            LDI: begin
                o_SelA = 2'b01;
                o_WrAcc = 1'b1;
            end
            ADD: begin
                o_SelA = 2'b10;
                o_SelB = 1'b0;
                // o_op = 1'b0;
                o_WrAcc = 1'b1;
                o_RdRam = 1'b1;
            end
            ADDI: begin
                o_SelA = 2'b10;
                o_SelB = 1'b1;
                // o_op = 1'b0;
                o_WrAcc = 1'b1;
            end
            SUB: begin
                o_SelA = 2'b10;
                o_SelB = 1'b0;
                o_op = 1'b1;
                o_WrAcc = 1'b1;
                o_RdRam = 1'b1;
            end
            SUBI: begin
                o_SelA = 2'b10;
                o_SelB = 1'b1;
                o_op = 1'b1;
                o_WrAcc = 1'b1;
            end
            default: begin
                o_WrPC = 1'b0;
            end
        endcase
    end

endmodule
