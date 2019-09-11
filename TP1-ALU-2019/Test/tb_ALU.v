`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2019 21:02:59
// Design Name: 
// Module Name: tb_ALU
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


module tb_ALU();
  
  //local parameters
  localparam    NB_DATA_01      = 8;
  localparam    NB_OP           = 6;

  //inputs
  reg [NB_OP-1:0] i_operation_01;
  reg [NB_DATA_01 - 1: 0] i_data_a_01;
  reg [NB_DATA_01 - 1: 0] i_data_b_01;
  //outputs
  wire signed [NB_DATA_01 - 1: 0] o_result_01;
  
  initial begin
    #0
    $dumpfile("dump.vcd");
    $dumpvars(1);
    $monitor("t=%3d x=%4b o=%4b",$time,i_operation_01, o_result_01);
    i_operation_01 = 6'b100000;
    i_data_a_01 = {NB_DATA_01{1'b0}};
    i_data_b_01 = {NB_DATA_01{1'b0}};
    #20
    i_operation_01 = 6'b100010;
    #20
    i_operation_01 = 6'b100100;
    #20
    i_operation_01 = 6'b100101;
    #20
    i_operation_01 = 6'b100110;
    #20
    i_operation_01 = 6'b000011;
    #20
    i_operation_01 = 6'b000010;
    #20
    i_operation_01 = 6'b100111;
    #20
    $finish;
  end // initial

  always begin
  #10
    i_data_a_01 = $random;
    i_data_b_01 = $random;
  end // always

  ALU
  #(
    .NB_DATA (NB_DATA_01)
  )

  u_ALU_01
  (
    .i_operation (i_operation_01),
    .i_data_a (i_data_a_01),
    .i_data_b (i_data_b_01),
    .o_result (o_result_01)
  );

endmodule
