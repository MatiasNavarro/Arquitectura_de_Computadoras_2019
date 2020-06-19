`timescale 1ns / 1ps

module seg_instruction_decode
    #( 
        parameter NB_INSTRUC    = 32,
        parameter NB_DATA       = 32,
        parameter NB_REG        = 32,
        parameter NB_ADDRESS    = 16,
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
        input wire                      i_clk,
        input wire                      i_rst,
        input wire [NB_INSTRUC-1:0]     i_instruc,
        input wire [NB_DATA-1:0]        i_write_data,
        
        //Salidas
        output wire [NB_DATA-1:0]       o_read_data_1,
        output wire [NB_DATA-1:0]       o_read_data_2,
        output wire [NB_DATA-1:0]       o_addr_ext,
        
        //Control outputs 
        output wire                     o_Branch,
        output wire                     o_MemRead,
        output wire                     o_MemtoReg,
        output wire                     o_MemWrite,
        output wire                     o_ALUSrc,
        output wire [NB_ALU_CODE-1:0]   o_ALUCode
    );

    //Register Wires 
    wire [NB_ADDR-1:0]      read_register_1;
    wire [NB_ADDR-1:0]      read_register_2;
    wire [NB_ADDR-1:0]      write_register;
    //wire [NB_REG-1:0]       addr_ext;
    
    //Outputs
    wire [NB_DATA-1:0]      read_data_1;
    wire [NB_DATA-1:0]      read_data_2;
    
    
    //Control bus
    wire    [NB_WB_BUS-1:0]     wb_bus; 
    wire    [NB_MEM_BUS-1:0]    mem_bus;
    wire    [NB_EXC_BUS-1:0]    exc_bus;
    //Instruction 
    wire    [NB_OPCODE-1:0]     opcode;
    wire    [NB_ADDR-1:0]       rs;
    wire    [NB_ADDR-1:0]       rt;
    wire    [NB_ADDR-1:0]       rd;
    wire    [NB_ADDR-1:0]       shamt;
    wire    [NB_OPCODE-1:0]     funct;
    wire    [NB_ADDRESS-1:0]    address;        
    //Control wires
    wire                        RegWrite;
    wire                        RegDst;
    wire                        Branch;
    wire                        MemRead;
    wire                        MemtoReg;
    wire                        MemWrite;
    wire                        ALUSrc;
    //wire    [NB_ALUOP-1:0]      ALUOp;
    
    
    //Control wires
    //WbBus
    assign RegWrite = wb_bus[1];
    assign MemtoReg = wb_bus[0];
    //MemBus
    assign Branch   = mem_bus[2];
    assign MemRead  = mem_bus[1];
    assign MemWrite = mem_bus[0];
    //ExcBus
    assign RegDst   = exc_bus[2];
    assign ALUSrc   = exc_bus[1:0];
    //Instruction
    assign opcode   = i_instruc[31:26];
    assign rs       = i_instruc[25:21];
    assign rt       = i_instruc[20:16];
    assign rd       = i_instruc[15:11];
    assign shamt    = i_instruc[10:6];
    assign funct    = i_instruc[5:0];
    assign address  = i_instruc[15:0];
    
    

    assign write_register   = (RegDst) ? rt : rd; //RegDst = 0 -> 20-16 | RegDst = 1 -> 15-11
    //Outputs ID
    assign o_read_data_1    = read_data_1;
    assign o_read_data_2    = read_data_2;
    //Extension de signo
    assign o_addr_ext         = {{NB_ADDRESS{address[15]}}, address[15:0]};
    //Control outputs 
    assign o_Branch     = Branch;
    assign o_MemRead    = MemRead;
    assign o_MemtoReg   = MemtoReg;
    assign o_MemWrite   = MemWrite;
    assign o_ALUSrc     = ALUSrc;
    //assign o_ALUCode    = ALUCode;

    
    control #(
        .NB_EXC_BUS     (NB_EXC_BUS),
        .NB_MEM_BUS     (NB_MEM_BUS), 
        .NB_OPCODE      (NB_OPCODE),
        .NB_ALU_CODE    (NB_ALU_CODE),
        .NB_ALUOP       (NB_ALUOP),
        .NB_WB_BUS      (NB_WB_BUS)
        )
    u_control(
        .i_opcode       (opcode),
        .i_funct        (funct),
        .o_wb_bus       (wb_bus),
        .o_mem_bus      (mem_bus),
        .o_exc_bus      (exc_bus),
        .o_ALUCode      (o_ALUCode)
    );
    
    registers #(
        .NB_DATA    (NB_DATA),
        .NB_REG     (NB_REG), 
        .NB_ADDR    (NB_ADDR)
    )
    u_registers(
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_RegWrite         (RegWrite),
        .i_read_register_1  (rs),
        .i_read_register_2  (rt),
        .i_write_register   (write_register),
        .i_write_data       (i_write_data),
        .o_read_data_1      (read_data_1),
        .o_read_data_2      (read_data_2)
    );

endmodule
