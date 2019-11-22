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

//Listing 8.4
module top_uart
   #( //PARAMETROS
      // Default setting:
      // 19,200 baud, 8 data bits, 1 stop bit, 2^2 FIFO
      parameter DBIT = 8,                   // # data bits
                SB_TICK = 16,               // # ticks for stop bits, 16/24/32
                                            // for 1/1.5/2 stop bits
                BAUDRATE_DIVISOR = 10,      // baud rate divisor
                                            // BAUDRATE_DIVISOR = 50M/(16*baud_rate) ... 19,200BR=>163
                BAUDRATE_DIVISOR_BITS = 8,  // # bits of BAUDRATE_DIVISOR
                //FIFO_W = 2,                  // # addr bits of FIFO
                                            // # words in FIFO=2^FIFO_W
                NB_OP = 6                   //Bit number for operation
   )
   (
   //INPUTS
    input wire              i_clk, 
    input wire              i_reset,
    input wire              i_rx,
   //OUTPUTS
    output wire             o_tx
   );

   // signal declaration
   wire             tick;               //Clk (Salida del Baud Rate Generator)
   wire             rx_done_tick;       //Salida de RX - Entrada a Interface Circuit
   wire             tx_done_tick;
   wire             tx_empty;
   wire             tx_start;
   wire [DBIT-1:0]  tx_data_out; 
   wire [DBIT-1:0]  rx_data_out;        //Salida de RX - Entrada a Iterface Circuit
   wire [DBIT-1:0]  data_a;
   wire [DBIT-1:0]  data_b;   
   wire [DBIT-1:0]  o_alu;
   wire [NB_OP-1:0] operation;
   

   
   //BAUD RATE GENERATOR
    baud_rate_gen #(
        .BAUDRATE_DIVISOR       (BAUDRATE_DIVISOR),
        .BAUDRATE_DIVISOR_BITS  (BAUDRATE_DIVISOR_BITS)
    )
    u_baud_rate (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .o_tick         (tick)      
    );

// // TEST RX conectado a TX
//
//    //MODULO RECEPTOR
//    uart_rx #(
//        .DBIT           (DBIT),
//        .SB_TICK        (SB_TICK)
//    ) 
//    u_uart_rx (
//        .i_clk          (i_clk), 
//        .i_reset        (i_reset), 
//        .rx             (i_rx), 
//        .s_tick         (tick),
//        .rx_done_tick   (rx_done_tick), 
//        .o_data_out     (rx_data_out)
//      );
//    //MODULO TRANSMISOR 
//    uart_tx #(
//        .DBIT           (DBIT),
//        .SB_TICK        (SB_TICK)
//    ) 
//    u_uart_tx (
//        .i_clk          (i_clk), 
//        .i_reset        (i_reset), 
//        .tx_start       (rx_done_tick),
//        .s_tick         (tick), 
//        .din            (rx_data_out),
//        .tx_done_tick   (tx_done_tick), 
//        .tx             (o_tx)
//    );

    //MODULO RECEPTOR
    uart_rx #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK)
    ) 
    u_uart_rx
      ( .i_clk          (i_clk),
        .i_reset        (i_reset),
        .rx             (i_rx), 
        .s_tick         (tick),
        .rx_done_tick   (rx_done_tick),
        .o_data_out     (rx_data_out)
      );
    
    //MODULO TRANSMISOR 
    uart_tx  #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK)
    ) 
    u_uart_tx
      ( .i_clk          (i_clk), 
        .i_reset        (i_reset), 
        .tx_start       (tx_start),
        .s_tick         (tick), 
        .din            (tx_data_out),
        .tx_done_tick   (tx_done_tick), 
        .tx             (o_tx)
      );
      
    //MODULO INTERFAZ
    interface_circuit #(
        .DBIT(DBIT),
        .NB_OP(NB_OP)
    )
    u_interface_circuit
    (   //Input
        .i_clk            (i_clk),
        .i_reset          (i_reset),
        .i_rx_done_tick   (rx_done_tick),
        .i_rx_data_in     (rx_data_out),
        .i_alu_data_in    (o_alu),
        //Output
        .o_data_a         (data_a),
        .o_data_b         (data_b),
        .o_operation      (operation),  
        .o_tx_start       (tx_start), 
        .o_data_out       (tx_data_out)
    );
    
    //ALU
    ALU #(
        .NB_DATA(DBIT),
        .NB_OP(NB_OP)
    )
    u_ALU
    (   .i_data_a       (data_a),
        .i_data_b       (data_b),
        .i_operation    (operation),
        .o_result       (o_alu)
    );
       
    
    // assign tx_start = ~tx_empty;

endmodule