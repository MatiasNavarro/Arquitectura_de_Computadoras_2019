`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2019 05:43:28 PM
// Design Name: 
// Module Name: tb_baud_rate_gen
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

module tb_baud_rate_gen();
    
  //local parameters
  localparam    BAUDRATE_DIVISOR_01         = 9;
  localparam    BAUDRATE_DIVISOR_BITS_01    = 4;

  //inputs
  reg i_clk_01;
  reg reset_01;
  //outputs
  wire o_tick_01;
  
    initial begin
        #0
        $dumpfile("dump.vcd");
        $dumpvars(1);
        //$monitor("t=%3d x=%4b o=%4b",$time,i_operation_01, o_result_01);
        reset_01 = 1;
        i_clk_01 = 0;
        #10
        reset_01 = 0;
        #10
        reset_01 = 1;
        
        #200
        $finish;
    end // initial
    
    always #1 i_clk_01 = ~i_clk_01;
    
    baud_rate_gen
    #(
    .BAUDRATE_DIVISOR       (BAUDRATE_DIVISOR_01),
    .BAUDRATE_DIVISOR_BITS  (BAUDRATE_DIVISOR_BITS_01)
    )
    
    u_baud_rate_gen_01
    (
    .i_clk (i_clk_01),
    .reset (reset_01),
    .o_tick (o_tick_01)
    );

endmodule
