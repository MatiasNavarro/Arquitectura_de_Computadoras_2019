`timescale 1ns / 1ps

module control
    #(
        parameter NB_OPCODE     = 6,
        parameter NB_CTRL_EX    = 3,
        parameter NB_CTRL_M     = 3,
        parameter NB_CTRL_WB    = 2
     )
    (
        // Inputs
        input                           i_rst,
        input       [NB_OPCODE-1:0]     i_opcode,
        // Outputs (organiza las salidas en buses, para mayor prolijidad)
        output reg  [NB_CTRL_WB-1:0]    o_ctrl_wb_bus,   // [ RegWrite, MemtoReg]
        output reg  [NB_CTRL_M-1:0]     o_ctrl_mem_bus,  // [ SB, SH, LB, LH, Unsigned, Branch, MemRead, MemWrite ]
        output reg  [NB_CTRL_EX-1:0]    o_ctrl_exc_bus  // [ Jump&Link, JALOnly, RegDst, ALUSrc[1:0] , jump, jump_register, ALUCode [3:0] ]
    );
    
    always@(*) begin
        if(!i_rst) begin
            o_ctrl_wb_bus   = 0;
            o_ctrl_mem_bus  = 0;
            o_ctrl_exc_bus  = 0;
        end else begin
            o_ctrl_wb_bus   = o_ctrl_wb_bus;
            o_ctrl_mem_bus  = o_ctrl_mem_bus;
            o_ctrl_exc_bus  = o_ctrl_exc_bus;

            case(i_opcode)
                6'b 000000: // R-Type
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 3'b100;
                end
                    
                6'b 100011: //LW (I-Type)
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 3'b010;
                    o_ctrl_exc_bus   = 3'b001;
                end
                                
                6'b 101011: //SW (I-Type)
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b001;
                    o_ctrl_exc_bus   = 3'b001;
                end
                                
                6'b 000100: //BEQ (J-Type) 
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b100;
                    o_ctrl_exc_bus   = 3'b000;
                end
                
                default:
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 3'b000;
                end
            endcase
        end
    end

endmodule
