`timescale 1ns / 1ps

module top_mips
    #(              //CPU
       parameter    LEN             = 32,
       parameter    NB_ADDRESS      = 16,
       parameter    NB_OPCODE       = 6,
       parameter    NB_OPERAND      = 11,
       parameter    NB_ADDR         = 5,
       parameter    NB_ALUOP        = 2,
       parameter    NB_FUNC         = 6,
       parameter    NB_ALUCTL       = 4,             
       parameter    NB_CTRL_EX      = 4,
       parameter    NB_CTRL_M       = 3,
       parameter    NB_CTRL_WB      = 2,
                    
                    //PROGRAM MEMORY
       parameter    RAM_WIDTH_PROGRAM       = 32,
       parameter    RAM_DEPTH_PROGRAM       = 2048,
       parameter    RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY",
       parameter    INIT_FILE_PROGRAM       = "",
                    
                    //DATA MEMORY
       parameter    RAM_WIDTH_DATA          = 32,
       parameter    RAM_DEPTH_DATA          = 1024, 
       parameter    RAM_PERFORMANCE_DATA    = "LOW_LATENCY",
       parameter    INIT_FILE_DATA          = "" 
    )
    (
        //inputs
        input                           i_clk,
        input                           i_rst,
        //outputs
        output wire [LEN - 1 : 0]       o_led
    );

    //Wire CPU - Memory
    wire [NB_ADDR-1:0]      addr_program_mem;
    wire [LEN-1:0]          instruc;
    wire [NB_ADDR-1:0]      addr_data_mem;
    wire [LEN-1:0]          in_data_memory;
    wire [LEN-1:0]          out_data_memory;
    wire [LEN-1:0]          o_alu;
    
    //Control wires
    wire [NB_CTRL_WB-1:0]   wb_bus;   // [ RegWrite, MemtoReg]
    wire [NB_CTRL_M-1:0]    mem_bus;  // [ SB, SH, LB, LH, Unsigned, Branch, MemRead, MemWrite ]
    wire [NB_CTRL_EX-1:0]   exc_bus;  // [ Jump&Link, JALOnly, RegDst, ALUSrc[1:0] , jump, jump_register, ALUCode [3:0] 
    wire [NB_ALUOP-1:0]     alu_op;
    
    //Instruction fetch I/O wires
    wire [LEN-1:0]          PC_branch;      //PC -> Add PC + (shiftleft << 2)
    wire                    PCSrc;          //Selector del MUX de PC
    wire [LEN-1:0]          instruction;    //Instruccion de 32 bits
    wire [LEN-1:0]          PC_if_id;       //Program Counter
    
    //Instruction decode I/O wires
    wire [LEN-1:0]          read_data_1_id_ex; //Salida de ID 
    wire [LEN-1:0]          read_data_2_id_ex; //Salida de ID
    wire [LEN-1:0]          address_ext_id_ex; //Salida de ID
    wire [LEN-1:0]          PC_id_ex;
    wire [NB_ADDR-1:0]      rt_id_ex;
    wire [NB_ADDR-1:0]      rd_id_ex;
        //Control outputs     
    wire [NB_CTRL_WB-1:0]   ctrl_wb_bus_id_ex;
    wire [NB_CTRL_M-1:0]    ctrl_mem_bus_id_ex;
    wire [NB_CTRL_EX-1:0]   ctrl_exc_bus_id_ex;
    
    //Execute I/O wires
    wire [LEN-1:0]          PC_branch_ex_mem;         //PC -> Add PC + (shiftleft << 2)
    wire [LEN-1:0]          ALU_result_ex_mem;    
    wire [LEN-1:0]          write_data_ex_mem;
    wire [NB_ADDR-1:0]      write_register_exc_mem;
    wire                    ALU_zero;
        //Control outputs
    wire [NB_CTRL_WB-1:0]   ctrl_wb_bus_ex_mem;
    wire [NB_CTRL_M-1:0]    ctrl_mem_bus_ex_mem;

    //Data Memory I/O wires
    wire                    PCSrc_exc_if;
    wire [LEN-1:0]          PC_branch_mem_if;
    wire [LEN-1:0]          read_data_mem_wb; //Salida de ID
    wire [LEN-1:0]          address_mem_wb; //Salida de ID
    wire [NB_ADDR-1:0]      write_register_mem_wb;
        //Control outputs     
    wire [NB_CTRL_WB-1:0]   ctrl_wb_bus_mem_wb;

    
    //Write Back I/O wires 
    wire                    RegWrite_wb_id;
    wire [NB_ADDR-1:0]      write_register_wb_id;
    wire [LEN-1:0]          write_data_wb_id;
    


    // -----------------------------------------------
    // Instruction Fetch (IF) 
    //------------------------------------------------
    seg_instruction_fetch #(
        .NB_INSTRUC                 (LEN),
        .RAM_WIDTH_PROGRAM 			(RAM_WIDTH_PROGRAM),
        .RAM_DEPTH_PROGRAM 			(RAM_DEPTH_PROGRAM),
        .RAM_PERFORMANCE_PROGRAM 	(RAM_PERFORMANCE_PROGRAM),
        .INIT_FILE_PROGRAM 			(INIT_FILE_PROGRAM)
    )
    u_seg_instruction_fetch
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_PC_branch        (PC_branch_mem_if),
        .i_PCSrc            (PCSrc_exc_if),
        //Output
        .o_instruction      (instruction),
        .o_PC               (PC_if_id)
    );
    
    // -----------------------------------------------
    // Instruction Decode (ID) 
    //------------------------------------------------
    seg_instruction_decode #(
        .NB_INSTRUC                 (LEN),
        .NB_REG                     (LEN),
        .NB_ADDRESS                 (NB_ADDRESS),
        .NB_OPCODE                  (NB_OPCODE),
        .NB_ADDR                    (NB_ADDR),
        .NB_CTRL_EX                 (NB_CTRL_EX),
        .NB_CTRL_M                 (NB_CTRL_M),
        .NB_CTRL_WB                  (NB_CTRL_WB),
        .NB_ALUOP 			        (NB_ALUOP)
    )
    u_seg_instruction_decode
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_PC               (PC_if_id),
        .i_instruc          (instruction),
        .i_write_reg        (write_register_wb_id),
        .i_write_data       (write_data_wb_id),
        .i_RegWrite         (RegWrite_wb_id),
        //Outputs
        .o_PC               (PC_id_ex),
        .o_read_data_1      (read_data_1_id_ex),
        .o_read_data_2      (read_data_2_id_ex),
        .o_addr_ext         (address_ext_id_ex),
        .o_rt               (rt_id_ex),
        .o_rd               (rd_id_ex),
        //Control outputs
        .o_ctrl_wb_bus      (ctrl_wb_bus_id_ex),
        .o_ctrl_mem_bus     (ctrl_mem_bus_id_ex),
        .o_ctrl_exc_bus     (ctrl_exc_bus_id_ex)
    );
    
    // -----------------------------------------------
    // Execute (EX) 
    //------------------------------------------------
    seg_execute #(
        .LEN            (LEN),
        .NB_ALUOP       (NB_ALUOP),
        .NB_ALUCTL      (NB_ALUCTL),
        .NB_ADDR        (NB_ADDR),
        .NB_FUNC        (NB_FUNC),
        .NB_CTRL_WB     (NB_CTRL_WB),
        .NB_CTRL_M      (NB_CTRL_M),
        .NB_CTRL_EX     (NB_CTRL_EX)
    )
    u_seg_execute
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_add_PC           (PC_id_ex),
        .i_read_data_1      (read_data_1_id_ex),
        .i_read_data_2      (read_data_2_id_ex),
        .i_addr_ext         (address_ext_id_ex),
        .i_rt               (rt_id_ex),
        .i_rd               (rd_id_ex),
        //Control inputs    
        .i_ctrl_wb_bus      (ctrl_wb_bus_id_ex),
        .i_ctrl_mem_bus     (ctrl_mem_bus_id_ex),
        .i_ctrl_exc_bus     (ctrl_exc_bus_id_ex),
        //Output
        .o_PC_branch        (PC_branch_ex_mem),
        .o_ALU_result       (ALU_result_ex_mem),
        .o_write_data       (write_data_ex_mem),
        .o_write_register   (write_register_exc_mem),
        .o_ALU_zero         (ALU_zero),
        //Control outputs
        .o_ctrl_wb_bus      (ctrl_wb_bus_ex_mem),
        .o_ctrl_mem_bus     (ctrl_mem_bus_ex_mem)
    );

    // -----------------------------------------------
    // Memory Access (MEM) 
    //------------------------------------------------
    seg_memory_access #(
        .LEN                    (LEN),
        .NB_ADDR                (NB_ADDR),
        .NB_CTRL_WB             (NB_CTRL_WB),
        .NB_CTRL_M              (NB_CTRL_M),
        
        //DATA MEMORY
        .RAM_WIDTH_DATA         (RAM_WIDTH_DATA),
        .RAM_DEPTH_DATA         (RAM_DEPTH_DATA),
        .RAM_PERFORMANCE_DATA   (RAM_PERFORMANCE_DATA),
        .INIT_FILE_DATA         (INIT_FILE_DATA)
    )
    u_seg_memory_access
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_PC_branch        (PC_branch_ex_mem),
        .i_ALU_result       (ALU_result_ex_mem),
        .i_write_data       (write_data_ex_mem),
        .i_write_register   (write_register_exc_mem),
        .i_ALU_zero         (ALU_zero),
        .i_ctrl_wb_bus      (ctrl_wb_bus_ex_mem),
        .i_ctrl_mem_bus     (ctrl_mem_bus_ex_mem),
        //Output
        .o_PCSrc            (PCSrc_exc_if),
        .o_PC_branch        (PC_branch_mem_if),
        .o_read_data        (read_data_mem_wb),
        .o_address          (address_mem_wb),
        .o_write_register   (write_register_mem_wb),
        //Control outputs
        .o_ctrl_wb_bus      (ctrl_wb_bus_mem_wb)
    );

    // -----------------------------------------------
    // Write Back (WB) 
    //------------------------------------------------
    seg_write_back #(
        .LEN            (LEN),
        .NB_NB_ADDR     (NB_ADDR),
        .NB_CTRL_WB     (NB_CTRL_WB)
    )
    u_seg_write_back
    (
        //Input
        .i_clk              (i_clk),
        .i_read_data        (read_data_mem_wb),
        .i_address          (address_mem_wb),
        .i_write_register    (write_register_mem_wb),
        //Control inputs
        .i_ctrl_wb_bus      (ctrl_wb_bus_mem_wb),
        //Output
        .o_RegWrite         (RegWrite_wb_id),
        .o_write_data       (write_data_wb_id),
        .o_write_register   (write_register_wb_id)
    );
    
endmodule
