`timescale 1ns / 1ps

module top_mips
    #(
        parameter LEN           = 32,
        parameter NB_ADDRESS    = 16,
        parameter NB_OPCODE     = 6,
        parameter NB_OPERAND    = 11,
        parameter NB_ADDR       = 5,
        parameter NB_ALUOP      = 2,
        parameter NB_FUNC       = 6,
        parameter NB_ALUCTL     = 4,             
        parameter NB_CTRL_EX    = 10,
        parameter NB_CTRL_M     = 9,
        parameter NB_CTRL_WB    = 2,
        
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
        input                           i_clk,
        input                           i_rst,
        // Outputs
        output wire [LEN - 1 : 0]       o_led
    );
    
    // -----------------------------------------------
    // Instruction Fetch (IF) I/O wires
    //------------------------------------------------
    // Outputs
    output wire [LEN - 1 : 0] if_id_o_instruction; 
    output wire [LEN - 1 : 0] if_id_o_PC;
    
    // IF/ID registers
    reg [LEN-1:0]          if_id_reg_PC;
    reg [LEN-1:0]          if_id_reg_instruction;
    wire                   stall_flag;

    // -----------------------------------------------
    // Instruction decode (ID) I/O wires
    //------------------------------------------------
    // Inputs
    wire [LEN-1:0]         if_id_i_PC;
    wire [LEN-1:0]         if_id_i_instruction;
    // Outputs
    wire [LEN-1:0]         id_ex_o_PC;
    wire [LEN-1:0]         id_ex_o_read_data_1;
    wire [LEN-1:0]         id_ex_o_read_data_2;
    wire [LEN-1:0]         id_ex_o_addr_ext;
    wire [NB_ADDR-1:0]     id_ex_o_rt;
    wire [NB_ADDR-1:0]     id_ex_o_rd;
    wire [NB_CTRL_WB-1:0]  id_ex_o_ctrl_wb_bus;
    wire [NB_CTRL_M-1:0]   id_ex_o_ctrl_mem_bus;
    wire [NB_CTRL_EX-1:0]  id_ex_o_ctrl_exc_bus;
    wire [LEN-1:0]         id_if_PC_dir_jump;
    wire                   id_if_jump;
    
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

    // -----------------------------------------------
    // Execute (EX) I/O wires
    //------------------------------------------------
    // Inputs
    wire [LEN - 1 : 0]          id_ex_i_PC;
    wire [LEN - 1 : 0]          id_ex_i_read_data_1;
    wire [LEN - 1 : 0]          id_ex_i_read_data_2;
    wire [LEN - 1 : 0]          id_ex_i_addr_ext;
    wire [NB_ADDR - 1 : 0]      id_ex_i_rs;
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

    // MEM/WB registers
    reg [LEN - 1 : 0]           mem_wb_reg_read_data;
    reg [LEN - 1 : 0]           mem_wb_reg_ALU_result;
    reg [NB_ADDR - 1 : 0]       mem_wb_reg_write_register;
    reg [NB_CTRL_WB - 1 : 0]    mem_wb_reg_ctrl_wb_bus;

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

    // -----------------------------------------------
    // Forwarding Unit
    //------------------------------------------------
    wire [1:0]                  crtl_muxA_forwarding;
    wire [1:0]                  crtl_muxB_forwarding;


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
        .i_clk              (i_clk                  ),
        .i_rst              (i_rst                  ),
        .i_PC_branch        (mem_if_PC_branch       ),
        .i_PCSrc            (mem_if_PCSrc           ),
        .i_PC_dir_jump      (id_if_PC_dir_jump      ),
        .i_jump             (id_if_jump             ),
        .i_stall_flag       (stall_flag             ),
        // Outputs
        .o_instruction      (if_id_o_instruction    ),
        .o_PC               (if_id_o_PC             )
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
        // Outputs
        .o_rs               (id_ex_i_rs             ),
        .o_rt               (id_ex_i_rt             ),
        .o_rd               (id_ex_i_rd             ),
        .o_PC               (id_ex_o_PC             ),
        .o_read_data_1      (id_ex_o_read_data_1    ),
        .o_read_data_2      (id_ex_o_read_data_2    ),
        .o_addr_ext         (id_ex_o_addr_ext       ),
        .o_PC_dir_jump      (id_if_PC_dir_jump      ),
        .o_jump             (id_if_jump             ),
        .o_stall_flag       (stall_flag             ),
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
        .i_rt                   (rt                         ),
        .i_rd                   (rd                         ),
        // Control inputs    
        .i_ctrl_wb_bus          (id_ex_i_ctrl_wb_bus        ),
        .i_ctrl_mem_bus         (id_ex_i_ctrl_mem_bus       ),
        .i_ctrl_exc_bus         (id_ex_i_ctrl_exc_bus       ),
        // Forwarding
        .i_ctrl_muxA_forwarding (crtl_muxA_forwarding       ),
        .i_ctrl_muxB_forwarding (crtl_muxB_forwarding       ),
        .i_rd_mem_forwarding    (ex_mem_o_ALU_result        ),  //Salida de ALU 
        .i_rd_wb_forwarding     (wb_id_write_data           ),  //WB write data en banco de registros (mismo que en ID)
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
        // Inputs
        .i_read_data        (mem_wb_i_read_data         ),
        .i_ALU_result       (mem_wb_i_ALU_result        ),
        .i_write_register   (mem_wb_i_write_register    ),
        // Control inputs
        .i_ctrl_wb_bus      (mem_wb_i_ctrl_wb_bus       ),
        // Outputs
        .o_RegWrite         (wb_id_RegWrite             ),
        .o_write_data       (wb_id_write_data           ),
        .o_write_register   (wb_id_write_register       )
    );
    
    // -----------------------------------------------
    // Forwarding Unit (Unidad de Cortocircuito)  
    //------------------------------------------------
    forwarding_unit #(
        .LEN        (LEN        ),
        .NB_ADDR    (NB_ADDR    )
    )
    (
        .i_rs_id_ex         (id_ex_i_rs                 ),
        .i_rt_id_ex         (id_ex_i_rt                 ),
        .i_write_reg_ex_mem (ex_mem_o_write_register    ),  
        .i_write_reg_mem_wb (wb_id_write_register       ),
        .i_reg_write_ex_mem (mem_wb_i_ctrl_wb_bus[1]    ),
        .i_reg_write_mem_wb (wb_id_RegWrite             ),
        .o_muxA_alu         (crtl_muxA_forwarding       ),
        .o_muxB_alu         (crtl_muxB_forwarding       )
    );
    
    
endmodule
