`timescale 1ns / 1ps

module top_mips
    #(
        parameter LEN           = 32,
        parameter NB_ADDRESS    = 16,
        parameter NB_OPCODE     = 6,
        parameter NB_OPERAND    = 11,
        parameter NB_ADDR       = 5,
        parameter NB_ALUOP      = 4,
        parameter NB_FUNC       = 6,
        parameter NB_ALUCTL     = 4,             
        parameter NB_CTRL_EX    = 6,
        parameter NB_CTRL_M     = 9,
        parameter NB_CTRL_WB    = 2,
        //Latches 
        parameter NB_IF_ID      = 64,
        parameter NB_ID_EX      = 163,
        parameter NB_EX_MEM     = 145,
        parameter NB_MEM_WB     = 72,
        
        //PROGRAM MEMORY
        parameter RAM_WIDTH_PROGRAM       = 32,
        parameter RAM_DEPTH_PROGRAM       = 2048,
        parameter RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY",
        parameter INIT_FILE_PROGRAM       = "",

        //DATA MEMORY
        parameter RAM_WIDTH_DATA          = 32,
        parameter RAM_DEPTH_DATA          = 1024, 
        parameter RAM_PERFORMANCE_DATA    = "LOW_LATENCY",
        parameter INIT_FILE_DATA          = "" 
    )
    (
        // Inputs
        input wire               i_clk,
        input wire               i_rst,
        input wire               i_preload_flag,
        input wire [LEN - 1 : 0] i_preload_address,
        input wire [LEN - 1 : 0] i_preload_instruction,
        // Outputs
        // output wire [LEN - 1 : 0]       o_led
        output      [NB_IF_ID  -1 : 0]  o_latch_if_id,
        output      [NB_ID_EX  -1 : 0]  o_latch_id_ex,
        output      [NB_EX_MEM -1 : 0]  o_latch_ex_mem,
        output      [NB_MEM_WB -1 : 0]  o_latch_mem_wb
    );
    
    // -----------------------------------------------
    // Instruction Fetch (IF) I/O wires
    //------------------------------------------------
    // Outputs
    wire [LEN - 1 : 0]  if_id_o_instruction;
    wire [LEN - 1 : 0]  if_id_o_PC;
    
    // IF/ID registers
    reg [LEN-1:0]       if_id_reg_PC;
    reg [LEN-1:0]       if_id_reg_instruction;

    // -----------------------------------------------
    // Instruction decode (ID) I/O wires
    //------------------------------------------------
    // Inputs
    wire [LEN-1:0]         if_id_i_PC;
    wire [LEN-1:0]         if_id_i_instruction;
    wire [NB_ADDR-1:0]     id_id_i_rt;
    wire [NB_ADDR-1:0]     id_id_i_PCSrc;
    // Outputs
    wire [LEN-1:0]          id_ex_o_PC;
    wire [LEN-1:0]          id_ex_o_read_data_1;
    wire [LEN-1:0]          id_ex_o_read_data_2;
    wire [LEN-1:0]          id_ex_o_addr_ext;
    wire [NB_ADDR-1:0]      id_fu_o_rs;
    wire [NB_ADDR-1:0]      id_ex_o_rt;
    wire [NB_ADDR-1:0]      id_ex_o_rd;
    wire [NB_CTRL_WB-1:0]   id_ex_o_ctrl_wb_bus;
    wire [NB_CTRL_M-1:0]    id_ex_o_ctrl_mem_bus;
    wire [NB_CTRL_EX-1:0]   id_ex_o_ctrl_exc_bus;
    wire [LEN-1:0]          id_if_PC_dir_jump;
    wire                    id_if_jump_flag;
    wire                    id_if_stall_flag;

    // ID/EX registers
    reg [LEN - 1 : 0]           id_ex_reg_PC;
    reg [LEN - 1 : 0]           id_ex_reg_read_data_1;
    reg [LEN - 1 : 0]           id_ex_reg_read_data_2;
    reg [LEN - 1 : 0]           id_ex_reg_addr_ext;
    reg [NB_ADDR - 1 : 0]       id_ex_reg_rt;
    reg [NB_ADDR - 1 : 0]       id_ex_reg_rd;
    reg [NB_CTRL_WB - 1 : 0]    id_ex_reg_ctrl_wb_bus;
    reg [NB_CTRL_M - 1 :  0]    id_ex_reg_ctrl_mem_bus;
    reg [NB_CTRL_EX - 1 : 0]    id_ex_reg_ctrl_exc_bus;
    // ID/FU registers
    reg [NB_ADDR - 1 : 0]       id_fu_reg_rs;

    // -----------------------------------------------
    // Execute (EX) I/O wires
    //------------------------------------------------
    // Inputs
    wire [LEN - 1 : 0]          id_ex_i_PC;
    wire [LEN - 1 : 0]          id_ex_i_read_data_1;
    wire [LEN - 1 : 0]          id_ex_i_read_data_2;
    wire [LEN - 1 : 0]          id_ex_i_addr_ext;
    wire [NB_ADDR - 1 : 0]      id_ex_i_rt;
    wire [NB_ADDR - 1 : 0]      id_ex_i_rd;
    wire [NB_CTRL_WB - 1 : 0]   id_ex_i_ctrl_wb_bus;
    wire [NB_CTRL_M - 1 :  0]   id_ex_i_ctrl_mem_bus;
    wire [NB_CTRL_EX - 1 : 0]   id_ex_i_ctrl_exc_bus;
    // Outputs
    wire [LEN - 1 : 0]          ex_mem_o_PC_branch;
    wire [LEN - 1 : 0]          ex_mem_o_ALU_result;
    wire [LEN - 1 : 0]          ex_mem_o_write_data;
    wire [NB_ADDR - 1 : 0]      ex_mem_o_write_register;
    wire                        ex_mem_o_ALU_zero;
    wire [NB_CTRL_WB - 1 : 0]   ex_mem_o_ctrl_wb_bus;
    wire [NB_CTRL_M - 1 : 0]    ex_mem_o_ctrl_mem_bus;

    // EX/MEM registers
    reg [LEN - 1 : 0]       ex_mem_reg_PC_branch;
    reg [LEN - 1 : 0]       ex_mem_reg_ALU_result;
    reg [LEN - 1 : 0]       ex_mem_reg_write_data;
    reg [NB_ADDR-1:0]       ex_mem_reg_write_register;
    reg                     ex_mem_reg_ALU_zero;
    reg [NB_CTRL_WB-1:0]    ex_mem_reg_ctrl_wb_bus;
    reg [NB_CTRL_M-1:0]     ex_mem_reg_ctrl_mem_bus;

    // -----------------------------------------------
    // Memory Access (MEM) I/O wires
    //------------------------------------------------
    // Inputs
    wire [LEN - 1 : 0]      ex_mem_i_PC_branch;
    wire [LEN - 1 : 0]      ex_mem_i_ALU_result;
    wire [LEN - 1 : 0]      ex_mem_i_write_data;
    wire [NB_ADDR-1:0]      ex_mem_i_write_register;
    wire                    ex_mem_i_ALU_zero;
    wire [NB_CTRL_WB-1:0]   ex_mem_i_ctrl_wb_bus;
    wire [NB_CTRL_M-1:0]    ex_mem_i_ctrl_mem_bus;
    // Outputs
    wire                    mem_if_PCSrc;
    wire [LEN - 1 : 0]      mem_if_PC_branch;
    wire [LEN - 1 : 0]      mem_wb_o_read_data;
    wire [LEN - 1 : 0]      mem_wb_o_address;
    wire [NB_ADDR-1:0]      mem_wb_o_write_register;
    wire [NB_CTRL_WB-1:0]   mem_wb_o_ctrl_wb_bus;
    // MEM/EX wires
    wire                    mem_ex_flush;
    // MEM/ID wires
    wire                    mem_id_flush;

    // MEM/WB registers
    reg [LEN - 1 : 0]           mem_wb_reg_read_data;
    reg [LEN - 1 : 0]           mem_wb_reg_ALU_result;
    reg [NB_ADDR - 1 : 0]       mem_wb_reg_write_register;
    reg [NB_CTRL_WB - 1 : 0]    mem_wb_reg_ctrl_wb_bus;
    // MEM/EX


    // -----------------------------------------------
    // Write Back (WB) I/O wires
    //------------------------------------------------
    // Inputs
    wire [LEN - 1 : 0]          mem_wb_i_read_data;
    wire [LEN - 1 : 0]          mem_wb_i_ALU_result;
    wire [NB_ADDR - 1 : 0]      mem_wb_i_write_register;
    wire [NB_CTRL_WB - 1 : 0]   mem_wb_i_ctrl_wb_bus;
    // Outputs
    wire                        wb_id_RegWrite;
    wire [LEN - 1 : 0]          wb_id_write_data;
    wire [NB_ADDR - 1 : 0]      wb_id_write_register;
    // Outputs - forwarding
    wire                        wb_id_RegWrite_forwarding;
    wire [LEN - 1 : 0]          wb_id_write_data_forwarding;
    wire [NB_ADDR - 1 : 0]      wb_id_write_register_forwarding;

    // -----------------------------------------------
    // Forwarding Unit
    //------------------------------------------------
    wire [NB_ADDR - 1 : 0]      id_fu_i_rs;
    wire [1:0]                  fu_ex_muxA_forwarding;
    wire [1:0]                  fu_ex_muxB_forwarding;

    // -----------------------------------------------
    // Inter-segment outputs 
    //------------------------------------------------
    assign o_latch_if_id = {
                            if_id_reg_PC,               //32 bits
                            if_id_reg_instruction       //32 bits
                           }; //Total = 64 bits

    assign o_latch_id_ex = {
                            id_ex_reg_PC,               //32 bits
                            id_ex_reg_read_data_1,      //32 bits
                            id_ex_reg_read_data_2,      //32 bits
                            id_ex_reg_addr_ext,         //32 bits
                            id_fu_reg_rs,               //6  bits
                            id_ex_reg_rt,               //6  bits
                            id_ex_reg_rd,               //6  bits
                            id_ex_reg_ctrl_wb_bus,      //2  bits
                            id_ex_reg_ctrl_mem_bus,     //9  bits
                            id_ex_reg_ctrl_exc_bus     //6  bits
                           }; //Total = 163 bits

    assign o_latch_ex_mem = {
                            ex_mem_reg_PC_branch,       //32 bits
                            ex_mem_reg_ALU_result,      //32 bits
                            ex_mem_reg_write_data,      //32 bits
                            ex_mem_reg_write_register,  //6  bits
                            ex_mem_reg_ALU_zero,        //32 bits
                            ex_mem_reg_ctrl_wb_bus,     //2  bits
                            ex_mem_reg_ctrl_mem_bus    //9  bits
                            }; //Total = 145 bits

    assign o_latch_mem_wb = {
                            mem_wb_reg_read_data,       //32 bits
                            mem_wb_reg_ALU_result,      //32 bits
                            mem_wb_reg_write_register,  //6  bits
                            mem_wb_reg_ctrl_wb_bus      //2  bits
                            }; //Total = 72 bits

    // -----------------------------------------------
    // Inter-segment register logic 
    //------------------------------------------------
    always @(negedge i_clk) begin
        if (!i_rst) begin
            // IF/ID registers
            if_id_reg_PC                <= {LEN{1'b0}};
            if_id_reg_instruction       <= {LEN{1'b0}};
            // ID/EX registers
            id_ex_reg_PC                <= {LEN{1'b0}};
            id_ex_reg_read_data_1       <= {LEN{1'b0}};
            id_ex_reg_read_data_2       <= {LEN{1'b0}};
            id_ex_reg_addr_ext          <= {LEN{1'b0}};
            id_fu_reg_rs                <= {NB_ADDR{1'b0}};
            id_ex_reg_rt                <= {NB_ADDR{1'b0}};
            id_ex_reg_rd                <= {NB_ADDR{1'b0}};
            id_ex_reg_ctrl_wb_bus       <= {NB_CTRL_WB{1'b0}};
            id_ex_reg_ctrl_mem_bus      <= {NB_CTRL_M{1'b0}};
            id_ex_reg_ctrl_exc_bus      <= {NB_CTRL_EX{1'b0}};
            // EX/MEM registers
            ex_mem_reg_PC_branch        <= {LEN{1'b0}};
            ex_mem_reg_ALU_result       <= {LEN{1'b0}};
            ex_mem_reg_write_data       <= {LEN{1'b0}};
            ex_mem_reg_write_register   <= {NB_ADDR{1'b0}};
            ex_mem_reg_ALU_zero         <= {LEN{1'b0}};
            ex_mem_reg_ctrl_wb_bus      <= {NB_CTRL_WB{1'b0}};
            ex_mem_reg_ctrl_mem_bus     <= {NB_CTRL_M{1'b0}};
            // MEM/WB registers
            mem_wb_reg_read_data        <= {LEN{1'b0}};
            mem_wb_reg_ALU_result       <= {LEN{1'b0}};
            mem_wb_reg_write_register   <= {NB_ADDR{1'b0}};
            mem_wb_reg_ctrl_wb_bus      <= {NB_CTRL_WB{1'b0}};
        end else begin
            // IF/ID registers
            if_id_reg_PC                <= if_id_o_PC;
            if_id_reg_instruction       <= if_id_o_instruction;
            // ID/EX registers
            id_ex_reg_PC                <= id_ex_o_PC;
            id_ex_reg_read_data_1       <= id_ex_o_read_data_1;
            id_ex_reg_read_data_2       <= id_ex_o_read_data_2;
            id_ex_reg_addr_ext          <= id_ex_o_addr_ext;
            id_fu_reg_rs                <= id_fu_o_rs;
            id_ex_reg_rt                <= id_ex_o_rt;
            id_ex_reg_rd                <= id_ex_o_rd;
            id_ex_reg_ctrl_wb_bus       <= id_ex_o_ctrl_wb_bus;
            id_ex_reg_ctrl_mem_bus      <= id_ex_o_ctrl_mem_bus;
            id_ex_reg_ctrl_exc_bus      <= id_ex_o_ctrl_exc_bus;
            // EX/MEM registers
            ex_mem_reg_PC_branch        <= ex_mem_o_PC_branch;
            ex_mem_reg_ALU_result       <= ex_mem_o_ALU_result;
            ex_mem_reg_write_data       <= ex_mem_o_write_data;
            ex_mem_reg_write_register   <= ex_mem_o_write_register;
            ex_mem_reg_ALU_zero         <= ex_mem_o_ALU_zero;
            ex_mem_reg_ctrl_wb_bus      <= ex_mem_o_ctrl_wb_bus;
            ex_mem_reg_ctrl_mem_bus     <= ex_mem_o_ctrl_mem_bus;
            // MEM/WB registers
            mem_wb_reg_read_data        <= mem_wb_o_read_data;
            mem_wb_reg_ALU_result       <= mem_wb_o_address;
            mem_wb_reg_write_register   <= mem_wb_o_write_register;
            mem_wb_reg_ctrl_wb_bus      <= mem_wb_o_ctrl_wb_bus;
        end
    end

    // IF/ID registers
    assign if_id_i_PC                  = if_id_reg_PC;
    assign if_id_i_instruction         = if_id_reg_instruction;
    // ID/ID register
    assign id_id_i_rt                  = id_ex_reg_rt;
    // ID/EX registers
    assign id_ex_i_PC                  = id_ex_reg_PC;
    assign id_ex_i_read_data_1         = id_ex_reg_read_data_1;
    assign id_ex_i_read_data_2         = id_ex_reg_read_data_2;
    assign id_ex_i_addr_ext            = id_ex_reg_addr_ext;
    assign id_fu_i_rs                  = id_fu_reg_rs;
    assign id_ex_i_rt                  = id_ex_reg_rt;
    assign id_ex_i_rd                  = id_ex_reg_rd;
    assign id_ex_i_ctrl_wb_bus         = id_ex_reg_ctrl_wb_bus;
    assign id_ex_i_ctrl_mem_bus        = id_ex_reg_ctrl_mem_bus;
    assign id_ex_i_ctrl_exc_bus        = id_ex_reg_ctrl_exc_bus;
    // EX/MEM registers
    assign ex_mem_i_PC_branch          = ex_mem_reg_PC_branch;
    assign ex_mem_i_ALU_result         = ex_mem_reg_ALU_result;
    assign ex_mem_i_write_data         = ex_mem_reg_write_data;
    assign ex_mem_i_write_register     = ex_mem_reg_write_register;
    assign ex_mem_i_ALU_zero           = ex_mem_reg_ALU_zero;
    assign ex_mem_i_ctrl_wb_bus        = ex_mem_reg_ctrl_wb_bus;
    assign ex_mem_i_ctrl_mem_bus       = ex_mem_reg_ctrl_mem_bus;
    // MEM/WB registers
    assign mem_wb_i_read_data          = mem_wb_reg_read_data;
    assign mem_wb_i_ALU_result         = mem_wb_reg_ALU_result;
    assign mem_wb_i_write_register     = mem_wb_reg_write_register;
    assign mem_wb_i_ctrl_wb_bus        = mem_wb_reg_ctrl_wb_bus;

    // MEM/EX wires
    assign mem_ex_flush                = mem_if_PCSrc;
    // MEM/ID wires
    assign mem_id_flush                = mem_if_PCSrc;

    // -----------------------------------------------
    // Instruction Fetch (IF) 
    //------------------------------------------------
    seg_instruction_fetch #(
        .LEN                        (LEN                        ),
        .RAM_WIDTH_PROGRAM 			(RAM_WIDTH_PROGRAM          ),
        .RAM_DEPTH_PROGRAM 			(RAM_DEPTH_PROGRAM          ),
        .RAM_PERFORMANCE_PROGRAM 	(RAM_PERFORMANCE_PROGRAM    ),
        .INIT_FILE_PROGRAM 			(INIT_FILE_PROGRAM          )
    )
    u_seg_instruction_fetch (
        // Inputs
        .i_clk                  (i_clk                  ),
        .i_rst                  (i_rst                  ),
        .i_PC_branch            (mem_if_PC_branch       ),
        .i_PCSrc                (mem_if_PCSrc           ),
        .i_PC_dir_jump          (id_if_PC_dir_jump      ),
        .i_jump                 (id_if_jump_flag        ),
        .i_stall_flag           (id_if_stall_flag       ),
        .i_preload_flag         (i_preload_flag         ),
        .i_preload_address      (i_preload_address      ),
        .i_preload_instruction  (i_preload_instruction  ),
        // Outputs
        .o_instruction          (if_id_o_instruction    ),
        .o_PC                   (if_id_o_PC             )
    );
    
    // -----------------------------------------------
    // Instruction Decode (ID) 
    //------------------------------------------------
    seg_instruction_decode #(
        .LEN        (LEN            ),
        .NB_REG     (LEN            ),
        .NB_ADDRESS (NB_ADDRESS     ),
        .NB_OPCODE  (NB_OPCODE      ),
        .NB_ADDR    (NB_ADDR        ),
        .NB_CTRL_EX (NB_CTRL_EX     ),
        .NB_CTRL_M  (NB_CTRL_M      ),
        .NB_CTRL_WB (NB_CTRL_WB     )
    )
    u_seg_instruction_decode (
        // Inputs
        .i_clk              (i_clk                  ),
        .i_rst              (i_rst                  ),
        .i_PC               (if_id_i_PC             ),
        .i_instruction      (if_id_i_instruction    ),
        .i_write_reg        (wb_id_write_register   ),
        .i_write_data       (wb_id_write_data       ),
        .i_RegWrite         (wb_id_RegWrite         ),
        .i_flush            (mem_id_flush           ),
        .i_rt_ex            (id_id_i_rt             ),
        .i_id_ex_ctrl_mem_bus_MemRead (id_ex_i_ctrl_mem_bus[1]),
        // Outputs
        .o_rs               (id_fu_o_rs             ),
        .o_rt               (id_ex_o_rt             ),
        .o_rd               (id_ex_o_rd             ),
        .o_PC               (id_ex_o_PC             ),
        .o_read_data_1      (id_ex_o_read_data_1    ),
        .o_read_data_2      (id_ex_o_read_data_2    ),
        .o_addr_ext         (id_ex_o_addr_ext       ),
        .o_PC_dir_jump      (id_if_PC_dir_jump      ),
        .o_jump_flag        (id_if_jump_flag        ),
        .o_stall_flag       (id_if_stall_flag       ),
        // Control outputs
        .o_ctrl_wb_bus      (id_ex_o_ctrl_wb_bus    ),  // [ RegWrite, MemtoReg]
        .o_ctrl_mem_bus     (id_ex_o_ctrl_mem_bus   ),  // [ SB, SH, LB, LH, Unsigned, BNEQ, Branch, MemRead, MemWrite ]
        .o_ctrl_exc_bus     (id_ex_o_ctrl_exc_bus   )   // [ JAL, JR, JALR, Jump, ALUSrc, AluOp[3], AluOp[2], AluOp[1], AluOp[0], RegDst]
    );
    
    // -----------------------------------------------
    // Execute (EX) 
    //------------------------------------------------
    seg_execute #(
        .LEN            (LEN        ),
        .NB_ALUOP       (NB_ALUOP   ),
        .NB_ALUCTL      (NB_ALUCTL  ),
        .NB_ADDR        (NB_ADDR    ),
        .NB_FUNC        (NB_FUNC    ),
        .NB_CTRL_WB     (NB_CTRL_WB ),
        .NB_CTRL_M      (NB_CTRL_M  ),
        .NB_CTRL_EX     (NB_CTRL_EX )
    )
    u_seg_execute (
        // Inputs
        .i_clk                  (i_clk                      ),
        .i_rst                  (i_rst                      ),
        .i_PC                   (id_ex_i_PC                 ),
        .i_read_data_1          (id_ex_i_read_data_1        ),
        .i_read_data_2          (id_ex_i_read_data_2        ),
        .i_addr_ext             (id_ex_i_addr_ext           ),
        .i_rt                   (id_ex_i_rt                 ),
        .i_rd                   (id_ex_i_rd                 ),
        .i_flush                (mem_ex_flush               ),
        // Control inputs    
        .i_ctrl_wb_bus          (id_ex_i_ctrl_wb_bus        ),
        .i_ctrl_mem_bus         (id_ex_i_ctrl_mem_bus       ),
        .i_ctrl_exc_bus         (id_ex_i_ctrl_exc_bus       ),
        // Forwarding
        .i_muxA_forwarding      (fu_ex_muxA_forwarding      ),
        .i_muxB_forwarding      (fu_ex_muxB_forwarding      ),
        .i_rd_mem_forwarding    (ex_mem_i_ALU_result        ),  //Salida de ALU 
        .i_rd_wb_forwarding     (wb_id_write_data_forwarding),  //WB write data en banco de registros (mismo que en ID)
        // Outputs
        .o_PC_branch            (ex_mem_o_PC_branch         ),
        .o_ALU_result           (ex_mem_o_ALU_result        ),
        .o_write_data           (ex_mem_o_write_data        ),
        .o_write_register       (ex_mem_o_write_register    ),
        .o_ALU_zero             (ex_mem_o_ALU_zero          ),
        // Control outputs
        .o_ctrl_wb_bus          (ex_mem_o_ctrl_wb_bus       ),
        .o_ctrl_mem_bus         (ex_mem_o_ctrl_mem_bus      )
    );

    // -----------------------------------------------
    // Memory Access (MEM) 
    //------------------------------------------------
    seg_memory_access #(
        .LEN                    (LEN                    ),
        .NB_ADDR                (NB_ADDR                ),
        .NB_CTRL_WB             (NB_CTRL_WB             ),
        .NB_CTRL_M              (NB_CTRL_M              ),
        
        //DATA MEMORY
        .RAM_WIDTH_DATA         (RAM_WIDTH_DATA         ),
        .RAM_DEPTH_DATA         (RAM_DEPTH_DATA         ),
        .RAM_PERFORMANCE_DATA   (RAM_PERFORMANCE_DATA   ),
        .INIT_FILE_DATA         (INIT_FILE_DATA         )
    )
    u_seg_memory_access
    (
        // Inputs
        .i_clk              (i_clk                      ),
        .i_rst              (i_rst                      ),
        .i_PC_branch        (ex_mem_i_PC_branch         ),
        .i_ALU_result       (ex_mem_i_ALU_result        ),
        .i_write_data       (ex_mem_i_write_data        ),
        .i_write_register   (ex_mem_i_write_register    ),
        .i_ALU_zero         (ex_mem_i_ALU_zero          ),
        .i_ctrl_wb_bus      (ex_mem_i_ctrl_wb_bus       ),
        .i_ctrl_mem_bus     (ex_mem_i_ctrl_mem_bus      ),
        // Outputs
        .o_PCSrc            (mem_if_PCSrc               ),
        .o_PC_branch        (mem_if_PC_branch           ),
        .o_read_data        (mem_wb_o_read_data         ),
        .o_address          (mem_wb_o_address           ),
        .o_write_register   (mem_wb_o_write_register    ),
        // Control outputs
        .o_ctrl_wb_bus      (mem_wb_o_ctrl_wb_bus       )
    );

    // -----------------------------------------------
    // Write Back (WB) 
    //------------------------------------------------
    seg_write_back #(
        .LEN            (LEN            ),
        .NB_ADDR        (NB_ADDR        ),
        .NB_CTRL_WB     (NB_CTRL_WB     )
    )
    u_seg_write_back
    (
        // Inputs - VIA WIRES
        .i_read_data        (mem_wb_o_read_data         ),
        .i_ALU_result       (mem_wb_o_address           ),
        .i_write_register   (mem_wb_o_write_register    ),
        // Control inputs
        .i_ctrl_wb_bus      (mem_wb_o_ctrl_wb_bus       ),
        // Outputs
        .o_RegWrite         (wb_id_RegWrite             ),
        .o_write_data       (wb_id_write_data           ),
        .o_write_register   (wb_id_write_register       )
    );
    // WB Auxiliario para forwarding
    seg_write_back #(
        .LEN            (LEN            ),
        .NB_ADDR        (NB_ADDR        ),
        .NB_CTRL_WB     (NB_CTRL_WB     )
    )
    u_seg_write_back_forwarding
    (
        // Inputs - VIA TOP REGISTERS
        .i_read_data        (mem_wb_i_read_data         ),
        .i_ALU_result       (mem_wb_i_ALU_result        ),
        .i_write_register   (mem_wb_i_write_register    ),
        // Control inputs
        .i_ctrl_wb_bus      (mem_wb_i_ctrl_wb_bus       ),
        // Outputs
        .o_RegWrite         (                           ),
        .o_write_data       (wb_id_write_data_forwarding),
        .o_write_register   (                           )
    );
    
    // -----------------------------------------------
    // Forwarding Unit (FU) (Unidad de Cortocircuito)  
    //------------------------------------------------
    forwarding_unit #(
        .LEN        (LEN        ),
        .NB_ADDR    (NB_ADDR    )
    )
    u_forwarding_unit
    (
        .i_rs_id_ex                 (id_fu_i_rs                 ),
        .i_rt_id_ex                 (id_ex_i_rt                 ),
        .i_write_reg_ex_mem         (ex_mem_i_write_register    ),
        .i_write_reg_mem_wb         (mem_wb_i_write_register    ),
        .i_reg_write_flag_ex_mem    (ex_mem_i_ctrl_wb_bus[1]    ),
        .i_reg_write_flag_mem_wb    (mem_wb_i_ctrl_wb_bus[1]    ),
        .o_muxA_alu                 (fu_ex_muxA_forwarding      ),
        .o_muxB_alu                 (fu_ex_muxB_forwarding      )
    );
    
    
endmodule
