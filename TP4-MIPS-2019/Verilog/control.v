`timescale 1ns / 1ps

module control
    #(
        parameter NB_EXC_BUS    = 3,
        parameter NB_MEM_BUS    = 3,
        parameter NB_OPCODE     = 6,
        parameter NB_ALU_CODE   = 4,
        parameter NB_ALUOP      = 2,
        parameter NB_WB_BUS     = 2
     )
    (
        //Inputs
        input                           i_rst,
        input       [NB_OPCODE-1:0]     i_opcode,
        input       [NB_OPCODE-1:0]     i_funct,
        //Outputs 
        //Organiza las salidas en buses, para mayor prolijidad 
        output reg  [NB_WB_BUS-1:0]     o_wb_bus,   // [ RegWrite, MemtoReg]
        output reg  [NB_MEM_BUS-1:0]    o_mem_bus,  // [ SB, SH, LB, LH, Unsigned, Branch, MemRead, MemWrite ]
        output reg  [NB_EXC_BUS-1:0]    o_exc_bus,  // [ Jump&Link, JALOnly, RegDst, ALUSrc[1:0] , jump, jump_register, ALUCode [3:0] ]
        output reg  [NB_ALU_CODE-1:0]   o_ALUCode
    );
    
    reg     [NB_ALUOP-1:0]      ALUOp;
    wire    [NB_ALU_CODE-1:0]   ALUCode;
    
    ALU_Control #(
        .NB_OPCODE      (NB_OPCODE),
        .NB_ALU_CODE    (NB_ALU_CODE),
        .NB_ALUOP       (NB_ALUOP)
    )
    u_ALU_Control(
        .i_funct    (i_funct),
        .i_ALUOp    (ALUOp),
        .o_ALUCode  (ALUCode)
    );
    
     
    
    always@(*)
    begin
        if(!i_rst) 
        begin
            ALUOp       = 2'b00;
            o_wb_bus    = 2'b00;
            o_mem_bus   = 3'b000;
            o_exc_bus   = 3'b000;
        end
        else
        begin
            case(i_opcode)
                6'b 000000: // R-Type
                begin
                    ALUOp       = 2'b10;
                    o_wb_bus    = 2'b10;
                    o_mem_bus   = 3'b000;
                    o_exc_bus   = 3'b100;
                 end
                    
                6'b 100011: //LW (I-Type)
                begin
                    ALUOp       = 2'b00;
                    o_wb_bus    = 2'b11;
                    o_mem_bus   = 3'b010;
                    o_exc_bus   = 3'b001;
                end
                                
                6'b 101011: //SW (I-Type)
                begin
                    ALUOp       = 2'b00;
                    o_wb_bus    = 2'b00;
                    o_mem_bus   = 3'b001;
                    o_exc_bus   = 3'b001;
                end
                                
                6'b 000100: //BEQ (J-Type) 
                begin
                    ALUOp       = 2'b01;
                    o_wb_bus    = 2'b00;
                    o_mem_bus   = 3'b100;
                    o_exc_bus   = 3'b000;
                end
            endcase
            
            o_ALUCode = ALUCode;
        end
    end

endmodule
