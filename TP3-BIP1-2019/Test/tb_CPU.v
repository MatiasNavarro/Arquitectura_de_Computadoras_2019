`timescale 1ns / 1ps

module tb_CPU();
    parameter NB_INSTRUC      = 16;
    parameter NB_OPCODE       = 5;
    parameter NB_OPERAND      = 11;
    parameter NB_ADDR         = 11;
    parameter NB_DATA         = 16;

    // INPUTS
    reg                          i_clk;
    reg                          i_rst;
    reg [NB_INSTRUC - 1 : 0]     i_instruc;
    reg [NB_DATA - 1 : 0]        i_data_memory;
    // OUTPUTS
    wire [NB_ADDR -1 : 0]        o_addr_program_mem;
    wire [NB_ADDR - 1 : 0]       o_addr_data_mem;
    wire [NB_DATA - 1 : 0]       o_data_memory;
    wire                         o_WrRam;
    wire                         o_RdRam;

    reg [NB_DATA - 1 : 0] data_memory_out;
    reg [NB_DATA - 1 : 0] data_memory_in;

    always @(*) begin
        if (o_RdRam) begin
            i_data_memory = data_memory_out;
        end
        if (o_WrRam) begin
            data_memory_in = o_data_memory;
        end
    end

    initial begin
        i_clk = 1'b0;
        i_rst = 1'b0;
        i_instruc = {NB_INSTRUC{1'b0}};
        data_memory_out = {NB_DATA{1'b0}};

        #2
        i_rst = 1'b1; // Desactivo la accion del reset.
        data_memory_out = $random%2048;

        #2 i_instruc = 16'b0000000000011101;
        #2 i_instruc = 16'b0000100000011101;
        #2 i_instruc = 16'b0001000000011101;
        #2 i_instruc = 16'b0001100000011101;
        #2 i_instruc = 16'b0010000000000000;
        #2 i_instruc = 16'b0010100000000000;
        #2 i_instruc = 16'b0011000000000000;
        #2 i_instruc = 16'b0011100000000000;
        #2 i_instruc = 16'b0000000000000000;
        #2 i_instruc = 16'b0000100000000000;
        #2 i_instruc = 16'b0001000000000000;
        #2 i_instruc = 16'b0001100000000000;
        #2 i_instruc = 16'b0010000000000000;
        #2 i_instruc = 16'b0010100000011101;
        #2 i_instruc = 16'b0011000000011101;
        #2 i_instruc = 16'b0011100000011101;
        #2 i_instruc = 16'b0000000000011101;
        
        #2 $finish;
    end

    always #1 i_clk = ~i_clk;

    CPU #(
        .NB_INSTRUC (NB_INSTRUC),
        .NB_OPCODE  (NB_OPCODE),
        .NB_OPERAND (NB_OPERAND),
        .NB_ADDR    (NB_ADDR),
        .NB_DATA    (NB_DATA)
    )
    tb_CPU (
        // INPUTS
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_instruc      (i_instruc),
        .i_data_memory  (i_data_memory),
        // OUTPUTS
        .o_addr_program_mem (o_addr_program_mem),
        .o_addr_data_mem    (o_addr_data_mem),
        .o_data_memory      (o_data_memory),
        .o_WrRam            (o_WrRam),
        .o_RdRam            (o_RdRam)
    );

endmodule
