`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2019 14:47:12
// Design Name: 
// Module Name: top_uart
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

module tb_top_uart();
    parameter DBIT_01 = 8;                   // # data bits
    parameter SB_TICK_01 = 16;               // # ticks for stop bits, 16/24/32
                                // for 1/1.5/2 stop bits
    parameter BAUDRATE_DIVISOR_01 = 651;      // baud rate divisor
                                // BAUDRATE_DIVISOR = 50M/(16*baud_rate) ... 19,200BR=>163
    parameter BAUDRATE_DIVISOR_BITS_01 = 10;  // # bits of BAUDRATE_DIVISOR
                                // # words in FIFO=2^FIFO_W
    parameter NB_OP_01 = 6;

   //INPUTS
    reg              i_clk_01; 
    reg              i_reset_01;
    reg              i_rx_01;
   //OUTPUTS
    wire             o_tx_01;

    initial begin
        i_clk_01 = 1'b0; 
        i_reset_01 = 1'b0;
        i_rx_01 = 1'b1;

        #10 i_reset_01 = 1'b1; // Desactivo la accion del reset.
        

        // Test 1 - dato a
        #104167 i_rx_01 = 1'b1; //nada
        #104167 i_rx_01 = 1'b0; //bit inicio
        
        #104167 i_rx_01 = 1'b1; // dato - 8 bits (0110 1001)
        #104167 i_rx_01 = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
        #104167 i_rx_01 = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
        #104167 i_rx_01 = 1'b1; // entonces 16 * 10 = 160
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop

        // Test 1 - dato b
        #104167 i_rx_01 = 1'b0; //bit inicio
        
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop

        // Test 1 - op OR b00100101
        #104167 i_rx_01 = 1'b0; //bit inicio 
        
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        
        #1000000;
        // OPERACION EN ALU Y TX
        
        // Test 1 - dato a
        #104167 i_rx_01 = 1'b1; //nada
        #104167 i_rx_01 = 1'b0; //bit inicio
        
        #104167 i_rx_01 = 1'b0; // dato - 8 bits (0110 1001)
        #104167 i_rx_01 = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
        #104167 i_rx_01 = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
        #104167 i_rx_01 = 1'b0; // entonces 16 * 10 = 160
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b1;
        
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop

        // Test 1 - dato b
        #104167 i_rx_01 = 1'b0; //bit inicio
        
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop

        // Test 1 - op SUMA b00100000
        #104167 i_rx_01 = 1'b0; //bit inicio 
        
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b1;
        #104167 i_rx_01 = 1'b0;
        #104167 i_rx_01 = 1'b0;
        
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        #104167 i_rx_01 = 1'b1; //bits stop
        
        // OPERACION EN ALU Y TX
        
        #1000000 $finish;
    end
    
    always #5 i_clk_01=~i_clk_01; // Simulacion de clock.

    top_uart #(
            .DBIT                   (DBIT_01),
            .SB_TICK                (SB_TICK_01),
            .BAUDRATE_DIVISOR       (BAUDRATE_DIVISOR_01),
            .BAUDRATE_DIVISOR_BITS  (BAUDRATE_DIVISOR_BITS_01),
            .NB_OP                  (NB_OP_01)
        )
    top_uart_01 (
        .i_clk      (i_clk_01),
        .i_reset    (i_reset_01),
        .i_rx       (i_rx_01),
        .o_tx         (o_tx_01)
        );

endmodule