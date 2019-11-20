`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2019 12:45:43
// Design Name: 
// Module Name: uart_rx
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

module uart_rx
   #(
     parameter DBIT     =   8,      // # data bits
               SB_TICK  =   16      // # ticks for stop bits
   )
   (
    input   wire                    i_clk, 
    input   wire                    i_reset,
    input   wire                    rx, 
    input   wire                    s_tick,
    output  reg                     rx_done_tick,
    output  wire    [DBIT-1:0]      o_data_out
   );

   // symbolic state declaration
   localparam [1:0]
        idle    = 2'b00,    //Espero el bit de start
        start   = 2'b01,    //Inicializa los registros, solo se ejecuta un ciclo
        data    = 2'b10,    //Carga datos en el shift reg
        stop    = 2'b11;    //Paso los datos a out, espero el bit de stop

   // signal declaration
   reg  [1:0]       state_reg, state_next;
   reg  [3:0]       s_reg, s_next;
   reg  [2:0]       n_reg, n_next;
   reg  [DBIT-1:0]  buffer, buffer_next;

   // body
   // FSMD state & data registers
   always @(posedge i_clk, posedge i_reset)
      if (!i_reset)
         begin
            state_reg   <= idle;
            s_reg       <= 0;
            n_reg       <= 0;
            buffer      <= 0;
         end
      else
         begin
            state_reg   <= state_next;
            s_reg       <= s_next;
            n_reg       <= n_next;
            buffer      <= buffer_next;
         end

   // FSMD next-state logic 
   // Logica para el proximo estado
   always @(*)
   begin
      state_next    = state_reg;
      rx_done_tick  = 1'b0;
      s_next        = s_reg;
      n_next        = n_reg;
      buffer_next   = buffer;
      
      case (state_reg)
         idle:
            if (~rx)
               begin
                  state_next    = start;
                  s_next        = 0;
               end
         start:
            if (s_tick)
               if (s_reg==7)
                  begin
                     state_next = data;
                     s_next     = 0;
                     n_next     = 0;
                  end
               else
                  s_next = s_reg + 1;
         data:
            if (s_tick)
               if (s_reg==15)
                  begin
                     s_next         = 0;
                     buffer_next    = {rx, buffer[7:1]};
                     
                     if (n_reg==(DBIT-1))
                        state_next = stop ;
                      else
                        n_next = n_reg + 1;
                   end
               else
                  s_next = s_reg + 1;
         stop:
            if (s_tick)
               if (s_reg==(SB_TICK-1))
                  begin
                     state_next = idle;
                     rx_done_tick =1'b1;
                  end
               else
                  s_next = s_reg + 1;
      endcase
   end
   // output
   assign o_data_out = buffer;

endmodule