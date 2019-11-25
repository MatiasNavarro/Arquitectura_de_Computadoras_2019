`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2019 09:50:59 PM
// Design Name: 
// Module Name: datapath
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

module datapath
#(
    parameter   NB_DATA     = 15,
                NB_OPERAND  = 11,
                NB_EXT      = 5
)
(
    //Inputs
    input                       i_clk,
    input                       i_reset,
    input   [1:0]               i_selA,
    input                       i_selB,
    input                       i_WrAcc,
    input                       i_Op,
    input   [NB_OPERAND-1:0]    i_Operand,
    input   [NB_DATA-1:0]       i_data_memory,
    //Outputs
    output  [NB_OPERAND-1:0]    o_Addr,
    output  [NB_DATA-1:0]       o_data_memory
);

    reg [NB_DATA-1:0]    mux_a_out;
    reg [NB_DATA-1:0]    mux_b_out;
    reg [NB_DATA-1:0]    op_out;
    reg [NB_DATA-1:0]    acc;   
    reg [NB_DATA-1:0]    signal_extension;

    //Signal Extension 
    always @(*) begin
        signal_extension = {{NB_EXT{i_Operand[NB_OPERAND-1]}},i_Operand}; //Extension del MSB del i_Operand
    end

    //mux_A
    always @(*)begin
        case(i_selA)
            2'b00:     mux_a_out = i_data_memory;
            2'b01:     mux_a_out = signal_extension;
            2'b10:     mux_a_out = op_out;
            default:   mux_a_out = 0; 
        endcase
    end

    //mux_B
    always @(*) begin
        case(i_selB)
            1'b0:   i_data_memory;
            1'b1:   signal_extension;
        endcase
    end

    //ACC
    always @(posedge i_clk) begin
        if(!i_rst)
            acc <= {(NB_DATA-1){1'b0}};
        else begin
            if(i_WrAcc)
                acc <= mux_a_out;
            else
                acc <= acc;
        end
    end

    //Operacion
    always @(*) begin
        case(i_Op)
            1'b0:   op_out = acc - mux_b_out;
            1'b1:   op_out = acc + mux_b_out;
        endcase
    end

    assign o_Addr           = i_Operand;
    assign o_data_memory    = acc; 

endmodule