`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2020 18:33:44
// Design Name: 
// Module Name: tb_seg_write_back
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


module tb_seg_write_back();
    parameter   LEN_01          = 32;
    parameter   NB_ADDR_01      = 5;
    parameter   NB_WB_BUS_01    = 2;
    
    reg                     i_clk_01;
    reg [LEN_01-1:0]        i_data_mem_01;
    reg [LEN_01-1:0]        i_alu_mem_01;
    reg [NB_WB_BUS_01-1:0]  i_wb_bus_01;
    
    wire [LEN_01-1:0]       o_write_data_01;
    
    initial
    begin
        #0
        i_clk_01        = 0;
        i_data_mem_01   = 0;
        i_alu_mem_01    = 0;
        i_wb_bus_01     = 0;
        
        #10
        i_data_mem_01   = 5'b00011;
        i_alu_mem_01    = 5'b11100;
        i_wb_bus_01     = 2'b01;
        
        #10
        i_wb_bus_01     = 2'b00;
        
        #10 $finish;        
    end
    
    always #2.5 i_clk_01 = ~i_clk_01;
    
    //Modulo para pasarle los estimulos del banco de pruebas.
    seg_write_back
    #(
        .LEN            (LEN_01),
        .NB_ADDR        (NB_ADDR_01),
        .NB_WB_BUS      (NB_WB_BUS_01)
    )
    u_seg_write_back_01
    (
        .i_clk          (i_clk_01),
        .i_data_mem     (i_data_mem_01),
        .i_alu_mem      (i_alu_mem_01),
        .i_wb_bus       (i_wb_bus_01),
        .o_write_data   (o_write_data_01)
    );
endmodule
