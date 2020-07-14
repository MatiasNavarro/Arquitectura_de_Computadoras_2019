`timescale 1ns / 1ps

module control
    #(
        parameter NB_OPCODE     = 6,
        parameter NB_CTRL_EX    = 7,
        parameter NB_CTRL_M     = 3,
        parameter NB_CTRL_WB    = 2
     )
    (
        // Inputs
        input                           i_rst,
        input       [NB_OPCODE-1:0]     i_opcode,
        input       [NB_OPCODE-1:0]     i_funct,
        // Outputs (organiza las salidas en buses, para mayor prolijidad)
        output reg  [NB_CTRL_WB-1:0]    o_ctrl_wb_bus,      // [ RegWrite, MemtoReg]
        output reg  [NB_CTRL_M-1:0]     o_ctrl_mem_bus,     // [ Branch, MemRead, MemWrite ]
        output reg  [NB_CTRL_EX-1:0]    o_ctrl_exc_bus      // [ Jump, ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
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

                //R-TYPE ------------------------------------------
                6'b 000000: 
                begin
                    case(i_funct)
                        6'b000000, 6'b000010, 6'b000011: //SHIFT CON SHAMT (SLL - SRL - SRA)
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 3'b000;
                            o_ctrl_exc_bus   = 7'b0100101;
                        end

                        6'b001000: //JR
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 3'b000;
                            o_ctrl_exc_bus   = 7'b0000000;
                        end

                        6'b001001: //JALR
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 3'b000;
                            o_ctrl_exc_bus   = 7'b0000001;
                        end  

                        default:
                        begin
                            o_ctrl_wb_bus    = 2'b10;
                            o_ctrl_mem_bus   = 3'b000;
                            o_ctrl_exc_bus   = 7'b0000101;
                        end 
                    endcase
                end

                //LOAD TYPE ---------------------------------------

                6'b 100000: //LB
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 3'b010;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                6'b 100001: //LH
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 3'b010;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                6'b 100011: //LW
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 3'b010;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                6'b 100111: //LWU
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 3'b010;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                6'b 100100: //LBU
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 3'b010;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                6'b 100101: //LHU
                begin
                    o_ctrl_wb_bus    = 2'b11;
                    o_ctrl_mem_bus   = 3'b010;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                //STORE TYPE ---------------------------------------
                                
                6'b 101000: //SB
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b001;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                6'b 101001: //SH
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b001;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                6'b 101011: //SW
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b001;
                    o_ctrl_exc_bus   = 7'b0100000;
                end

                //INMEDIATE ---------------------------------------

                6'b 001000: //ADDI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0100110;
                end

                6'b 001100: //ANDI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0101000;
                end

                6'b 001101: //ORI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0101010;
                end

                6'b 001110: //XORI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0101100;
                end

                6'b 001111: //LUI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0101110;
                end

                6'b 001010: //SLTI
                begin
                    o_ctrl_wb_bus    = 2'b10;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0110000;
                end

                //BRANCH - JUMP ---------------------------------------
                                
                6'b 000100: //BEQ
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b100;
                    o_ctrl_exc_bus   = 7'b0100010;
                end
                
                6'b 000101: //BNQ
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b100;
                    o_ctrl_exc_bus   = 7'b0100010;
                end

                6'b 000010: //JUMP (Salto incondicional) 
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b1000000;
                end

                6'b 000011: //JAL
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0000001;
                end
                
                default:
                begin
                    o_ctrl_wb_bus    = 2'b00;
                    o_ctrl_mem_bus   = 3'b000;
                    o_ctrl_exc_bus   = 7'b0000000;
                end
            endcase
        end
    end

endmodule
