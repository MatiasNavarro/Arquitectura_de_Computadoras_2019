`timescale 1ns / 1ps

module seg_write_back
    #( parameter    NB_DATA         = 16,
                    NB_CTRL_WB      = 2
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_ADDR -1 : 0]         i_read_data,
        input wire [NB_ADDR - 1 : 0]        i_address,
        input wire [NB_CTRL_WB - 1 : 0]     i_control,
        // OUTPUTS
        output wire [NB_ADDR -1 : 0]        o_write_data
    );

endmodule
