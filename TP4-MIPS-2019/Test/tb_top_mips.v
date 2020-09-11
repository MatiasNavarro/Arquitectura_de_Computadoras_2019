`timescale 1ns / 1ps

module tb_top_mips();
    localparam LEN           = 32;
    localparam NB_ADDRESS    = 16;
    localparam NB_OPCODE     = 6;
    localparam NB_OPERAND    = 11;
    localparam NB_ADDR       = 5;
    localparam NB_ALUOP      = 4;
    localparam NB_FUNC       = 6;
    localparam NB_ALUCTL     = 4;
    localparam NB_CTRL_EX    = 6;
    localparam NB_CTRL_M     = 9;
    localparam NB_CTRL_WB    = 2;
    //PROGRAM MEMORY
    localparam RAM_WIDTH_PROGRAM       = 32;
    localparam RAM_DEPTH_PROGRAM       = 32;
    localparam RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY";
    localparam INIT_FILE_PROGRAM       = "C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\MIPS_Binarios\\Test3Prueba.bin";
    //DATA MEMORY
    localparam RAM_WIDTH_DATA          = 32;
    localparam RAM_DEPTH_DATA          = 32; 
    localparam RAM_PERFORMANCE_DATA    = "LOW_LATENCY";
    localparam INIT_FILE_DATA          = "";
    // localparam INIT_FILE_DATA          = "C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\init_top_mem_data.mem";

    // Inputs
    reg                 i_clk;
    reg                 i_rst;
    // Outputs
    // wire [LEN - 1 : 0]  o_led;

    initial begin
        i_clk = 1'b1;
        i_rst = 1'b0;
        
        #4 i_rst = 1'b1;

        
        #40 $finish;
    end

    always #1 i_clk = ~i_clk;

    top_mips 
    #(
        .LEN                     (LEN                     ),
        .NB_ADDRESS              (NB_ADDRESS              ),
        .NB_OPCODE               (NB_OPCODE               ),
        .NB_OPERAND              (NB_OPERAND              ),
        .NB_ADDR                 (NB_ADDR                 ),
        .NB_ALUOP                (NB_ALUOP                ),
        .NB_FUNC                 (NB_FUNC                 ),
        .NB_ALUCTL               (NB_ALUCTL               ),
        .NB_CTRL_EX              (NB_CTRL_EX              ),
        .NB_CTRL_M               (NB_CTRL_M               ),
        .NB_CTRL_WB              (NB_CTRL_WB              ),
        .RAM_WIDTH_PROGRAM       (RAM_WIDTH_PROGRAM       ),
        .RAM_DEPTH_PROGRAM       (RAM_DEPTH_PROGRAM       ),
        .RAM_PERFORMANCE_PROGRAM (RAM_PERFORMANCE_PROGRAM ),
        .INIT_FILE_PROGRAM       (INIT_FILE_PROGRAM       ),
        .RAM_WIDTH_DATA          (RAM_WIDTH_DATA          ),
        .RAM_DEPTH_DATA          (RAM_DEPTH_DATA          ),
        .RAM_PERFORMANCE_DATA    (RAM_PERFORMANCE_DATA    ),
        .INIT_FILE_DATA          (INIT_FILE_DATA          )
    )
    u_top_mips(
    	.i_clk               (i_clk               ),
        .i_rst               (i_rst               )
        // .o_led               (o_led               )
    );
    

endmodule
