`timescale 1ns / 1ps

module seg_memory_access
    #( parameter    LEN             = 32,
                    NB_ADDR         = 5,
                    NB_CTRL_WB      = 2,
                    NB_CTRL_M       = 9,
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
        input wire  [LEN - 1 : 0]       i_PC_branch,        //Branch
        input wire  [LEN - 1 : 0]       i_ALU_result,       //Address (Data Memory)
        input wire  [LEN - 1 : 0]       i_write_data,
        input wire  [NB_ADDR-1:0]       i_write_register,
        input wire                      i_ALU_zero,
        //Control inputs
        input wire  [NB_CTRL_WB-1:0]    i_ctrl_wb_bus,      // [RegWrite, MemtoReg]
        input wire  [NB_CTRL_M-1:0]     i_ctrl_mem_bus,     // [SB, SH, LB, LH, Unsigned, BNEQ, Branch, MemRead, MemWrite]
        // OUTPUTS
        output wire                     o_PCSrc,
        output wire [LEN - 1 : 0]       o_PC_branch,
        output wire [LEN - 1 : 0]       o_read_data,
        output wire [LEN - 1 : 0]       o_address,
        output wire [NB_ADDR-1:0]       o_write_register,
        //Control outputs 
        output wire [NB_CTRL_WB-1:0]    o_ctrl_wb_bus
    );
    
    //Memory wires
    wire ena;
    wire rsta;
    wire regcea;
    
    //Control mem 
    wire MemWrite;
    wire MemRead;
    wire Branch;
    wire BNEQ;
    wire SB_flag;
    wire SH_flag;
    wire LB_flag;
    wire LH_flag;
    wire Unsigned_flag;
    
    assign BNEQ     = i_ctrl_mem_bus[3];
    assign Branch   = i_ctrl_mem_bus[2];
    assign MemRead  = i_ctrl_mem_bus[1];
    assign MemWrite = i_ctrl_mem_bus[0];

    assign SB_flag = i_ctrl_mem_bus[8];
    assign SH_flag = i_ctrl_mem_bus[7];
    assign LB_flag = i_ctrl_mem_bus[6];
    assign LH_flag = i_ctrl_mem_bus[5];
    assign Unsigned_flag = i_ctrl_mem_bus[4];
    
    //Memory control
    assign ena      = 1;
    assign rsta     = 0;
    assign regcea   = 0;
    
    //Outputs 
    assign o_PCSrc          = (Branch && i_ALU_zero) || (BNEQ && !i_ALU_zero);
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
        .i_addr             (i_ALU_result),
        .i_data             (i_write_data),
        .i_clk              (i_clk),
        .i_wea              (MemWrite),
        .i_ena              (ena),
        .i_rsta             (rsta),
        .i_regcea           (regcea),
        .i_SB_flag          (SB_flag),
        .i_SH_flag          (SH_flag),
        .i_LB_flag          (LB_flag),
        .i_LH_flag          (LH_flag),
        .i_Unsigned_flag    (Unsigned_flag),
        .o_data             (o_read_data)
    );

endmodule
