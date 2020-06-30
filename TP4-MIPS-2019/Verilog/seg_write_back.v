`timescale 1ns / 1ps

module seg_write_back
    #(  parameter   LEN             = 32,
        parameter   NB_ADDR         = 5,
        parameter   NB_CTRL_WB      = 2
    )
    (
        // INPUTS
//        input wire [NB_DATA-1 : 0]  i_address,
        input wire                  i_clk,
        input wire [LEN-1 : 0]      i_read_data,
        input wire [LEN-1 : 0]      i_address,
        input wire [NB_ADDR-1:0]    i_write_register,
        //Control Inputs
        input wire [NB_CTRL_WB-1:0] i_ctrl_wb_bus,       //[RegWrite, MemtoReg]
        
        // OUTPUTS
        output wire                 o_RegWrite,
        output wire [LEN -1 : 0]    o_write_data,
        output wire [NB_ADDR-1:0]   o_write_register
    );
    
    //Control wires
    wire    MemtoReg;

    //Control bits    
    assign o_RegWrite       = i_ctrl_wb_bus[1];
    assign MemtoReg         = i_ctrl_wb_bus[0];

    assign o_write_register = i_write_register;

    assign o_write_data     = (MemtoReg) ? i_data_mem : i_alu_mem; //MUX 

endmodule
