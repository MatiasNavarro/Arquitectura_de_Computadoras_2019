`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2019 20:47:05
// Design Name: 
// Module Name: tb_rx
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

module tb_tx();

    // Parametros
    parameter DBIT_TEST     = 8;
    parameter SB_TICK_TEST  = 16;
    
    //Todo puerto de salida del modulo es un cable.
    //Todo puerto de estimulo o generacion de entrada es un registro.
    
    // Entradas.
    reg                 clock;      // Clock.
    reg                 stick;      //s_tick
    reg                 rst;        // Reset.
    reg                 tx_st;      //tx_start
    reg [DBIT_TEST-1:0] data_in;    //din                   
    wire                bit_tx;     //tx 
    wire                tx_done;    //tx_done_tick



    initial	begin
        stick = 1'b0;
        clock = 1'b0;
        rst = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
        data_in = 8'b00000000;
        tx_st = 1'b0;
        #10 rst = 1'b1; // Desactivo la accion del reset.
        
        // Test 1: Envío de dato.
        #160 data_in = 8'b10010110; // Dato a enviar
        
        #160 tx_st = 1'b1; // Enviar ahora
        #100 tx_st = 1'b0;
    
        // Test 2: Envío de dato.
        #1160 data_in = 8'b10000110; // Dato a enviar
        #160 tx_st = 1'b1; // Enviar ahora
        #100 tx_st = 1'b0; 
        
        // Test 3: Prueba tx_start.
        #1000 tx_st = 1'b1; // Enviar ahora
        #100 tx_st = 1'b0; 
                
        // Test 4: Prueba reset.
        #10000 rst = 1'b0; // Reset.
        #10000 rst = 1'b1; // Desactivo el reset.
        
        
        #500000 $finish;
    end

always #2.5 clock=~clock;  // Simulacion de clock.
always #5 stick=~stick;  // Simulacion de rate.


// Modulo para pasarle los estimulos del banco de pruebas.
uart_tx
#(
     .WIDTH_WORD_TX (DBIT_TEST),
     .CANT_BIT_STOP (SB_TICK_TEST)
 ) 
u_tx_1    
(
  .i_clk (clock),
  .s_tick (stick),
  .din (data_in),
  .reset (rst),
  .tx_start (tx_st),
  .tx (bit_tx),
  .tx_done_tick (tx_done)
);

endmodule