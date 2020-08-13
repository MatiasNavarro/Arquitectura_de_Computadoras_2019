`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.08.2020 20:17:11
// Design Name: 
// Module Name: tb_hazard_detection_unit
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

//Todo puerto de salida del modulo es un cable.
//Todo puerto de estimulo o generacion de entrada es un registro.
module tb_hazard_detection_unit();
    localparam  NB_ADDR = 5;
    //Inputs
    reg                 i_MemRead;
    reg [NB_ADDR-1:0]   i_rs_id;
    reg [NB_ADDR-1:0]   i_rt_id;
    reg [NB_ADDR-1:0]   i_rt_ex;
    //Outputs 
    wire                o_stall_flag;

    initial 
    begin
        #1  i_MemRead   = 0;
            i_rs_id     = 0;
            i_rt_id     = 0;
            i_rt_ex     = 0;

        #10 i_MemRead   = 1;            
            i_rs_id     = 6'b000100;    
            i_rt_ex     = 6'b000100;

        #10 i_rs_id     = 6'b010101;

        #10 i_rt_id     = 6'b000111;
            i_rt_ex     = 6'b000111;
        
        #10 i_MemRead   = 1'b0;
        
        
        #10 i_MemRead   = 1'b1; 
            i_rt_id     = 6'b001010;

        #10 $finish;    
    end 
    
    hazard_detection_unit #(
        .NB_ADDR    (NB_ADDR    )
    )
    u_hazard_detection_unit
    (
        .i_MemRead      (i_MemRead      ),
        .i_rs_id        (i_rs_id        ),
        .i_rt_id        (i_rt_id        ),
        .i_rt_ex        (i_rt_ex        ),
        .o_stall_flag   (o_stall_flag   )
    );


endmodule
