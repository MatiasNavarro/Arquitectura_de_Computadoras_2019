`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2019 20:32:39
// Design Name: 
// Module Name: baud_rate_gen
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


/*Imagine that the baud rate you want to work with is 9600. The clock of my
FPGA is 50MHz. If we want the "TICKS" to ahev 16 times the frequency of the UART signal
we need a frequency 16 times the 9600Hz. 
The width of the UART signal is 1/9600 equal to 104us. The width of the main clock is 1/50Mhz equal to 20ns
How many 20ns pulses we need to cont to get to 104us/16??? Well (104000ns/16)/ 20ns = 325 pulses (
That's why in the top we set baud rate to 325)
*/
module baud_rate_gen
    #(
    parameter   BAUDRATE_DIVISOR = 326,     // 50.000.000 / (16 * 9600)
                BAUDRATE_DIVISOR_BITS = 10
    )
    (
    input   wire            i_clk,      // Clock input
    input   wire            i_reset,      // Reset input
    // input   wire    [15:0]  i_baudrate, // Value to divide the generator by
    output  wire            o_tick      // Each "BaudRate" pulses we create a tick pulse
    );

reg [BAUDRATE_DIVISOR_BITS:0] baudRateReg; // Register used to count


always @(posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
        baudRateReg <= {BAUDRATE_DIVISOR_BITS{1'b0}};
    end else if (o_tick) begin
        baudRateReg <= {BAUDRATE_DIVISOR_BITS{1'b0}};
    end else begin
        baudRateReg <= baudRateReg + 1;
    end
end
assign o_tick = (baudRateReg == BAUDRATE_DIVISOR);
endmodule
