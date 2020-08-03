`timescale 1ns / 1ps

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
        
        //Salidas
        output reg  [NB_ADDR-1:0]       o_rs,           //instruction[25:21]
        output reg  [NB_ADDR-1:0]       o_rt,           //instruction[20:16]
        output reg  [NB_ADDR-1:0]       o_rd,           //instruction[15:11]
        output reg  [LEN-1:0]           o_PC,
        output reg  [LEN-1:0]           o_addr_ext,
        output wire [LEN-1:0]           o_read_data_1,
        output wire [LEN-1:0]           o_read_data_2,
        output wire [LEN-1:0]           o_PC_dir_jump, 
        output wire                     o_jump_flag,         //Jump signal        
        output wire                     o_stall_flag,        //Stall signal   

        //Control outputs 
        output reg  [NB_CTRL_WB-1:0]    o_ctrl_wb_bus,   // [ RegWrite, MemtoReg]
        output reg  [NB_CTRL_M-1:0]     o_ctrl_mem_bus,  // [ SB, SH, LB, LH, Unsigned, BNEQ, Branch, MemRead, MemWrite ]
        output reg  [NB_CTRL_EX-1:0]    o_ctrl_exc_bus   // [ JAL, JR, JALR, Jump, ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
    );
    
    //Instruction 
    wire    [NB_OPCODE-1:0]     opcode;
    wire    [NB_ADDR-1:0]       rs;
    wire    [NB_ADDR-1:0]       rt;
    wire    [NB_ADDR-1:0]       rd;
    wire    [NB_ADDR-1:0]       shamt;
    wire    [NB_ADDRESS-1:0]    address;

    wire                        stall_flag;         //Hazard detection unit flag 
    wire    [LEN-1:0]           wire_read_data_1;
    wire    [2:0]               jump_flag;          //Distintos tipos de saltos 

    wire                        addr_ext;
    wire    [NB_CTRL_EX-1:0]    ctrl_exc_bus;
    wire    [NB_CTRL_M -1:0]    ctrl_mem_bus; 
    wire    [NB_CTRL_WB-1:0]    ctrl_wb_bus;

    //Instruction
    assign opcode   = i_instruction[31:26];
    assign rs       = i_instruction[25:21];
    assign rt       = i_instruction[20:16];
    assign rd       = i_instruction[15:11];
    assign shamt    = i_instruction[10:6];
    assign address  = i_instruction[15:0];
    assign funct    = i_instruction[5:0];

    
    //Extension de signo
    assign addr_ext = {{NB_ADDRESS{address[15]}}, address[15:0]};

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

    always @(negedge i_clk)
    begin
      if(!i_rst | i_flush)
      begin
        o_rs            <= 0;
        o_rt            <= 0; 
        o_rd            <= 0;
        o_PC            <= 0;
        o_addr_ext      <= 0;

        o_ctrl_exc_bus  <= 0;
        o_ctrl_mem_bus  <= 0;
        o_ctrl_wb_bus   <= 0;
      end

      if(i_enable)
      begin
        o_rs            <= rs;
        o_rt            <= rt; 
        o_rd            <= rd;
        o_PC            <= i_PC;
        o_addr_ext      <= addr_ext;

        o_ctrl_exc_bus  <= ctrl_exc_bus;
        o_ctrl_mem_bus  <= ctrl_mem_bus;
        o_ctrl_wb_bus   <= ctrl_wb_bus;
      end
      
      else
      begin
        o_rs            <= o_rs;
        o_rt            <= o_rt; 
        o_rd            <= o_rd;
        o_PC            <= o_PC;
        o_addr_ext      <= o_addr_ext;

        o_ctrl_exc_bus  <= o_ctrl_exc_bus;
        o_ctrl_mem_bus  <= o_ctrl_mem_bus;
        o_ctrl_wb_bus   <= o_ctrl_wb_bus;
      end

      if(stall_flag)            //MUX - Control Riesgos 
                                //Deteccion de riesgos - NOP - Burbuja
      begin
        o_ctrl_exc_bus  <= 0;
        o_ctrl_mem_bus  <= 0;
        o_ctrl_wb_bus   <= 0;
      end
      else
      begin
        o_ctrl_exc_bus  <= o_ctrl_exc_bus;
        o_ctrl_mem_bus  <= o_ctrl_mem_bus;
        o_ctrl_wb_bus   <= o_ctrl_wb_bus;
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
        .o_ctrl_wb_bus  (ctrl_wb_bus    )
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
        .i_read_register_1  (rs                 ),
        .i_read_register_2  (o_rt               ),
        .i_write_register   (i_write_reg        ),
        .i_write_data       (i_write_data       ),
        .o_wire_read_data_1 (wire_read_data_1   ),
        .o_read_data_1      (o_read_data_1      ),
        .o_read_data_2      (o_read_data_2      )
    );

    hazard_detection_unit #(
        .LEN            (LEN                ),
        .NB_ADDR        (NB_ADDR            )
    )
    (
        .i_rs_id        (rs                 ),
        .i_rt_id        (rt                 ),
        .i_rt_ex        (o_rt               ),
        .i_MemRead      (o_ctrl_mem_bus[1]  ),  
        .o_stall_flag   (stall_flag         )
    );

endmodule
