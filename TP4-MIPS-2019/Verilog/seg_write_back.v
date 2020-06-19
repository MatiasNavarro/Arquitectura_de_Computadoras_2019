`timescale 1ns / 1ps

module seg_write_back
    #(  parameter   NB_REG          = 32,
        parameter   NB_DATA         = 16,
        parameter   NB_CTRL_WB      = 2
    )
    (
        // INPUTS
        input wire                  i_clk,
        input wire                  i_rst,
        input wire [NB_DATA-1 : 0]  i_read_data,
        input wire [NB_DATA-1 : 0]  i_address,
        input wire [NB_REG-1 : 0]   i_data_mem,
        input wire [NB_REG-1 : 0]   i_alu_mem,
        
        //Control Inputs
        input wire                  i_MemtoReg,
        
        // OUTPUTS
        output wire [NB_REG -1 : 0] o_write_data
    );
    
    assign o_write_data = (i_MemtoReg) ? i_data_mem : i_alu_mem;

endmodule
