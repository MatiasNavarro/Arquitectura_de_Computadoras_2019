`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2019 15:41:42
// Design Name: 
// Module Name: tb_interface_circuit
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


module tb_interface_circuit();
    
    parameter  DBIT_01  = 8;  // # buffer bits
    parameter  NB_OP_01 = 6;  // Operation bits
	           
   //INPUT
    reg                        i_clk_01;
    reg                        i_reset_01;
    reg                        i_rx_done_tick_01;
    reg      [DBIT_01-1:0]     i_rx_data_in_01;
    wire      [DBIT_01-1:0]     i_alu_data_in_01;
    //OUTPUT
	wire    [DBIT_01-1 : 0]    o_data_a_01;
	wire    [DBIT_01-1 : 0]    o_data_b_01;
	wire    [NB_OP_01-1 : 0]   o_operation_01;
    wire                       o_tx_start_01;
    wire    [DBIT_01-1:0]      o_data_out_01;

    initial begin
        i_clk_01 = 1'b0; 
        i_reset_01 = 1'b0;
        i_rx_done_tick_01 = 1'b0;
        i_rx_data_in_01 = {DBIT_01{1'b0}};
//        i_alu_data_in_01 = {DBIT_01{1'b0}};

        #10 i_reset_01 = 1'b1; // Desactivo la accion del reset.
        
        // test1 - OR
        #10
        i_rx_data_in_01 = 8'b10010110; //data a
        i_rx_done_tick_01 = 1'b1;
        #1
        i_rx_done_tick_01 = 1'b0;
        #10
        i_rx_data_in_01 = 8'b01101001; //data b
        i_rx_done_tick_01 = 1'b1;
        #1
        i_rx_done_tick_01 = 1'b0;
        #10
        i_rx_data_in_01 = 8'b00100101; //op OR
        i_rx_done_tick_01 = 1'b1;
        #1
        i_rx_done_tick_01 = 1'b0;
        
        // test2 - RESTA
        #10
        i_rx_data_in_01 = 8'd21; //data a
        i_rx_done_tick_01 = 1'b1;
        #1
        i_rx_done_tick_01 = 1'b0;
        #10
        i_rx_data_in_01 = 8'd34; //data b
        i_rx_done_tick_01 = 1'b1;
        #1
        i_rx_done_tick_01 = 1'b0;
        #10
        i_rx_data_in_01 = 8'b11100010; //op RESTA (100010)
        i_rx_done_tick_01 = 1'b1;
        #1
        i_rx_done_tick_01 = 1'b0;
        
        

        // Test 1: Envío de trama correcta.
        
        #10 $finish;
    end
    
    always #1 i_clk_01=~i_clk_01; // Simulacion de clock.

    interface_circuit #(
        .DBIT       (DBIT_01),
        .NB_OP      (NB_OP_01)
    )
    tb_interface_circuit_01 (
        .i_clk              (i_clk_01),
        .i_reset            (i_reset_01),
        .i_rx_done_tick     (i_rx_done_tick_01),
        .i_rx_data_in       (i_rx_data_in_01),
        .i_alu_data_in      (i_alu_data_in_01),
        .o_data_a           (o_data_a_01),
        .o_data_b           (o_data_b_01),
        .o_operation        (o_operation_01),
        .o_tx_start         (o_tx_start_01),
        .o_data_out         (o_data_out_01)
    );
    
    ALU #(
        .NB_DATA (DBIT_01)
    )

    u_ALU_01 (
        .i_operation (o_operation_01),
        .i_data_a (o_data_a_01),
        .i_data_b (o_data_b_01),
        .o_result (i_alu_data_in_01)
    );

endmodule
