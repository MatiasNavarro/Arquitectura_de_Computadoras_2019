`timescale 1ns / 1ps

module seg_memory_access
    #( parameter    LEN             = 32,
                    NB_ADDR         = 5,
                    NB_CTRL_WB      = 2,
                    NB_CTRL_M       = 3,
                    //DATA MEMORY
                    RAM_WIDTH_DATA          = 32,
                    RAM_DEPTH_DATA          = 2048, 
                    RAM_PERFORMANCE_DATA    = "LOW_LATENCY",
                    INIT_FILE_DATA          = ""
    )
    (
        // INPUTS
        input wire                      i_clk,
        input wire                      i_rst,
        input wire  [LEN - 1 : 0]       i_PC_branch,        //Branch o Jump 
        input wire  [LEN - 1 : 0]       i_ALU_result,       //Address (Data Memory)
        input wire  [LEN - 1 : 0]       i_write_data,
        input wire  [NB_ADDR-1:0]       i_write_register,
        input wire                      i_ALU_zero,
        //Control inputs
        input wire  [NB_CTRL_WB-1:0]    i_ctrl_wb_bus,      //[RegWrite, MemtoReg]
        input wire  [NB_CTRL_M-1:0]     i_ctrl_mem_bus,     //[Branch, MemRead, MemWrite]
        // OUTPUTS
        output wire                     o_PCSrc,
        output wire [LEN - 1 : 0]       o_PC_branch,
        output wire [LEN - 1 : 0]       o_read_data,
        output wire [LEN - 1 : 0]       o_address,
        output wire [NB_ADDR-1:0]       o_write_register,
        //Control outputs 
        output wire [NB_CTRL_WB-1:0]    o_ctrl_wb_bus
    );
    
    
    //Control mem 
    wire MemWrite;
    wire MemRead;
    wire Branch;
    assign Branch   = i_ctrl_mem_bus[2];
    assign MemRead  = i_ctrl_mem_bus[1];
    assign MemWrite = i_ctrl_mem_bus[0];
    
    //Memory control wires
    wire rsta;
    wire regcea;
    assign rsta     = 0;
    assign regcea   = 0;
    
    //Outputs 
    assign o_PCSrc          = (Branch & i_ALU_zero);
    assign o_PC_branch      = i_PC_branch;
    assign o_address        = i_ALU_result;
    assign o_write_register = i_write_register;

    //Control 
    assign o_ctrl_wb_bus    = i_ctrl_wb_bus;


    //DATA MEMORY
    mem_data #(
        .RAM_WIDTH          (RAM_WIDTH_DATA),
        .RAM_DEPTH          (RAM_DEPTH_DATA),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE_DATA),
        .INIT_FILE          (INIT_FILE_DATA)
    )
    u_data_mem
    (
        .i_addr     (i_ALU_result),
        .i_data     (i_write_data),
        .i_clk      (i_clk),
        .i_wea      (MemWrite),
        .i_ena      (MemRead),
        .i_rsta     (rsta),
        .i_regcea   (regcea),
        .o_data     (o_read_data)
    );

endmodule
