`timescale 1ns / 1ps

module seg_instruction_decode
    #( 
         parameter LENGTH_INSTRUCTION   = 32,
         parameter NB_OPCODE            = 6,
         parameter NB_ADDR              = 6,
         parameter NB_DATA              = 6,
         parameter NB_ALUOP             = 2
    )
    (
        input i_clk,
        input i_rst,
        input [LENGTH_INSTRUCTION-1:0] instruction
    );

    //Register Wires 
    wire [NB_ADDR-1:0]      read_register_1;
    wire [NB_ADDR-1:0]      read_register_2;
    wire [NB_ADDR-1:0]      write_register;
    wire [NB_DATA-1:0]      write_data;
    
    wire [NB_DATA-1:0]      read_data_1;
    wire [NB_DATA-1:0]      read_data_2;
    
    
    //Control Wires
    wire                    RegWrite;
    wire                    RegDst;
    wire                    Branch;
    wire                    MemRead;
    wire                    MemtoReg;
    wire                    MemWrite;
    wire                    ALUSrc;
    wire [NB_ALUOP-1:0]     ALUOp;
    wire [NB_OPCODE-1:0]    opcode;

    control #(.NB_OPCODE (NB_OPCODE), .NB_ALUOP(NB_ALUOP))
    u_control(
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_opcode       (opcode),
        .o_RegDst       (RegDst),
        .o_Branch       (Branch),
        .o_MemRead      (MemRead),
        .o_MemtoReg     (MemtoReg),
        .o_ALUOp        (ALUOp),
        .o_MemWrite     (MemWrite),
        .o_ALUSrc       (ALUSrc),
        .o_RegWrite     (RegWrite)
    );
    
    registers #(.NB_DATA (NB_DATA), .NB_ADDR (NB_ADDR))
    u_registers(
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_RegWrite         (RegWrite),
        .i_read_register_1  (read_register_1),
        .i_read_register_2  (read_register_2),
        .i_write_register   (write_register),
        .i_write_data       (write_data),
        .o_read_data_1      (read_data_1),
        .o_read_data_2      (read_data_2)
    );

endmodule
