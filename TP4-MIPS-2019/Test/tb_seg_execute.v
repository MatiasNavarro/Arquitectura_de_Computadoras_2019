`timescale 1ns / 1ps

module tb_seg_execute();
    localparam    LEN             = 32;
    localparam    NB_ALUOP        = 2;
    localparam    NB_ALUCTL       = 4;
    localparam    NB_ADDR         = 5;
    localparam    NB_FUNC         = 6;
    localparam    NB_CTRL_WB      = 2;
    localparam    NB_CTRL_M       = 9;
    localparam    NB_CTRL_EX      = 7;

    // INPUTS
    reg                           i_clk;
    reg                           i_rst;
    reg  [LEN - 1 : 0]            i_PC;
    reg  [LEN - 1 : 0]            i_read_data_1;
    reg  [LEN - 1 : 0]            i_read_data_2;
    wire [LEN - 1 : 0]            i_addr_ext;         // instruction[15:0] extendida a 32 bits
    wire [NB_ADDR - 1 : 0]        i_rt;               // instruction[20:16]
    wire [NB_ADDR - 1 : 0]        i_rd;               // instruction[15:11]
    // Control input
    reg  [NB_CTRL_WB - 1 : 0]     i_ctrl_wb_bus;
    reg  [NB_CTRL_M - 1 :  0]     i_ctrl_mem_bus;
    reg  [NB_CTRL_EX - 1 : 0]     i_ctrl_exc_bus;
    // OUTPUTS
    wire [LEN - 1 : 0]            o_PC_branch;        // Branch o Jump
    wire [LEN - 1 : 0]            o_ALU_result;       // Address (Data Memory)
    wire [LEN - 1 : 0]            o_write_data;
    wire [NB_ADDR - 1 : 0]        o_write_register;
    wire                          o_ALU_zero;
    // Control outputs
    wire [NB_CTRL_WB - 1 : 0]     o_ctrl_wb_bus;
    wire [NB_CTRL_M - 1 : 0]      o_ctrl_mem_bus;

    reg [LEN - 1 : 0] instruction;

    assign i_rt = instruction[20:16];
    assign i_rd = instruction[15:11];
    assign i_addr_ext = {{16{instruction[15]}}, instruction[15:0]};
    
    initial begin
        i_clk   = 1'b0;
        i_rst   = 1'b0;
        i_PC    = {NB_ADDR{1'b0}};
        i_read_data_1 = {LEN{1'b0}};
        i_read_data_2 = {LEN{1'b0}};
        instruction =  {LEN{1'b0}};
        i_ctrl_wb_bus = {NB_CTRL_WB{1'b0}};
        i_ctrl_mem_bus = {NB_CTRL_M{1'b0}};
        i_ctrl_exc_bus = {NB_CTRL_EX{1'b0}};
        // LOAD/STORE WORD
        #10 
        i_rst = 1'b1;
        instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        // BRANCH
        #10
        i_ctrl_exc_bus = 4'b0010;
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        // R-TYPE
        #10
        i_ctrl_exc_bus = 4'b0100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100000;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100010;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100101;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100110;  // XOR
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100111;  // NOR
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101010;  // SLT
        #10
        i_ctrl_exc_bus = 4'b0110;
        #10
        i_ctrl_exc_bus = 4'b0100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100000;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100001;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100010;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100011;
        i_ctrl_exc_bus = 4'b0101;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100101;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100110;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100111;
        i_ctrl_exc_bus = 4'b1100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101000;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101001;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101010;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101011;
        i_ctrl_exc_bus = 4'b1101;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101101;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101110;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101111;
        #10 $finish;
    end

    always begin
    #5
        i_read_data_1 = $random;
        i_read_data_2 = $random;
    end

    always #1 i_clk = ~i_clk;

    always #2 i_PC = i_PC + 1;

    seg_execute 
    #(
        .LEN        (LEN        ),
        .NB_ALUOP   (NB_ALUOP   ),
        .NB_ALUCTL  (NB_ALUCTL  ),
        .NB_ADDR    (NB_ADDR    ),
        .NB_FUNC    (NB_FUNC    ),
        .NB_CTRL_WB (NB_CTRL_WB ),
        .NB_CTRL_M  (NB_CTRL_M  ),
        .NB_CTRL_EX (NB_CTRL_EX )
    )
    u_seg_execute(
    	.i_clk            (i_clk            ),
        .i_rst            (i_rst            ),
        .i_PC             (i_PC             ),
        .i_read_data_1    (i_read_data_1    ),
        .i_read_data_2    (i_read_data_2    ),
        .i_addr_ext       (i_addr_ext       ),
        .i_rt             (i_rt             ),
        .i_rd             (i_rd             ),
        .i_ctrl_wb_bus    (i_ctrl_wb_bus    ),
        .i_ctrl_mem_bus   (i_ctrl_mem_bus   ),
        .i_ctrl_exc_bus   (i_ctrl_exc_bus   ),
        .o_PC_branch      (o_PC_branch      ),
        .o_ALU_result     (o_ALU_result     ),
        .o_write_data     (o_write_data     ),
        .o_write_register (o_write_register ),
        .o_ALU_zero       (o_ALU_zero       ),
        .o_ctrl_wb_bus    (o_ctrl_wb_bus    ),
        .o_ctrl_mem_bus   (o_ctrl_mem_bus   )
    );

endmodule
