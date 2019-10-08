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
   #( // Default setting:
      // 19,200 baud, 8 data bits, 1 stop bit, 2^2 FIFO
      parameter DBIT = 8,                   // # data bits
                SB_TICK = 16,               // # ticks for stop bits, 16/24/32
                                            // for 1/1.5/2 stop bits
                BAUDRATE_DIVISOR = 10,     // baud rate divisor
                                            // BAUDRATE_DIVISOR = 50M/(16*baud_rate) ... 19,200BR=>163
                BAUDRATE_DIVISOR_BITS = 8,  // # bits of BAUDRATE_DIVISOR
                FIFO_W = 2                  // # addr bits of FIFO
                                            // # words in FIFO=2^FIFO_W
   )
   (
    input wire          i_clk, reset,
    input wire          rd_uart, wr_uart, rx,
    input wire  [7:0]   w_data,
    output wire         tx_full, rx_empty, tx,
    output wire [7:0]   r_data
   );

   // signal declaration
   wire             tick, rx_done_tick, tx_done_tick;
   wire             tx_empty, tx_fifo_not_empty;
   wire [7:0]       tx_fifo_out, rx_data_out;

   //body
    baud_rate_gen #(.BAUDRATE_DIVISOR(BAUDRATE_DIVISOR), .BAUDRATE_DIVISOR_BITS(BAUDRATE_DIVISOR_BITS))
    u_baud_rate (
    .i_clk      (i_clk),
    .reset      (reset)/*,
    .p          ()
    .max_tick   (tick)*/
    );

    uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_rx_unit
      (.clk(i_clk), .reset(reset), .rx(rx), .s_tick(tick),
       .rx_done_tick(rx_done_tick), .dout(rx_data_out));
    
    fifo_buf #(.B(DBIT), .W(FIFO_W)) fifo_rx_unit    
      (.i_clk(i_clk), .reset(reset), .rd(rd_uart),
       .wr(rx_done_tick), .w_data(rx_data_out),
       .empty(rx_empty), .full(), .r_data(r_data));
    
    fifo_buf #(.B(DBIT), .W(FIFO_W)) fifo_tx_unit
      (.i_clk(i_clk), .reset(reset), .rd(tx_done_tick),
       .wr(wr_uart), .w_data(w_data), .empty(tx_empty),
       .full(tx_full), .r_data(tx_fifo_out));
    
    uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit
      (.i_clk(i_clk), .reset(reset), .tx_start(tx_fifo_not_empty),
       .s_tick(tick), .din(tx_fifo_out),
       .tx_done_tick(tx_done_tick), .tx(tx));
    
    assign tx_fifo_not_empty = ~tx_empty;

endmodule