`timescale 1ns / 1ps

module seg_instruction_fetch
    #( parameter
        LEN                     = 32,
        //PROGRAM MEMORY
        RAM_WIDTH_PROGRAM       = 32,
        RAM_DEPTH_PROGRAM       = 2048,
        RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY",
        INIT_FILE_PROGRAM       = ""
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire  [LEN - 1 : 0]           i_PC_branch, //Branch o Jump
        input wire  [LEN - 1 : 0]           i_PC_dir_jump,
        input wire                          i_PCSrc,
        input wire                          i_jump,
        input wire                          i_stall_flag,
        input wire                          i_preload_flag,
        input wire  [LEN - 1 : 0]           i_preload_address,
        input wire  [LEN - 1 : 0]           i_preload_instruction,
        input wire                          i_enable_pipeline,
        // OUTPUTS
        output wire [LEN - 1 : 0]           o_instruction,
        output wire [LEN - 1 : 0]           o_PC
    );
    
    //Memory
    wire [LEN - 1 : 0]  mem_address;
    wire                ena;
    wire                rsta;
    wire                regcea;
    wire                halt_flag;

    // Program Counter Register
    reg [LEN - 1 : 0]   reg_PC = {LEN{1'b0}};
    reg [LEN - 1 : 0]   reg_PC_aumentado;
    
    //Control Memoria
    assign ena      = 1;
    assign rsta     = 0;
    assign regcea   = 1;
    
    //---------------------------------------
    // Program Counter Logic
    //---------------------------------------

    // always @(posedge i_clk) begin
    //     if (!i_rst) begin
    //         reg_PC <= {LEN{1'b0}};
    //     end else if (i_enable_pipeline) begin
    //         if (i_PCSrc) begin
    //             if (halt_flag) begin
    //                 reg_PC <= i_PC_branch;
    //             end else begin
    //                 reg_PC <= i_PC_branch + 1;
    //             end
    //         end else if (i_jump) begin
    //             if (halt_flag) begin
    //                 reg_PC <= i_PC_dir_jump;
    //             end else begin
    //                 reg_PC <= i_PC_dir_jump + 1;
    //             end
    //         end else if (i_stall_flag || halt_flag) begin
    //             reg_PC <= reg_PC;
    //         end else begin
    //             reg_PC <= reg_PC + 1;
    //         end
    //     end else begin
    //         reg_PC <= reg_PC;
    //     end
    // end
    always @(posedge i_clk) begin
        if (!i_rst) begin
            reg_PC <= {LEN{1'b0}};
        end else if (i_enable_pipeline && !halt_flag) begin
            reg_PC <= mem_address + 1;
        end else begin
            reg_PC <= mem_address;
        end
    end

    assign mem_address = (i_preload_flag) ? i_preload_address :
                         (i_PCSrc) ? i_PC_branch :
                         (i_jump) ? i_PC_dir_jump :
                         (i_stall_flag) ? reg_PC - 1 :
                         reg_PC;

    assign o_PC = reg_PC;

    // Intruction Memory
    mem_instruction #(
        .RAM_WIDTH          (RAM_WIDTH_PROGRAM),
        .RAM_DEPTH          (RAM_DEPTH_PROGRAM),
        .RAM_PERFORMANCE    (RAM_PERFORMANCE_PROGRAM),
        .INIT_FILE          (INIT_FILE_PROGRAM)
    )
    u_mem_instruction
    (
        .i_addr     (mem_address),
        .i_dina     (i_preload_instruction),
        .i_clk      (i_clk),
        .i_wea      (i_preload_flag),
        .i_ena      (ena),
        .i_rsta     (rsta),
        .i_regcea   (regcea),
        .o_data     (o_instruction),
        .o_halt     (halt_flag)
    );

endmodule
