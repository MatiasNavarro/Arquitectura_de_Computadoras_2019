`timescale 1ns / 1ps

// TODO: Escribir los read_data a registros en un clock entre los clock de escritura de registros entre etapas (top_mips usa negedge, usa posedge aca) y asignalos a los o_read_data

module seg_instruction_decode
    #( 
        parameter LEN           = 32,
        parameter NB_REG        = 32,
        parameter NB_ADDRESS    = 16,
        parameter NB_OPCODE     = 6,
        parameter NB_ADDR       = 5,
        parameter NB_CTRL_EX    = 10,
        parameter NB_CTRL_M     = 9,
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
        input wire                      i_flush,
        input wire                      i_enable,       //Pipeline enable
        input wire [NB_ADDR-1:0]        i_rt_ex,
        
        //Salidas
        output wire [NB_ADDR-1:0]       o_rs,           //instruction[25:21]
        output wire [NB_ADDR-1:0]       o_rt,           //instruction[20:16]
        output wire [NB_ADDR-1:0]       o_rd,           //instruction[15:11]
        output wire [LEN-1:0]           o_PC,
        output wire [LEN-1:0]           o_addr_ext,
        output wire [LEN-1:0]           o_read_data_1,
        output wire [LEN-1:0]           o_read_data_2,
        output wire [LEN-1:0]           o_PC_dir_jump, 
        output wire                     o_jump_flag,         //Jump signal        
        output wire                     o_stall_flag,        //Stall signal   

        //Control outputs 
        output wire [NB_CTRL_WB-1:0]    o_ctrl_wb_bus,   // [ RegWrite, MemtoReg]
        output wire [NB_CTRL_M-1:0]     o_ctrl_mem_bus,  // [ SB, SH, LB, LH, Unsigned, BNEQ, Branch, MemRead, MemWrite ]
        output wire [NB_CTRL_EX-1:0]    o_ctrl_exc_bus   // [ JAL, JR, JALR, Jump, ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
    );
    
    //Instruction 
    wire    [NB_OPCODE-1:0]     opcode;
    wire    [NB_OPCODE-1:0]     funct;
    wire    [NB_ADDR-1:0]       shamt;
    wire    [NB_ADDRESS-1:0]    address;

    wire                        stall_flag;         //Hazard detection unit flag 
    wire    [LEN-1:0]           wire_read_data_1;
    wire    [2:0]               jump_flag;          //Distintos tipos de saltos 

    //Instruction
    assign opcode   = i_instruction[31:26];
    assign o_rs     = i_instruction[25:21];
    assign o_rt     = (jump_flag == 3'b100) ? 5'b11111 : i_instruction[20:16];
    assign o_rd     = i_instruction[15:11];
    assign shamt    = i_instruction[10:6];
    assign address  = i_instruction[15:0];
    assign funct    = i_instruction[5:0];

    //Extension de signo
    assign o_addr_ext   = {{NB_ADDRESS{address[15]}}, address[15:0]};

    // assign o_stall_flag   = (i_flush) ? 1'b0  : stall_flag;
    // assign o_read_data_1  = (i_flush) ? 32'b0 : read_data_1;
    // assign o_read_data_2  = (i_flush) ? 32'b0 : read_data_2;

    assign o_PC = i_PC;

    //Extension de signo
    assign o_addr_ext = {{NB_ADDRESS{address[15]}}, address[15:0]};

    //(100) JAL, (011) JR, (010)JALR, (001) JUMP
    assign jump_flag    =   (o_ctrl_exc_bus[9]==1'b1)? 3'b100 : //JAL 
                            (o_ctrl_exc_bus[8]==1'b1)? 3'b011 : //JR
                            (o_ctrl_exc_bus[7]==1'b1)? 3'b010 : //JALR
                            (o_ctrl_exc_bus[6]==1'b1)? 3'b001 : //JUMP
                            3'b000;  

    assign o_PC_dir_jump    =   (jump_flag == 3'b001) ? {i_PC[31:28],{2'b00, i_instruction[25:0]}} :     //JUMP
                                (jump_flag == 3'b100) ? {2'b00, i_instruction[25:0]} :                   //JAL
                                (jump_flag == 3'b010 || (jump_flag == 3'b011)) ? wire_read_data_1 :     //JR JALR
                                32'b0;                

    assign o_jump_flag = |jump_flag;    //Jump signal

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
        .i_stall_flag   (stall_flag     ),
        .o_ctrl_exc_bus (o_ctrl_exc_bus ),
        .o_ctrl_mem_bus (o_ctrl_mem_bus ),
        .o_ctrl_wb_bus  (o_ctrl_wb_bus  )
    );
    
    registers #(
        .LEN                (LEN            ),
        .NB_REG             (NB_REG         ), 
        .NB_ADDR            (NB_ADDR        )
    )
    u_registers(
        .i_clk              (i_clk              ),
        .i_rst              (i_rst              ),
        .i_RegWrite         (i_RegWrite         ),
        .i_enable           (i_enable           ),
        .i_read_register_1  (o_rs               ),
        .i_read_register_2  (o_rt               ),
        .i_write_register   (i_write_reg        ),
        .i_write_data       (i_write_data       ),
        .o_wire_read_data_1 (wire_read_data_1   ),
        .o_read_data_1      (o_read_data_1      ),
        .o_read_data_2      (o_read_data_2      )
    );

    hazard_detection_unit #(
        .NB_ADDR        (NB_ADDR            )
    )
    u_hazard_detection_unit
    (
        .i_MemRead      (o_ctrl_mem_bus[1]  ),  //o_ctrl_mem_bus[1] = MemRead
        .i_rs_id        (o_rs               ),
        .i_rt_id        (o_rt               ),
        .i_rt_ex        (i_rt_ex            ),
        .o_stall_flag   (stall_flag         )
    );

endmodule
