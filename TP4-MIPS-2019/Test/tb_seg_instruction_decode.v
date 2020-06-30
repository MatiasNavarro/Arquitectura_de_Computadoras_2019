`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2020 15:25:21
// Design Name: 
// Module Name: tb_seg_instruction_decode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_seg_instruction_decode();
//Todo puerto de salida del modulo es un cable.
//Todo puerto de estimulo o generacion de entrada es un registro.
parameter LEN_01            = 32;
parameter NB_REG_01         = 32;
parameter NB_ADDRESS_01     = 16;
parameter NB_EXC_BUS_01     = 3;
parameter NB_MEM_BUS_01     = 3;
parameter NB_OPCODE_01      = 6;
parameter NB_ADDR_01        = 5;
parameter NB_ALU_CODE_01    = 4; 
parameter NB_WB_BUS_01      = 2;        
parameter NB_ALUOP_01       = 2;

//Inputs
reg i_clk_01;
reg i_rst_01;
reg [LEN_01 - 1 : 0] i_instruc_01;
reg [LEN_01 - 1 : 0] i_write_data_01;

//Outputs
wire [LEN_01 - 1 : 0] o_read_data_1_01;
wire [LEN_01 - 1 : 0] o_read_data_2_01;
wire [LEN_01 - 1 : 0] o_addr_ext_01;

//Control Outpus 
wire [NB_WB_BUS_01 - 1 : 0]     o_wb_bus_01;
wire [NB_MEM_BUS_01 - 1 : 0]    o_mem_bus_01;
wire [NB_EXC_BUS_01 - 1 : 0]    o_exc_bus_01;
wire [NB_ALUOP_01 - 1 : 0]      o_alu_op_01;
wire [NB_OPCODE_01 - 1 : 0]     o_funct_01;


initial begin
    i_clk_01 = 1'b0;
    i_rst_01 = 1'b0;
    i_write_data_01 = 32'h0000abcd;
    
    #5 i_rst_01 = 1'b1;
    
    #20 i_instruc_01 = 32'h01094020;    //R-Type
    #20 i_instruc_01 = 32'h8c034020;    //LW
    #20 i_instruc_01 = 32'hac040005;    //SW
    #20 i_instruc_01 = 32'h10080005;    //J-Type
    
    #10 $finish;
    
end
always #2.5 i_clk_01 = ~i_clk_01;




seg_instruction_decode
#(
    .LEN            (LEN_01),
    .NB_EXC_BUS     (NB_EXC_BUS_01),
    .NB_MEM_BUS     (NB_MEM_BUS_01),
    .NB_OPCODE      (NB_OPCODE_01),
    .NB_ALU_CODE    (NB_ALU_CODE_01),
    .NB_ALUOP       (NB_ALUOP_01), 
    .NB_WB_BUS      (NB_WB_BUS_01)
)
u_seg_instruction_decode_01
(
    .i_clk          (i_clk_01),
    .i_rst          (i_rst_01),
    .i_instruc      (i_instruc_01),
    .i_write_data   (i_write_data_01),
    .o_read_data_1  (o_read_data_1_01),
    .o_read_data_2  (o_read_data_2_01),
    .o_addr_ext     (o_addr_ext_01),
    .o_wb_bus       (o_wb_bus_01),
    .o_mem_bus      (o_mem_bus_01),
    .o_exc_bus      (o_exc_bus_01),
    .o_alu_op       (o_alu_op_01),
    .o_funct        (o_funct_01)
);

endmodule
