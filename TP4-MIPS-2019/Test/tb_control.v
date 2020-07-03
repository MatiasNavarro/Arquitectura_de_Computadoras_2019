`timescale 1ns / 1ps

module tb_control();
   // Cantidad de bits del opcode. (6 bits MSB de la instruccion)   
   // Cantidad de bits del output al ALU OP (Control de ALU)
    localparam NB_OPCODE     = 6;
    localparam NB_CTRL_EX    = 3;
    localparam NB_CTRL_M     = 3;
    localparam NB_CTRL_WB    = 2;

    // Inputs
    reg                 i_rst;
    reg [NB_OPCODE-1:0] i_opcode;
    // Outputs
    wire [NB_CTRL_WB-1:0]   o_ctrl_wb_bus;   // [ RegWrite, MemtoReg]
    wire [NB_CTRL_M-1:0]    o_ctrl_mem_bus;  // [ SB, SH, LB, LH, Unsigned, Branch, MemRead, MemWrite ]
    wire [NB_CTRL_EX-1:0]   o_ctrl_exc_bus;  // [ Jump&Link, JALOnly, RegDst, ALUSrc[1:0] , jump, jump_register, ALUCode [3:0] ]

    initial begin
        i_rst   = 1'b0;
        i_opcode = {NB_OPCODE-1{1'b0}};
        #5
        i_rst = 1'b1; // Desactivo el reset
        //R-Format
        #5 i_opcode = 6'b000000;
        //LW
        #10 i_opcode = 6'b100011;
        #10
        i_rst   = 1'b0;
        #5
        i_rst = 1'b1;
        //SW
        #5 i_opcode = 6'b101011;
        //BEQ
        #10 i_opcode = 6'b000100;
        #10 $finish;
    end
    
    //Modulo para pasarle los estimulos del banco de pruebas.
    control 
    #(
        .NB_OPCODE  (NB_OPCODE  ),
        .NB_CTRL_EX (NB_CTRL_EX ),
        .NB_CTRL_M  (NB_CTRL_M  ),
        .NB_CTRL_WB (NB_CTRL_WB )
    )
    u_control(
        .i_rst          (i_rst          ),
        .i_opcode       (i_opcode       ),
        .o_ctrl_wb_bus  (o_ctrl_wb_bus  ),
        .o_ctrl_mem_bus (o_ctrl_mem_bus ),
        .o_ctrl_exc_bus (o_ctrl_exc_bus )
    );
    
endmodule
