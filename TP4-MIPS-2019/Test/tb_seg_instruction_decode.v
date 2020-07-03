`timescale 1ns / 1ps

module tb_seg_instruction_decode();
    localparam LEN           = 32;
    localparam NB_REG        = 32;
    localparam NB_ADDRESS    = 16;
    localparam NB_OPCODE     = 6;
    localparam NB_ADDR       = 5;
    localparam NB_CTRL_EX    = 4;
    localparam NB_CTRL_M     = 3;
    localparam NB_CTRL_WB    = 2;

    //Entradas 
    reg                      i_clk;
    reg                      i_rst;
    reg [LEN-1:0]            i_PC;
    reg [LEN-1:0]            i_instruc;
    reg [NB_ADDR-1:0]        i_write_reg;
    reg [LEN-1:0]            i_write_data;
    reg                      i_RegWrite;
    
    //Salidas
    wire [LEN-1:0]           o_PC;
    wire [LEN-1:0]           o_read_data_1;
    wire [LEN-1:0]           o_read_data_2;
    wire  [LEN-1:0]          o_addr_ext;
    wire [LEN-1:0]           o_dir_jump;
    wire [NB_ADDR-1:0]       o_rt;           //instruction[20:16]
    wire [NB_ADDR-1:0]       o_rd;           //instruction[15:11]
    wire                     o_jump;
    //Control outputs 
    wire [NB_CTRL_WB-1:0]     o_ctrl_wb_bus;
    wire [NB_CTRL_M-1:0]      o_ctrl_mem_bus;
    wire [NB_CTRL_EX-1:0]     o_ctrl_exc_bus;

    initial begin
        i_clk = 1'b0;
        i_rst = 1'b0;
        i_write_data = 32'h0000abcd;
        i_PC            = 6'b111100; i_PC[25:0] = $random; 
//    i_instruc       = 32'b00000000;
        i_write_reg     = 5'b00010;
        i_RegWrite      = 1'b0;

        #5 i_rst = 1'b1;
        
        #20 i_instruc = 32'h01094020;    //R-Type
            i_RegWrite          = 1'b1;        
        #20 i_instruc = 32'h8c034020;    //LW
            i_RegWrite          = 1'b1;
        #20 i_instruc = 32'hac040005;    //SW
            i_RegWrite          = 1'b0;
        #20 i_instruc = 32'h10080005;    //J-Type
        #20 i_instruc[31-26] = 6'b000010 ; i_instruc[25:0] = $random;
        
        #10 $finish;
    end

    always #2.5 i_clk = ~i_clk;

    seg_instruction_decode 
    #(
        .LEN        (LEN        ),
        .NB_REG     (NB_REG     ),
        .NB_ADDRESS (NB_ADDRESS ),
        .NB_OPCODE  (NB_OPCODE  ),
        .NB_ADDR    (NB_ADDR    ),
        .NB_CTRL_EX (NB_CTRL_EX ),
        .NB_CTRL_M  (NB_CTRL_M  ),
        .NB_CTRL_WB (NB_CTRL_WB )
    )
    u_seg_instruction_decode(
    	.i_clk          (i_clk          ),
        .i_rst          (i_rst          ),
        .i_PC           (i_PC           ),
        .i_instruc      (i_instruc      ),
        .i_write_reg    (i_write_reg    ),
        .i_write_data   (i_write_data   ),
        .i_RegWrite     (i_RegWrite     ),
        .o_PC           (o_PC           ),
        .o_read_data_1  (o_read_data_1  ),
        .o_read_data_2  (o_read_data_2  ),
        .o_addr_ext     (o_addr_ext     ),
        .o_dir_jump     (o_dir_jump     ),
        .o_rt           (o_rt           ),
        .o_rd           (o_rd           ),
        .o_jump         (o_jump         ),
        .o_ctrl_wb_bus  (o_ctrl_wb_bus  ),
        .o_ctrl_mem_bus (o_ctrl_mem_bus ),
        .o_ctrl_exc_bus (o_ctrl_exc_bus )
    );

endmodule