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
        // OUTPUTS
        output wire [LEN - 1 : 0]           o_instruction,
        output wire [LEN - 1 : 0]           o_PC
    );
    
    //Memory
    wire [LEN-1:0]      dina;
    wire                wea;
    wire                ena;
    wire                rsta;
    wire                regcea;
    wire                halt_flag;

    // Program Counter Register
    reg [LEN - 1 : 0]   reg_PC;
    reg [LEN - 1 : 0]   reg_PC_aumentado;

    wire [LEN - 1 : 0] mem_address;
    
    //Salida de Instruccion
    //wire [LEN-1:0]      instruction;
    
    //Control Memoria
    assign dina     = 0;
    assign wea      = 0;
    assign ena      = 1;
    assign rsta     = 0;
    assign regcea   = 1;
    
    //---------------------------------------
    // Program Counter Logic
    //---------------------------------------
    // always @(posedge i_clk) begin
    //     if (!i_rst) begin
    //         reg_PC <= {LEN{1'b0}};
    //     end
    //     else begin
    //         if(!i_jump) begin                   //Segundo MUX PC
    //             if (!i_PCSrc) begin             //Primer MUX PC
    //                 if (i_stall_flag) begin
    //                     reg_PC <= reg_PC;
    //                 end else begin
    //                     reg_PC <= reg_PC + 1;
    //                 end
    //             end else begin
    //                 reg_PC <= i_PC_branch;
    //             end
    //         end else begin
    //             reg_PC <= i_PC_dir_jump;
    //         end
    //     end
    // end

    always @(negedge i_clk) begin
        if (!i_rst) begin
            reg_PC <= {LEN{1'b0}};
            reg_PC_aumentado <= 1;
        end else begin
            reg_PC <= reg_PC_aumentado;
        end
    end

    always @(posedge i_clk) begin
        if (!i_rst) begin
            reg_PC <= {LEN{1'b0}};
            reg_PC_aumentado <= 1;
        end else if (i_PCSrc) begin
            reg_PC_aumentado <= i_PC_branch + 1;
        end else if (i_jump) begin
            reg_PC_aumentado <= i_PC_dir_jump + 1;
        end else if (i_stall_flag || halt_flag) begin
            reg_PC_aumentado <= reg_PC;
        end else begin
            reg_PC_aumentado <= reg_PC + 1;
        end
    end

    assign mem_address = (i_jump) ? i_PC_dir_jump :
                         (i_PCSrc) ? i_PC_branch :
                         (i_stall_flag) ? reg_PC - 1 :
                         reg_PC;

    assign o_PC = reg_PC_aumentado;

    // TODO: CONSULTA 1 - Esta mal escribir PC y leer de la memoria de instrucciones en esa address (el PC) en el mismo posedge?
    //       CONSULTA 2 - Como leer de archivo en disco y escribirlo a una memoria en la simulacion.
        
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
        .i_dina     (dina),
        .i_clk      (i_clk),
        .i_wea      (wea),
        .i_ena      (ena),
        .i_rsta     (rsta),
        .i_regcea   (regcea),
        .o_data     (o_instruction),
        .o_halt     (halt_flag)
    );

endmodule
