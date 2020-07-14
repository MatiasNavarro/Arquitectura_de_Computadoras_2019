`timescale 1ns / 1ps

module seg_instruction_decode
    #( 
        parameter LEN           = 32,
        parameter NB_REG        = 32,
        parameter NB_ADDRESS    = 16,
        parameter NB_OPCODE     = 6,
        parameter NB_ADDR       = 5,
        parameter NB_CTRL_EX    = 5,
        parameter NB_CTRL_M     = 3,
        parameter NB_CTRL_WB    = 2        
    )
    (
        //Entradas 
        input wire                      i_clk,
        input wire                      i_rst,
        input wire [LEN-1:0]            i_PC,
        input wire [LEN-1:0]            i_instruction,
        input wire [NB_ADDR-1:0]        i_write_reg,
        input wire [LEN-1:0]            i_write_data,
        input wire                      i_RegWrite,
        
        //Salidas
        output wire [LEN-1:0]           o_PC,
        output wire [LEN-1:0]           o_read_data_1,
        output wire [LEN-1:0]           o_read_data_2,
        output wire [LEN-1:0]           o_addr_ext,
        output wire [LEN-1:0]           o_PC_dir_jump, 
        output wire [NB_ADDR-1:0]       o_rt,           //instruction[20:16]
        output wire [NB_ADDR-1:0]       o_rd,           //instruction[15:11]
        output wire                     o_jump,         //Jump signal        

        //Control outputs 
        output wire [NB_CTRL_WB-1:0]     o_ctrl_wb_bus,   // [ RegWrite, MemtoReg]
        output wire [NB_CTRL_M-1:0]      o_ctrl_mem_bus,  // [ SB, SH, LB, LH, Unsigned, Branch, MemRead, MemWrite ]
        output wire [NB_CTRL_EX-1:0]     o_ctrl_exc_bus   // [ Jump&Link, JALOnly, RegDst, ALUSrc[1:0] , jump, jump_register, ALUCode [3:0] ]
    );
    
    //Instruction 
    wire    [NB_OPCODE-1:0]     opcode;
    wire    [NB_ADDR-1:0]       rs;
    wire    [NB_ADDR-1:0]       shamt;
    wire    [NB_ADDRESS-1:0]    address;

    //Instruction
    assign opcode   = i_instruction[31:26];
    assign rs       = i_instruction[25:21];
    assign o_rt     = i_instruction[20:16];
    assign o_rd     = i_instruction[15:11];
    assign shamt    = i_instruction[10:6];
    assign address  = i_instruction[15:0];
    assign funct    = i_instruction[5:0];
    
    //Extension de signo
    assign o_addr_ext   = {{NB_ADDRESS{address[15]}}, address[15:0]};
    
    assign o_PC             = i_PC;
    assign o_jump           = o_ctrl_exc_bus[6];      //Jump signal
    assign o_PC_dir_jump    = {i_PC[31:28],{i_instruction[25:0],2'b00}};

    control #(
        .NB_OPCODE      (NB_OPCODE      ),
        .NB_CTRL_EX     (NB_CTRL_EX     ),
        .NB_CTRL_M      (NB_CTRL_M      ), 
        .NB_CTRL_WB     (NB_CTRL_WB     )
    )
    u_control(
        .i_rst          (i_rst          ),
        .i_opcode       (opcode         ),
        .i_funct        (funct          ),
        .o_ctrl_exc_bus (o_ctrl_exc_bus ),
        .o_ctrl_mem_bus (o_ctrl_mem_bus ),
        .o_ctrl_wb_bus  (o_ctrl_wb_bus  )
    );
    
    registers #(
        .LEN        (LEN                ),
        .NB_REG     (NB_REG             ), 
        .NB_ADDR    (NB_ADDR            )
    )
    u_registers(
        .i_clk              (i_clk          ),
        .i_rst              (i_rst          ),
        .i_RegWrite         (i_RegWrite     ),
        .i_read_register_1  (rs             ),
        .i_read_register_2  (o_rt           ),
        .i_write_register   (i_write_reg    ),
        .i_write_data       (i_write_data   ),
        .o_read_data_1      (o_read_data_1  ),
        .o_read_data_2      (o_read_data_2  )
    );

endmodule
