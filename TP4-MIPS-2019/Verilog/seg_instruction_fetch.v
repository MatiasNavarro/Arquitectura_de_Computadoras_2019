`timescale 1ns / 1ps

module seg_instruction_fetch
    #( parameter
        NB_INSTRUC      = 32,
        NB_ADDR         = 32,
        NB_DATA         = 16,
        //PROGRAM MEMORY
        RAM_WIDTH_PROGRAM       = 32,
        RAM_DEPTH_PROGRAM       = 2048,
        RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY",
        INIT_FILE_PROGRAM       = "/home/martin/git/Arquitectura_de_Computadoras_2019/TP3-BIP1-2019/Test/init_ram_program.mem"
    )
    (
        // INPUTS
        input wire                          i_clk,
        input wire                          i_rst,
        input wire [NB_ADDR - 1 : 0]        i_PC_branch,
        input wire                          i_PCSrc,
        // OUTPUTS
        output wire [NB_INSTRUC - 1 : 0]    o_instruction,
        output wire [NB_ADDR - 1 : 0]       o_PC
    );

    // Program Counter Register
    reg [NB_ADDR - 1 : 0] reg_PC;

    // Program Counter Logic
    always @(posedge i_clk) begin
        if (!i_rst) begin
            reg_PC <= {NB_ADDR{1'b0}};
        end
        else begin
            if (!i_PCSrc) begin
                reg_PC <= reg_PC + 1;
            end
            else begin
                reg_PC <= i_PC_branch;
            end
        end
    end

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
        .i_addr     (o_PC),
        .i_clk      (i_clk),
        .o_data     (o_instruction)
    );

endmodule
