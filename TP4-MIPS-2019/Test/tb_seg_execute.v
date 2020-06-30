`timescale 1ns / 1ps


//Todo puerto de salida del modulo es un cable.
//Todo puerto de estimulo o generacion de entrada es un registro.
module tb_seg_execute();
    localparam LEN_01           = 32;
    localparam NB_OP_01         = 2;
    localparam NB_ALUCTL_01     = 4;
    localparam NB_FUNC_01       = 6;
    localparam NB_WB_BUS_01     = 2;
    localparam NB_MEM_BUS_01    = 3;
    localparam NB_EXC_BUS_01    = 3;

    // INPUTS
    reg                         i_clk_01;
    reg                         i_rst_01;
    reg [LEN_01 - 1 : 0]        i_add_PC_01;
    reg [LEN_01 - 1 : 0]        i_addr_ext_01;
    reg [LEN_01 - 1 : 0]        i_read_data_1_01;
    reg [LEN_01 - 1 : 0]        i_read_data_2_01;
//    wire [LEN_01 - 1 : 0]       i_instruction_15_0;
//    wire [20 - 16 : 0]          i_instruction_20_16;
//    wire [15 - 11 : 0]          i_instruction_15_11;
//    reg [NB_CTRL_WB + NB_CTRL_M + NB_CTRL_EX - 1 : 0] i_control;
    reg [NB_WB_BUS_01-1 : 0]    i_wb_bus_01;
    reg [NB_MEM_BUS_01-1 : 0]   i_mem_bus_01;
    reg [NB_EXC_BUS_01-1 : 0]   i_exc_bus_01;
    reg [NB_OP_01-1 : 0 ]       i_alu_op_01;
    reg [NB_FUNC_01-1 : 0]      i_funct_01;
    // OUTPUTS
    wire [LEN_01 - 1 : 0]       o_PC_01;
    wire [LEN_01 - 1 : 0]       o_ALU_result_01;
    wire                        o_ALU_zero_01;
    wire [LEN_01 - 1 : 0]       o_read_data_2_01;
    //wire [20 - 16 : 0]          o_instruction_20_16_o_15_11_01;
    //wire [NB_CTRL_WB + NB_CTRL_M - 1 : 0] o_control_01;

//    reg [LEN_01 - 1 : 0] instruction;

//    assign i_instruction_20_16 = instruction[20:16];
//    assign i_instruction_15_11 = instruction[15:11];
//    assign i_instruction_15_0 = {{16{instruction[15]}}, instruction[15:0]};
    
    // TODO: Add instructions to test with
    initial begin
        i_clk_01   = 1'b0;
        i_rst_01   = 1'b0;
        i_PC_01    = {NB_ADDR{1'b0}};
        i_read_data_1_01 = {NB_DATA{1'b0}};
        i_read_data_2_01 = {NB_DATA{1'b0}};
        instruction_01 =  {NB_DATA{1'b0}};
        i_control_01 = {NB_CTRL_WB + NB_CTRL_M + NB_CTRL_EX{1'b0}};
        // LOAD/STORE WORD
        #10 
        i_rst_01 = 1'b1;
        instruction_01 = $random;
        #10 instruction_01 = $random;
        #10 instruction_01 = $random;
        #10 instruction_01 = $random;
        #10 instruction_01 = $random;
        // BRANCH
        #10
        i_control_01 = {4'b0010, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10 instruction_01 = $random;
        #10 instruction_01 = $random;
        #10 instruction_01 = $random;
        #10 instruction_01 = $random;
        #10 instruction_01 = $random;
        // R-TYPE
        #10
        i_control_01 = {4'b0100, {NB_CTRL_WB + NB_CTRL_M{1'b0}}};
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b100000;
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b100000;
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b100010;
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b100100;
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b100101;
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b100110;  // XOR
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b100111;  // NOR
        #10 instruction_01[31:6] = $random; instruction[5:0] = 6'b101010;  // SLT
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

    always #2.5 i_clk_01 = ~i_clk_01;

    always begin
    #2
        i_PC = i_PC + 1;
    end

    seg_execute 
    #(
        .LEN        (LEN_01),
        .NB_OP      (NB_OP_01),
        .NB_ALUCTL  (NB_ALUCTL_01),
        .NB_FUNC    (NB_FUNC_01),
        .NB_WB_BUS  (NB_WB_BUS_01),
        .NB_MEM_BUS (NB_MEM_BUS_01),
        .NB_EXC_BUS (NB_EXC_BUS_01)
    )
    u_seg_execute(
    	.i_clk                  (i_clk_01),
        .i_rst                  (i_rst_01),
        .i_add_PC               (i_add_PC_01),     
        .i_addr_ext             (i_addr_ext_01),
        .i_read_data_1          (i_read_data_1_01),
        .i_read_data_2          (i_read_data_2_01),
//        .i_instruction_15_0     (i_instruction_15_0_01          ),
//        .i_instruction_20_16    (i_instruction_20_16_01         ),
//        .i_instruction_15_11    (i_instruction_15_11_01         ),
//        .i_control              (i_control_01                   ),
        .i_wb_bus               (i_wb_bus_01),
        .i_mem_bus              (i_mem_bus_01),
        .i_exc_bus              (i_exc_bus_01),
        .i_alu_op               (i_alu_op_01),
        .i_funct                (i_funct_01),
        .o_PC                   (o_PC_01),
        .o_ALU_result           (o_ALU_result_01),
        .o_ALU_zero             (o_ALU_zero_01),
        .o_read_data_2          (o_read_data_2_01)
        //.o_instruction_20_16_o_15_11 (o_instruction_20_16_o_15_11_01 ),
        //.o_control                   (o_control_01                   )
    );

endmodule
