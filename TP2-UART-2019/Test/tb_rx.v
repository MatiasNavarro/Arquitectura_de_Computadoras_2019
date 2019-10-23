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


module rx_tb();
    //Parametros
    parameter DBIT_TEST     = 8;
    parameter SB_TICK_TEST  = 16;
    
    //Todo puerto de salida del modulo es un cable
    //Todo puerto de estimulo o generacion de entradas es un registro
    
    //Entradas
    reg                         clock;      //i_clk	
    reg                         stick;      //s_tick
    reg                         bit_rx;     //i_rx
    reg                         reset;      //i_rst
    wire    [DBIT_TEST - 1: 0 ] d_out;      //data_out
    wire                        rx_done;    //rx_done_tick

    initial begin
        clock = 1'b0;
        stick = 1'b0;
        reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).
        bit_rx = 1'b1;
        #10 reset = 1'b1; // Desactivo la accion del reset.
        

        // Test 1: Envío de trama correcta.
        #160 bit_rx = 1'b0; //bit inicio
        
        #160 bit_rx = 1'b1; // dato - 8 bits (1001 0110)
        #160 bit_rx = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
        #160 bit_rx = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
        #160 bit_rx = 1'b1; // entonces 16 * 10 = 160
        #160 bit_rx = 1'b0;
        #160 bit_rx = 1'b1;
        #160 bit_rx = 1'b1;
        #160 bit_rx = 1'b0;
        
        #160 bit_rx = 1'b1; //bits stop
        #160 bit_rx = 1'b1; //bits stop

        // Test 2: Envío de trama errónea.
        #160 bit_rx = 1'b0; //bit inicio
        
        #160 bit_rx = 1'b1; // dato - 8 bits (1001 0110)
        #160 bit_rx = 1'b0; // 160 viene dado porque cada 5 instantes de tiempo cambia el estado del rate
        #160 bit_rx = 1'b0; // o sea, cada 10 instantes de tiempo hay un nuevo tick
        #160 bit_rx = 1'b1; // entonces 16 * 10 = 160
        #160 bit_rx = 1'b0;
        #160 bit_rx = 1'b1;
        #160 bit_rx = 1'b1;
        #160 bit_rx = 1'b0;
        
        #160 bit_rx = 1'b1; //bits stop
        #160 bit_rx = 1'b0; //bits stop mal.


        
        // Test 3: Prueba reset.
        #10000 reset = 1'b0; // Reset.
        #10000 reset = 1'b1; // Desactivo el reset.
        
        
        #500000 $finish;
    end
    
    always #2.5 clock=~clock;  // Simulacion de clock.
    always #5 stick=~stick;       // Simulacion de rate.
    
//Modulo para pasarle los estimulos del banco de pruebas.
uart_rx
    #(
         .DBIT (DBIT_TEST),
         .SB_TICK(SB_TICK_TEST)
     ) 
    u_rx_1    // Una sola instancia de este modulo.
    (
      .s_tick (stick),
      .rx (bit_rx),
      .i_reset (reset),
      .i_clk (clock),
      .rx_done_tick (rx_done),
      .data_out (d_out)
    );

endmodule