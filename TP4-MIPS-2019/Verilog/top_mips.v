`timescale 1ns / 1ps

module top_mips
    #( parameter    //CPU
                    LEN             = 32,
                    NB_ADDRESS      = 16,
                    NB_OPCODE       = 6,
                    NB_OPERAND      = 11,
                    NB_ADDR         = 5,
                    NB_ALUOP        = 2,
       parameter    NB_FUNC         = 6,
       parameter    NB_ALUCTL       = 4,             
       parameter    NB_EXC_BUS      = 3,
       parameter    NB_MEM_BUS      = 3,
       parameter    NB_WB_BUS       = 2,
                    
                    //PROGRAM MEMORY
                    RAM_WIDTH_PROGRAM       = 32,
                    RAM_DEPTH_PROGRAM       = 2048,
                    RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY",
                    INIT_FILE_PROGRAM       = "",
                    
                    //DATA MEMORY
                    RAM_WIDTH_DATA          = 32,
                    RAM_DEPTH_DATA          = 1024, 
                    RAM_PERFORMANCE_DATA    = "LOW_LATENCY",
                    INIT_FILE_DATA          = "" 
    )
    (
        //inputs
        input                           i_clk,
        input                           i_rst,
        //outputs
        output wire [LEN - 1 : 0]       o_led
    );

    //Wire CPU - Memory
    wire [NB_ADDR-1:0]  addr_program_mem;
    wire [LEN-1:0]      instruc;
    wire [NB_ADDR-1:0]  addr_data_mem;
    wire [LEN-1:0]      in_data_memory;
    wire [LEN-1:0]      out_data_memory;
    wire [LEN-1:0]      o_alu;
    
    //Control wires
    wire [NB_WB_BUS-1:0]    wb_bus;   // [ RegWrite, MemtoReg]
    wire [NB_MEM_BUS-1:0]   mem_bus;  // [ SB, SH, LB, LH, Unsigned, Branch, MemRead, MemWrite ]
    wire [NB_EXC_BUS-1:0]   exc_bus;  // [ Jump&Link, JALOnly, RegDst, ALUSrc[1:0] , jump, jump_register, ALUCode [3:0] 
    wire [NB_ALUOP-1:0]     alu_op;
    
    //Instruction fetch I/O wires
    wire [LEN-1:0]          PC_branch;      //PC -> Add PC + (shiftleft << 2)
    wire                    PCSrc;          //Selector del MUX de PC
    wire [LEN-1:0]          instruction;    //Instruccion de 32 bits
    wire [LEN-1:0]          PC_id_ex;       //Program Counter
    
    //Instruction decode I/O wires
    wire [LEN-1:0]          id_read_data_1; //Salida de ID 
    wire [LEN-1:0]          id_read_data_2; //Salida de ID
    wire [LEN-1:0]          id_address_ext; //Salida de ID
    wire [NB_OPCODE-1:0]    funct;          
    
    
    //Execute I/O wires
    //wire [LEN-1:0]          PC_branch;         //PC -> Add PC + (shiftleft << 2)
    wire [LEN-1:0]          ALU_result;    
    wire                    ALU_zero;
    
    //Data Memory I/O wires
    wire [LEN-1:0]          dm_read_data;
    
    //Write Back I/O wires 
    wire [LEN-1:0]          write_data_md;


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
        .i_PC_branch        (PC_branch),
        .i_PCSrc            (PCSrc),
        //Output
        .o_instruction      (instruction),
        .o_PC               (PC)
    );
    
    // -----------------------------------------------
    // Instruction Decode (ID) 
    //------------------------------------------------
    seg_instruction_decode #(
        .NB_INSTRUC                 (LEN),
        .NB_REG                     (LEN),
        .NB_EXC_BUS                 (NB_EXC_BUS),
        .NB_MEM_BUS                 (NB_MEM_BUS),
        .NB_OPCODE                  (NB_OPCODE),
        .NB_ADDR                    (NB_ADDR),
        .NB_WB_BUS                  (NB_WB_BUS),
        .NB_ALUOP 			        (NB_ALUOP)
    )
    u_seg_instruction_decode
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_instruc          (instruc),
        .i_regdst
        .i_write_data       (write_data_md),
        //Outputs
        .o_read_data_1      (id_read_data_1),
        .o_read_data_2      (id_read_data_2),
        .o_addr_ext         (id_address_ext),
        .o_wb_bus           (wb_bus),
        .o_mem_bus          (mem_bus),
        .o_exc_bus          (exc_bus),
        .o_alu_op           (alu_op),
        .o_funct            (funct)
        
        
    );
    
    // -----------------------------------------------
    // Execute (EX) 
    //------------------------------------------------
    seg_execute #(
        .LEN            (LEN),
        .NB_ALUOP       (NB_ALUOP),
        .NB_ALUCTL      (NB_ALUCTL),
        .NB_FUNC        (NB_FUNC),
        .NB_WB_BUS      (NB_WB_BUS),
        .NB_MEM_BUS     (NB_MEM_BUS),
        .NB_EXC_BUS     (NB_EXC_BUS)
    )
    u_seg_execute
    (
        //Input
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_add_PC           (PC),
        .i_addr_ext         (id_address_ext),
        .i_read_data_1      (id_read_data_1),
        .i_read_data_2      (id_read_data_2),
        .i_wb_bus           (wb_bus),
        .i_mem_bus          (mem_bus),
        .i_exc_bus          (exc_bus),
        .i_alu_op           (alu_op),
        .i_funct            (funct),
//        .i_instruction_15_0              (i_instruction_15_0),
//        .i_instruction_20_16              (i_instruction_20_16),
//        .i_instruction_15_11              (i_instruction_15_11),
//        .i_control              (i_control),
        //Output
        .o_PC               (PC_branch),
        .o_ALU_result       (ALU_result),
        .o_ALU_zero         (ALU_zero)
//        .o_read_data_2      (o_read_data_2),
//        .o_instruction_20_16_o_15_11          (o_instruction_20_16_o_15_11),
//        .o_control          (o_control)
    );

    // -----------------------------------------------
    // Memory Access (MEM) 
    //------------------------------------------------
    seg_memory_access #(
        .LEN                    (LEN),
        .NB_WB_BUS              (NB_WB_BUS),
        .NB_MEM_BUS             (NB_MEM_BUS),
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
        .i_address          (ALU_result),
        .i_write_data       (id_read_data_2),
        .i_ALU_zero         (ALU_zero),
        .i_wb_bus           (wb_bus),
        .i_mem_bus          (mem_bus),
 //     .i_instruction_20_16_o_15_11      (i_instruction_20_16_o_15_11),
//      .i_control          (i_control),
        //Output
        .o_PCSrc            (PCSrc),
        .o_read_data        (dm_read_data)
//        .o_address          (o_address)
//        .o_instruction_20_16_o_15_11      (o_instruction_20_16_o_15_11),
//        .o_control          (o_control)
    );

    // -----------------------------------------------
    // Write Back (WB) 
    //------------------------------------------------
    seg_write_back #(
        .LEN            (LEN),
        .NB_NB_ADDR     (NB_ADDR),
        .NB_WB_BUS      (NB_WB_BUS)
    )
    u_seg_write_back
    (
        //Input
        .i_clk              (i_clk),
        .i_data_mem         (dm_read_data),
        .i_data_alu         (ALU_result),
        .i_wb_bus           (wb_bus),
        //Output
        .o_regdst
        .o_write_data       (write_data_md)
    );
    
endmodule
