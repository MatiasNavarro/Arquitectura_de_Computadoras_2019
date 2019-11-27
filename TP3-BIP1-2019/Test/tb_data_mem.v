`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2019 09:27:49
// Design Name: 
// Module Name: tb_data_mem
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


module tb_data_mem();
    parameter   RAM_WIDTH = 16;                     // Specify RAM data width
    parameter   RAM_DEPTH = 1024;                   // Specify RAM depth (number of entries)
    parameter   RAM_PERFORMANCE = "LOW_LATENCY";    // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    parameter   INIT_FILE = "";                     // Specify name/location of RAM initialization file if using one (leave blank if not)

    //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.

    //Inputs
    reg [11-1:0]                    i_addr;         // Address bus, width determined from RAM_DEPTH
    reg [RAM_WIDTH-1:0]             i_data;         // RAM input data
    reg i_clk;                                      // Clock
    reg wea;                                        // Write enable

    //Outputs
    wire [RAM_WIDTH-1:0]            o_data;         // RAM output data

    initial begin
        i_clk   = 1'b0;
        wea     = 1'b0;
        i_addr  = 0;
        i_data  = 0;
        
        #100
        i_data  = 16'h000f;         //Dato a guardar
        wea     = 1;                //Ahora escribo el dato 
        #10 
        wea     = 0;                //Wr = off
        
        #100
        i_addr  = 11'b00000000010;  //Cambio la direccion de memoria
        i_data  = 16'h00ff;         //Dato a guardar
        wea     = 1;                //Ahora escribo el dato
        #10
        wea     = 0;                //Wr = off
        
        #100
        i_addr  = 11'b00000000000;  //Leo el primer dato
        #100
        i_addr  = 11'b00000000010;  //Leo el segundo dato
        
            
        
        #100 $finish;
        
        
    end
    
    always #2.5 i_clk = ~i_clk;                     //Simulacion del clock

    data_mem #(
        .RAM_WIDTH          (RAM_WIDTH),
        .RAM_DEPTH          (RAM_DEPTH),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE),
        .INIT_FILE          (INIT_FILE)
    )
    u_data_mem
    (
        .i_addr     (i_addr),
        .i_data     (i_data),
        .i_clk      (i_clk),
        .wea        (wea),
        .o_data     (o_data)
    );
    
       
endmodule
