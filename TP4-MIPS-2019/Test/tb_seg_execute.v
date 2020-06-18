`timescale 1ns / 1ps

module tb_seg_execute();
    localparam NB_ADDR         = 32;
    localparam NB_DATA         = 32;
    localparam NB_OP           = 2;
    localparam NB_ALUCTL       = 4;
    localparam NB_FUNC         = 6;
    localparam NB_CTRL_WB      = 2;
    localparam NB_CTRL_M       = 3;
    localparam NB_CTRL_EX      = 4;

    // INPUTS
    reg                     i_clk;
    reg                     i_rst;
    reg [NB_ADDR - 1 : 0]   i_PC;
    reg [NB_DATA - 1 : 0]   i_read_data_1;
    reg [NB_DATA - 1 : 0]   i_read_data_2;
    wire [NB_ADDR - 1 : 0]   i_instruction_15_0;
    wire [20 - 16 : 0]       i_instruction_20_16;
    wire [15 - 11 : 0]       i_instruction_15_11;
    reg [NB_CTRL_WB + NB_CTRL_M + NB_CTRL_EX - 1 : 0] i_control;
    // OUTPUTS
    wire [NB_ADDR - 1 : 0]  o_PC;
    wire [NB_DATA - 1 : 0]  o_ALU_result;
    wire                    o_ALU_zero;
    wire [NB_DATA - 1 : 0]  o_read_data_2;
    wire [20 - 16 : 0]      o_instruction_20_16_o_15_11;
    wire [NB_CTRL_WB + NB_CTRL_M - 1 : 0] o_control;

    reg [NB_DATA - 1 : 0] instruction;

    assign i_instruction_20_16 = instruction[20:16];
    assign i_instruction_15_11 = instruction[15:11];
    assign i_instruction_15_0 = {{16{instruction[15]}}, instruction[15:0]};
    
    // TODO: Add instructions to test with
    initial begin
        i_clk   = 1'b0;
        i_rst   = 1'b0;
        i_PC    = {NB_ADDR{1'b0}};
        i_read_data_1 = {NB_DATA{1'b0}};
        i_read_data_2 = {NB_DATA{1'b0}};
        instruction =  {NB_DATA{1'b0}};
        i_control = {NB_CTRL_WB + NB_CTRL_M + NB_CTRL_EX{1'b0}};
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
        i_control = {4'b0010, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        #10 instruction = $random;
        // R-TYPE
        #10
        i_control = {4'b0100, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100000;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100000;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100010;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100101;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100110;  // XOR
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100111;  // NOR
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101010;  // SLT
        #10
        i_control = {4'b0110, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10
        i_control = {4'b0100, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100000;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100001;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100010;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100011;
        i_control = {4'b0101, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100100;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100101;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100110;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b100111;
        i_control = {4'b1100, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101000;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101001;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101010;
        #10 instruction[31:6] = $random; instruction[5:0] = 6'b101011;
        i_control = {4'b1101, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
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

    always begin
    #1
        i_clk = ~i_clk;
    end

    always begin
    #2
        i_PC = i_PC + 1;
    end

    seg_execute 
    #(
        .NB_ADDR    (NB_ADDR    ),
        .NB_DATA    (NB_DATA    ),
        .NB_OP      (NB_OP      ),
        .NB_ALUCTL  (NB_ALUCTL  ),
        .NB_FUNC    (NB_FUNC    ),
        .NB_CTRL_WB (NB_CTRL_WB ),
        .NB_CTRL_M  (NB_CTRL_M  ),
        .NB_CTRL_EX (NB_CTRL_EX )
    )
    u_seg_execute(
    	.i_clk                       (i_clk                       ),
        .i_rst                       (i_rst                       ),
        .i_PC                        (i_PC                        ),
        .i_read_data_1               (i_read_data_1               ),
        .i_read_data_2               (i_read_data_2               ),
        .i_instruction_15_0          (i_instruction_15_0          ),
        .i_instruction_20_16         (i_instruction_20_16         ),
        .i_instruction_15_11         (i_instruction_15_11         ),
        .i_control                   (i_control                   ),
        .o_PC                        (o_PC                        ),
        .o_ALU_result                (o_ALU_result                ),
        .o_ALU_zero                  (o_ALU_zero                  ),
        .o_read_data_2               (o_read_data_2               ),
        .o_instruction_20_16_o_15_11 (o_instruction_20_16_o_15_11 ),
        .o_control                   (o_control                   )
    );

endmodule
