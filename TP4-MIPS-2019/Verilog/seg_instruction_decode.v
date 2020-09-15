`timescale 1ns / 1ps

module seg_instruction_decode
    #( 
        parameter LEN           = 32,
        parameter NB_REG        = 32,
        parameter NB_ADDRESS    = 16,
        parameter NB_OPCODE     = 6,
        parameter NB_ADDR       = 5,
        parameter NB_CTRL_EX    = 6,
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
        input wire [NB_ADDR-1:0]        i_rt_ex,
        input wire                      i_id_ex_ctrl_mem_bus_MemRead,
        
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
        output reg  [NB_CTRL_WB-1:0]    o_ctrl_wb_bus,   // [ RegWrite, MemtoReg]
        output reg  [NB_CTRL_M-1:0]     o_ctrl_mem_bus,  // [ SB, SH, LB, LH, Unsigned, BNEQ, Branch, MemRead, MemWrite ]
        output reg  [NB_CTRL_EX-1:0]    o_ctrl_exc_bus   // [ ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
    );
    
    //Instruction 
    wire    [NB_OPCODE-1:0]     opcode;
    wire    [NB_OPCODE-1:0]     funct;
    wire    [NB_ADDR-1:0]       shamt;
    wire    [NB_ADDRESS-1:0]    address;
    
    wire                        stall_flag;         //Hazard detection unit flag 
    wire    [LEN-1:0]           wire_read_data_1;
    wire    [2:0]               jump_flag;          //Distintos tipos de saltos 
    wire    [LEN-1:0]           read_data_1;
    wire    [LEN-1:0]           read_data_2;
    wire    [NB_CTRL_WB-1:0]    ctrl_wb_bus;
    wire    [NB_CTRL_M-1:0]     ctrl_mem_bus;
    wire    [NB_CTRL_EX-1:0]    ctrl_exc_bus;
    wire    [NB_ADDR-1:0]       read_register_1;
    
    // Control flags
    wire Jump;
    wire JAL;
    wire JR;
    wire JALR;
    wire shift_flag;

    //Instruction
    assign opcode   = i_instruction[31:26];
    assign o_rs     = i_instruction[25:21];
    assign o_rt     = (JAL) ? 5'b11111 : i_instruction[20:16];
    assign o_rd     = i_instruction[15:11];
    assign shamt    = i_instruction[10:6];
    assign address  = i_instruction[15:0];
    assign funct    = i_instruction[5:0];

    //Extension de signo
    assign o_addr_ext   = {{NB_ADDRESS{address[15]}}, address[15:0]};
    assign o_PC         = i_PC;

    //Extension de signo
    assign o_addr_ext = {{NB_ADDRESS{address[15]}}, address[15:0]};

    // Logica de jump
    assign o_PC_dir_jump    =   (Jump)          ? {i_PC[31:28],{2'b00, i_instruction[25:0]}} :      //JUMP
                                (JAL)           ? {2'b00, i_instruction[25:0]} :                    //JAL
                                (JR || JALR)    ? wire_read_data_1 :                                //JR JALR
                                32'b0;

    assign o_jump_flag = Jump || JAL || JR || JALR; //Jump signal

    assign o_read_data_1 = (JAL || JALR) ? i_PC  : read_data_1;
    assign o_read_data_2 = (JAL || JALR) ? 32'd2 : 
                           (shift_flag)  ? {{27{1'b0}},shamt} : 
                           read_data_2;

    assign read_register_1 = (shift_flag) ? o_rt : o_rs;

    always @(posedge i_clk)
    begin
        if(!i_rst || i_flush) begin
            o_ctrl_exc_bus  <= 0;
            o_ctrl_mem_bus  <= 0;
            o_ctrl_wb_bus   <= 0;
        end
        else begin
            if(o_stall_flag) begin
                o_ctrl_exc_bus  <= 0;
                o_ctrl_mem_bus  <= 0;
                o_ctrl_wb_bus   <= 0;
            end
            else begin
                o_ctrl_exc_bus  <= ctrl_exc_bus;
                o_ctrl_mem_bus  <= ctrl_mem_bus;
                o_ctrl_wb_bus   <= ctrl_wb_bus;
            end
        end
    end

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
        .o_ctrl_exc_bus (ctrl_exc_bus   ),
        .o_ctrl_mem_bus (ctrl_mem_bus   ),
        .o_ctrl_wb_bus  (ctrl_wb_bus    ),
        .o_Jump         (Jump           ),
        .o_JAL          (JAL            ),
        .o_JR           (JR             ),
        .o_JALR         (JALR           ),
        .o_shift        (shift_flag     )
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
        .i_read_register_1  (read_register_1    ),
        .i_read_register_2  (o_rt               ),
        .i_write_register   (i_write_reg        ),
        .i_write_data       (i_write_data       ),
        .o_wire_read_data_1 (wire_read_data_1   ),
        .o_read_data_1      (read_data_1        ),
        .o_read_data_2      (read_data_2        )
    );

    hazard_detection_unit #(
        .NB_ADDR        (NB_ADDR            )
    )
    u_hazard_detection_unit
    (
        .i_MemRead      (i_id_ex_ctrl_mem_bus_MemRead),  //o_ctrl_mem_bus[1] = MemRead
        .i_rs_id        (o_rs               ),
        .i_rt_id        (o_rt               ),
        .i_rt_ex        (i_rt_ex            ),
        .o_stall_flag   (o_stall_flag       )
    );

endmodule
