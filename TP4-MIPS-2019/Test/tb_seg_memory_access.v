`timescale 1ns / 1ps

module tb_seg_memory_access();
    localparam LEN             = 32;
    localparam NB_ADDR         = 5;
    localparam NB_CTRL_WB      = 2;
    localparam NB_CTRL_M       = 3;
    //DATA MEMORY
    localparam RAM_WIDTH_DATA          = 32;
    localparam RAM_DEPTH_DATA          = 21; 
    localparam RAM_PERFORMANCE_DATA    = "LOW_LATENCY";
    localparam INIT_FILE_DATA          = "C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\init_mem_memory_access.mem";

    // INPUTS
    reg                      i_clk;
    reg                      i_rst;
    reg  [LEN - 1 : 0]       i_PC_branch;        //Branch o Jump 
    reg  [LEN - 1 : 0]       i_ALU_result;       //Address (Data Memory)
    reg  [LEN - 1 : 0]       i_write_data;
    reg  [NB_ADDR-1:0]       i_write_register;
    wire                     i_ALU_zero;
    //Control inputs
    reg  [NB_CTRL_WB-1:0]    i_ctrl_wb_bus;      //[RegWrite, MemtoReg]
    reg  [NB_CTRL_M-1:0]     i_ctrl_mem_bus;     //[Branch, MemRead, MemWrite]
    // OUTPUTS
    wire                     o_PCSrc;
    wire [LEN - 1 : 0]       o_PC_branch;
    wire [LEN - 1 : 0]       o_read_data;
    wire [LEN - 1 : 0]       o_address;
    wire [NB_ADDR-1:0]       o_write_register;
    //Control outputs 
    wire [NB_CTRL_WB-1:0]    o_ctrl_wb_bus;

    assign i_ALU_zero = (i_ALU_result == 0) ? 1'b1 : 1'b0;

    initial begin
        i_clk = 1'b0;
        i_rst = 1'b0;
        i_PC_branch = {LEN{1'b0}};
        i_ALU_result = {LEN{1'b0}};
        i_write_data = {LEN{1'b0}};
        i_write_register = {NB_ADDR{1'b0}};
        i_ctrl_wb_bus = {NB_CTRL_WB{1'b0}};
        i_ctrl_mem_bus = {NB_CTRL_M{1'b0}};
        
        #4
        i_rst = 1'b1;
        i_ALU_result = 32'd1;
        i_write_data = 32'hF6F6F6F6;
        i_write_register = 5'b10101;
        i_ctrl_wb_bus = 2'b11;
        i_ctrl_mem_bus = 3'b001;

        #2 i_ALU_result = 32'd2;
        #2 i_ALU_result = 32'd5;
        #2 i_ALU_result = 32'd6;
        #2 i_ALU_result = 32'd7;
        #2 i_ALU_result = 32'd20;

        #4 
        i_ALU_result = 32'd0;
        i_ctrl_mem_bus = 3'b110;
        i_ctrl_wb_bus = 2'b11;
        
        #2 i_ALU_result = 32'd1;
        #2 i_ALU_result = 32'd2;
        #2 i_ALU_result = 32'd3;
        #2 i_ALU_result = 32'd19;
        #2 i_ALU_result = 32'd20;
        
        #4 
        i_ALU_result = 32'd13;
        i_ctrl_mem_bus = 3'b111;
        i_write_data = 32'hA5DFA5DF;
        
        #2 i_ALU_result = 32'd14;
        #2 i_ALU_result = 32'd15;
        #2 i_ALU_result = 32'd8;
        #2 i_ALU_result = 32'd9;
        
        #2 $finish;
    end

    always #1 i_clk = ~i_clk;

    always #2 i_PC_branch = o_PC_branch + 1;

    seg_memory_access 
    #(
        .LEN                  (LEN                  ),
        .NB_ADDR              (NB_ADDR              ),
        .NB_CTRL_WB           (NB_CTRL_WB           ),
        .NB_CTRL_M            (NB_CTRL_M            ),
        .RAM_WIDTH_DATA       (RAM_WIDTH_DATA       ),
        .RAM_DEPTH_DATA       (RAM_DEPTH_DATA       ),
        .RAM_PERFORMANCE_DATA (RAM_PERFORMANCE_DATA ),
        .INIT_FILE_DATA       (INIT_FILE_DATA       )
    )
    u_seg_memory_access(
    	.i_clk            (i_clk            ),
        .i_rst            (i_rst            ),
        .i_PC_branch      (i_PC_branch      ),
        .i_ALU_result     (i_ALU_result     ),
        .i_write_data     (i_write_data     ),
        .i_write_register (i_write_register ),
        .i_ALU_zero       (i_ALU_zero       ),
        .i_ctrl_wb_bus    (i_ctrl_wb_bus    ),
        .i_ctrl_mem_bus   (i_ctrl_mem_bus   ),
        .o_PCSrc          (o_PCSrc          ),
        .o_PC_branch      (o_PC_branch      ),
        .o_read_data      (o_read_data      ),
        .o_address        (o_address        ),
        .o_write_register (o_write_register ),
        .o_ctrl_wb_bus    (o_ctrl_wb_bus    )
    );
    

endmodule
