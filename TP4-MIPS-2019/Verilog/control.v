`timescale 1ns / 1ps

module control
    #(
        parameter NB_OPCODE     = 6,
        parameter NB_CTRL_EX    = 6,
        parameter NB_CTRL_M     = 9,
        parameter NB_CTRL_WB    = 2
     )
    (
        // Inputs
        input                           i_rst,
        input       [NB_OPCODE-1:0]     i_opcode,
        input       [NB_OPCODE-1:0]     i_funct,
        // Outputs (organiza las salidas en buses, para mayor prolijidad)
        output reg  [NB_CTRL_WB-1:0]    o_ctrl_wb_bus,      // [ RegWrite, MemtoReg]
        output reg  [NB_CTRL_M-1:0]     o_ctrl_mem_bus,     // [ SB, SH, LB, LH, Unsigned, BNEQ, Branch, MemRead, MemWrite ]
        output reg  [NB_CTRL_EX-1:0]    o_ctrl_exc_bus,     // [ ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
        output reg                      o_Jump,
        output reg                      o_JAL,
        output reg                      o_JR,
        output reg                      o_JALR,
        output reg                      o_shift,
        output reg                      o_shamt
    );
    
    always@(*) begin
        o_Jump  = 0;
        o_JAL   = 0;
        o_JR    = 0;
        o_JALR  = 0;
        o_shift = 0;
        o_shamt = 0;
        if(!i_rst) begin
            o_ctrl_wb_bus   = 0;
            o_ctrl_mem_bus  = 0;
            o_ctrl_exc_bus  = 0;
        end 
        else begin
            o_ctrl_wb_bus   = o_ctrl_wb_bus;
            o_ctrl_mem_bus  = o_ctrl_mem_bus;
            o_ctrl_exc_bus  = o_ctrl_exc_bus;

            case(i_opcode)
                //R-TYPE ------------------------------------------
                6'b 000000: 
                begin
                    case(i_funct)
                        6'b000000, 6'b000010, 6'b000011: //SHIFT CON SHAMT (SLL - SRL - SRA)
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 9'b000000000;
                            o_ctrl_exc_bus   = 6'b000101;
                            o_shift          = 1;
                            o_shamt          = 1;
                        end
                        
                        6'b000100, 6'b000110, 6'b000111: //SHIFT CON VARIABLE (SLLV - SRLV - SRAV)
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 9'b000000000;
                            o_ctrl_exc_bus   = 6'b000101;
                            o_shift          = 1;
                        end

                        6'b001000: //o_JR
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 9'b000000000;
                            o_ctrl_exc_bus   = 6'b000000;
                            o_JR             = 1;
                        end

                        6'b001001: //o_JALR
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 9'b000000000;
                            o_ctrl_exc_bus   = 6'b000001;
                            o_JALR           = 1;
                        end  

                        default:
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 9'b000000000;
                            o_ctrl_exc_bus   = 6'b000101;
                        end 
                    endcase
                end

                //LOAD TYPE ---------------------------------------

                6'b 100000: //LB
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 9'b001000010;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                6'b 100001: //LH
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 9'b000100010;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                6'b 100011: //LW
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 9'b000000010;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                6'b 100111: //LWU
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 9'b000000010;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                6'b 100100: //LBU
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 9'b001010010;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                6'b 100101: //LHU
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 9'b000110010;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                //STORE TYPE ---------------------------------------
                                
                6'b 101000: //SB
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 9'b100000001;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                6'b 101001: //SH
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 9'b010000001;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                6'b 101011: //SW
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 9'b000000001;
                    o_ctrl_exc_bus   = 6'b100000;
                end

                //INMEDIATE ---------------------------------------

                6'b 001000: //ADDI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b100110;
                end

                6'b 001100: //ANDI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b101000;
                end

                6'b 001101: //ORI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b101010;
                end

                6'b 001110: //XORI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b101100;
                end

                6'b 001111: //LUI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b101110;
                end

                6'b 001010: //SLTI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b110000;
                end

                //BRANCH - o_Jump ---------------------------------------
                                
                6'b 000100: //BEQ
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 9'b000000100;
                    o_ctrl_exc_bus   = 6'b100010;
                end
                
                6'b 000101: //BNQ
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 9'b000001000;
                    o_ctrl_exc_bus   = 6'b100010;
                end

                6'b 000010: //o_Jump (Salto incondicional) 
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b000000;
                    o_Jump           = 1;
                end

                6'b 000011: //o_JAL
                begin
                    o_ctrl_wb_bus    = 2'b10;   
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b000000;
                    o_JAL            = 1;
                end
                
                default:
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 9'b000000000;
                    o_ctrl_exc_bus   = 6'b000000;
                end
            endcase
        end
    end

endmodule
