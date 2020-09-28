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
    //Latches 
    parameter NB_IF_ID      = 64;
    parameter NB_ID_EX      = 163;
    parameter NB_EX_MEM     = 145;
    parameter NB_MEM_WB     = 72;
        
    //PROGRAM MEMORY
    localparam RAM_WIDTH_PROGRAM       = 32;
    localparam RAM_DEPTH_PROGRAM       = 32; // Cantidad de instrucciones
    localparam RAM_PERFORMANCE_PROGRAM = "LOW_LATENCY";
    localparam INIT_FILE_PROGRAM       = "C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\MIPS_Binarios\\TestMain.bin";
    // localparam INIT_FILE_PROGRAM       = "/home/matiasnavarro/Facultad/2019/Arquitectura_de_Computadoras/Practico/Arquitectura_de_Computadoras_2019/TP4-MIPS-2019/Test/MIPS_Binarios/Test8Prueba.bin";
    //DATA MEMORY
    localparam RAM_WIDTH_DATA          = 32;
    localparam RAM_DEPTH_DATA          = 32; // Cantidad de datos
    localparam RAM_PERFORMANCE_DATA    = "LOW_LATENCY";
    localparam INIT_FILE_DATA          = "";

    // Inputs
    reg                 i_clk;
    reg                 i_rst;
    reg                 i_preload_flag;
    reg [LEN - 1 : 0]   i_preload_address;
    reg [LEN - 1 : 0]   i_preload_instruction;
    reg                 i_step_mode_flag;
    reg                 i_step;      
    // Outputs
    // wire [LEN - 1 : 0]  o_led;
    wire [NB_IF_ID  -1 : 0] o_latch_if_id;      
    wire [NB_ID_EX  -1 : 0] o_latch_id_ex;   
    wire [NB_EX_MEM -1 : 0] o_latch_ex_mem;   
    wire [NB_MEM_WB -1 : 0] o_latch_mem_wb;
    wire                    o_clk_locked_estable;
    
    // Variables de contador de clock
    integer clock_counter;
    integer halt_counter;

    // File descriptors de los archivos a escribir
    integer wr_latch_if_id, 
            wr_latch_id_ex, 
            wr_latch_ex_mem, 
            wr_latch_mem_wb;
     
    reg output_write_flag; 

    // Preload instructions & address aux
    reg [RAM_WIDTH_PROGRAM - 1 : 0] instruction_ram [RAM_DEPTH_PROGRAM - 1 : 0];
    reg [LEN - 1 : 0] preload_address_aux;

    initial begin
        i_rst = 1'b0;
        i_clk = 1'b0;
        output_write_flag = 1'b1;
        i_preload_flag = 1'b0;
        i_preload_address = {LEN{1'b0}};
        i_preload_instruction = {LEN{1'b0}};
        i_step_mode_flag = 1'b0;
        i_step = 1'b0;
        $readmemb(INIT_FILE_PROGRAM, instruction_ram, 0, RAM_DEPTH_PROGRAM-1);
        preload_address_aux = {LEN{1'b0}};

        //Archivos a escribir (Sacar datos del MIPS)
        wr_latch_if_id = $fopen("C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\Output_files\\latch_if_id.txt", "w");
        // wr_latch_if_id = $fopen("/home/matiasnavarro/Facultad/2019/Arquitectura_de_Computadoras/Practico/Arquitectura_de_Computadoras_2019/TP4-MIPS-2019/Test/Output_files/latch_if_id.txt", "w");
            if(wr_latch_if_id==0) $stop;
        wr_latch_id_ex = $fopen("C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\Output_files\\latch_id_ex.txt", "w");
            if(wr_latch_id_ex==0) $stop;
        wr_latch_ex_mem = $fopen("C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\Output_files\\latch_ex_mem.txt", "w");
            if(wr_latch_ex_mem==0) $stop;
        wr_latch_mem_wb = $fopen("C:\\Users\\astar\\git\\Arquitectura_de_Computadoras_2019\\TP4-MIPS-2019\\Test\\Output_files\\latch_mem_wb.txt", "w");
            if(wr_latch_mem_wb==0) $stop;

        repeat(500) begin
            #6 i_step = ~i_step;
            #3 i_step = ~i_step;
        end
    end

    //Cargamos instrucciones una por una
    always @(negedge o_clk) begin
        if (!i_rst) begin
            if (i_preload_instruction == 32'hffffffff) begin
                i_preload_flag <= 1'b0;
                i_rst <= 1'b1;
                // i_step_mode_flag <= 1'b1;
            end else begin
                i_preload_flag <= 1'b1;
                i_preload_address <= preload_address_aux;
                i_preload_instruction <= instruction_ram[preload_address_aux];
                preload_address_aux <= preload_address_aux + 1;
            end
        end
    end

    // Contador de clock de ejecucion
    always @(negedge clock) begin
        if (!i_rst) begin
            clock_counter <= 0;
            halt_counter <= 0;
        end else begin
            if (halt_counter != 4) begin
                clock_counter = clock_counter + 1;
            end else begin
                clock_counter = clock_counter;
            end
            if(o_latch_if_id[31:0] == 32'hffffffff) begin
                halt_counter <= halt_counter + 1;
            end
        end
    end

    assign clock = (i_step_mode_flag && i_rst) ? i_step : o_clk;
    //Para sacar los datos de los latches intermedios 
    always @(negedge clock)
    begin
        if(i_rst && output_write_flag == 1'b1)
        begin              
            $fwrite(wr_latch_if_id,  "%b\n", o_latch_if_id);
            $fwrite(wr_latch_id_ex,  "%b\n", o_latch_id_ex);
            $fwrite(wr_latch_ex_mem, "%b\n", o_latch_ex_mem);
            $fwrite(wr_latch_mem_wb, "%b\n", o_latch_mem_wb);
        end
        if(o_latch_if_id[31:0] == 32'hffffffff) begin
            output_write_flag = 0;
            $fclose(wr_latch_if_id);
            $fclose(wr_latch_id_ex);
            $fclose(wr_latch_ex_mem);
            $fclose(wr_latch_mem_wb);
        end
    end

    always #5 i_clk = ~i_clk;

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
        .INIT_FILE_PROGRAM       (INIT_FILE_DATA          ),
        .RAM_WIDTH_DATA          (RAM_WIDTH_DATA          ),
        .RAM_DEPTH_DATA          (RAM_DEPTH_DATA          ),
        .RAM_PERFORMANCE_DATA    (RAM_PERFORMANCE_DATA    ),
        .INIT_FILE_DATA          (INIT_FILE_DATA          )
    )
    u_top_mips(
    	.i_clk                  (i_clk                  ),
        .i_rst                  (i_rst                  ),
        .i_preload_flag         (i_preload_flag         ),
        .i_preload_address      (i_preload_address      ),
        .i_preload_instruction  (i_preload_instruction  ),
        .i_step_mode_flag       (i_step_mode_flag       ),
        .i_step                 (i_step                 ),
        .o_latch_if_id          (o_latch_if_id          ),
        .o_latch_id_ex          (o_latch_id_ex          ),
        .o_latch_ex_mem         (o_latch_ex_mem         ),
        .o_latch_mem_wb         (o_latch_mem_wb         ),
        .o_clk                  (o_clk                  )
    );

endmodule
