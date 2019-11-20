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
    //parameter FIFO_W_01 = 2;                  // # addr bits of FIFO
                                // # words in FIFO=2^FIFO_W
    parameter NB_OP_01 = 6;

   //INPUTS
    reg              i_clk_01; 
    reg              i_reset_01;
    reg              rd_uart_01;
    reg              wr_uart_01;
    reg              rx_01;
    reg  [DBIT_01-1:0]  w_data_01;
   //OUTPUTS
    wire             tx_full_01; 
    wire             rx_empty_01; 
    wire             tx_01;
    wire [DBIT_01-1:0]  r_data_01;

    initial begin
        i_clk_01 = 1'b0; 
        i_reset_01 = 1'b0;
        rd_uart_01 = 1'b0;
        wr_uart_01 = 1'b0;
        rx_01 = 1'b1;

        #10 i_reset_01 = 1'b1; // Desactivo la accion del reset.
        

        // Test 1: Envío de trama correcta.
        #104167 rx_01 = 1'b1; //nada
        #104167 rx_01 = 1'b0; //bit inicio
        
        #104167 rx_01 = 1'b1; // dato - 8 bits (0110 1001)
        #104167 rx_01 = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
        #104167 rx_01 = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
        #104167 rx_01 = 1'b1; // entonces 16 * 10 = 160
        #104167 rx_01 = 1'b0;
        #104167 rx_01 = 1'b1;
        #104167 rx_01 = 1'b1;
        #104167 rx_01 = 1'b0;
        
        #104167 rx_01 = 1'b1; //bits stop
        #104167 rx_01 = 1'b1; //bits stop
        #104167 rx_01 = 1'b1; //bits stop
        #104167 rx_01 = 1'b1; //bits stop

        // Test 2: Envío de trama errónea.
        #104167 rx_01 = 1'b0; //bit inicio
        
        #104167 rx_01 = 1'b1; // dato - 8 bits (1001 0110)
        #104167 rx_01 = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
        #104167 rx_01 = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
        #104167 rx_01 = 1'b1; // entonces 16 * 10 = 160
        #104167 rx_01 = 1'b0;
        #104167 rx_01 = 1'b1;
        #104167 rx_01 = 1'b1;
        #104167 rx_01 = 1'b0;
        
        #104167 rx_01 = 1'b1; //bits stop


        
        // Test 3: Prueba reset.
        //#10000 rst = 1'b0; // Reset.
        //#10000 rst = 1'b1; // Desactivo el reset.
        
        
        #3125010 $finish;
    end
    
    always #5 i_clk_01=~i_clk_01; // Simulacion de clock.

    top_uart #(
            .DBIT                   (DBIT_01),
            .SB_TICK                (SB_TICK_01),
            .BAUDRATE_DIVISOR       (BAUDRATE_DIVISOR_01),
            .BAUDRATE_DIVISOR_BITS  (BAUDRATE_DIVISOR_BITS_01),
            //.FIFO_W                 (FIFO_W_01),
            .NB_OP                  (NB_OP_01)
        )
    top_uart_01 (
        .i_clk      (i_clk_01),
        .i_reset    (i_reset_01),
        .rd_uart    (rd_uart_01),
        .wr_uart    (wr_uart_01),
        .rx         (rx_01),
        .w_data     (w_data_01),
        .tx_full    (tx_full_01),
        .rx_empty   (rx_empty_01),
        .tx         (tx_01),
        .r_data     (r_data_01)
        );

endmodule