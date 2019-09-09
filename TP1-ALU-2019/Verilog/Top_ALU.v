`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2019 16:13:24
// Design Name: 
// Module Name: Top_ALU
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


module Top_ALU
    //Parametros
    #(parameter 
    NB_SW = 8, 
    NB_LED = 7, 
    NB_BUT = 3
     )
    //Entradas y salidas del TOP de ALU 
    (
    input                   i_clk,
    input                   i_rst,
    input   [NB_SW-1:0]     i_sw,
    input   [NB_BUT-1:0]    i_btn,
    output  [NB_LED-1:0]    o_led
    );
   
    reg signed [NB_SW-1:0]     i_data_a;
    reg signed [NB_SW-1:0]     i_data_b;
    reg        [NB_SW-1:0]     i_operation;
    //wire       [NB_LED-1:0]    o_leds;
    
    ALU
    u_ALU(.i_data_a       (i_data_a),
          .i_data_b       (i_data_b),
          .i_operation    (i_operation),
          .o_result       (o_led)
    );
    
    always @(posedge i_clk) 
    begin
        if(i_btn[0] == 1'b1)
            i_data_a      <= i_sw;
            
        else if(i_btn[1] == 1'b1)    
            i_data_b      <= i_sw;
            
        else if(i_btn[2] == 1'b1)
            i_operation   <= i_sw;
            
        else begin
            i_data_a    <= i_data_a;
            i_data_b    <= i_data_b;
            i_operation <= i_operation;
        end   
    end
    
    
endmodule

