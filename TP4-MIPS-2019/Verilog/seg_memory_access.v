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
    wire rsta;
    wire regcea;
    wire [LEN - 1 : 0] read_data;
    wire [LEN - 1 : 0] write_data;
    wire [1 : 0] store_size; // 00=Word, 01=Halfword, 10=Byte
    
    //Control mem 
    wire    MemWrite;
    wire    MemRead;
    wire    Branch;
    
    assign Branch   = i_ctrl_mem_bus[2];
    assign MemRead  = i_ctrl_mem_bus[1];
    assign MemWrite = i_ctrl_mem_bus[0];

    assign SB_flag = i_ctrl_mem_bus[8];
    assign SH_flag = i_ctrl_mem_bus[7];
    assign LB_flag = i_ctrl_mem_bus[6];
    assign LH_flag = i_ctrl_mem_bus[5];
    assign Unsigned_flag = i_ctrl_mem_bus[4];
    
    //Memory control
    assign rsta     = 0;
    assign regcea   = 0;
    
    //Outputs 
    assign o_PCSrc          = (Branch & i_ALU_zero);
    assign o_PC_branch      = i_PC_branch;
    assign o_address        = i_ALU_result;
    assign o_write_register = i_write_register;

    assign o_read_data =    (LB_flag) ? (Unsigned_flag) ? {{24{read_data[7]}}, read_data[7:0]} : {{24{1'b0}}, read_data[7:0]} :
                            (LH_flag) ? (Unsigned_flag) ? {{16{read_data[15]}}, read_data[7:0]} : {{16{1'b0}}, read_data[15:0]} :
                            read_data;
    assign store_size = (SH_flag) ? 2'b01 : (SB_flag) ? 2'b10 : 2'b00;

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
        .i_addr         (i_ALU_result),
        .i_data         (i_write_data),
        .i_clk          (i_clk),
        .i_wea          (MemWrite),
        .i_ena          (MemRead),
        .i_rsta         (rsta),
        .i_regcea       (regcea),
        .i_store_size   (store_size),
        .o_data         (read_data)
    );

endmodule
