`timescale 1ns / 1ps

module seg_instruction_decode
    #( 
        parameter NB_INSTRUC    = 32,
        parameter NB_DATA       = 32,
        parameter NB_REG        = 32,
        parameter NB_EXC_BUS    = 3,
        parameter NB_MEM_BUS    = 3,
        parameter NB_OPCODE     = 6,
        parameter NB_ADDR       = 5,
        parameter NB_ALU_CODE   = 4,
        parameter NB_WB_BUS     = 2,        
        parameter NB_ALUOP      = 2
    )
    (
        //Entradas 
        input                   i_clk,
        input                   i_rst,
        input [NB_INSTRUC-1:0]  i_instruc,
        input [NB_DATA-1:0]     i_write_data,
        
        //Salidas
        output [NB_DATA-1:0]    o_read_data_1,
        output [NB_DATA-1:0]    o_read_data_2   
    );

    //Register Wires 
    wire [NB_ADDR-1:0]      read_register_1;
    wire [NB_ADDR-1:0]      read_register_2;
    wire [NB_ADDR-1:0]      write_register;
    //wire [NB_DATA-1:0]      write_data;
    
    //Outputs
    wire [NB_DATA-1:0]      read_data_1;
    wire [NB_DATA-1:0]      read_data_2;
    
    
    //Control Wires
    wire    [NB_WB_BUS-1:0]     wb_bus; 
    wire    [NB_MEM_BUS-1:0]    mem_bus;
    wire    [NB_EXC_BUS-1:0]    exc_bus;
//    wire                    RegWrite;
//    wire                    RegDst;
//    wire                    Branch;
//    wire                    MemRead;
//    wire                    MemtoReg;
//    wire                    MemWrite;
//    wire                    ALUSrc;
//    wire [NB_ALUOP-1:0]     ALUOp;
//    wire [NB_OPCODE-1:0]    opcode;

    assign write_register   = (exc_bus[2]) ? i_instruc[20:16] : i_instruc[15:11]; //RegDst = 0 -> 20-16 | RegDst = 1 -> 15-11
    assign o_read_data_1    = read_data_1;
    assign o_read_data_2    = read_data_2;

    
    control #(
        .NB_EXC_BUS     (NB_EXC_BUS),
        .NB_MEM_BUS     (NB_MEM_BUS), 
        .NB_OPCODE      (NB_OPCODE),
        .NB_ALU_CODE    (NB_ALU_CODE),
        .NB_ALUOP       (NB_ALUOP),
        .NB_WB_BUS      (NB_WB_BUS)
        )
    u_control(
        .i_opcode       (i_instruc[(NB_INSTRUC-1):(NB_INSTRUC-NB_OPCODE)]),
        .i_funct        (i_instruc[(NB_OPCODE-1):0]),
        .o_wb_bus       (wb_bus),
        .o_mem_bus      (mem_bus),
        .o_exc_bus      (exc_bus)
    );
    
    registers #(
        .NB_DATA    (NB_DATA),
        .NB_REG     (NB_REG), 
        .NB_ADDR    (NB_ADDR)
    )
    u_registers(
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_RegWrite         (wb_bus[1]),
        .i_read_register_1  (i_instruc[25:21]),
        .i_read_register_2  (i_instruc[20:16]),
        .i_write_register   (write_register),
        .i_write_data       (i_write_data),
        .o_read_data_1      (read_data_1),
        .o_read_data_2      (read_data_2)
    );

endmodule
