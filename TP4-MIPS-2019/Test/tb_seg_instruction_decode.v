`timescale 1ns / 1ps

//Todo puerto de salida del modulo es un cable.
//Todo puerto de estimulo o generacion de entrada es un registro.
module tb_seg_instruction_decode();
    localparam LEN           = 32;
    localparam NB_REG        = 32;
    localparam NB_ADDRESS    = 16;
    localparam NB_OPCODE     = 6;
    localparam NB_ADDR       = 5;
    localparam NB_CTRL_EX    = 6;
    localparam NB_CTRL_M     = 9;
    localparam NB_CTRL_WB    = 2;

    //Entradas 
    reg                     i_clk;
    reg                     i_rst;
    reg [LEN-1:0]           i_PC;
    reg [LEN-1:0]           i_instruction;
    reg [NB_ADDR-1:0]       i_write_reg;
    reg [LEN-1:0]           i_write_data;
    reg                     i_RegWrite;
    reg                     i_flush;
    reg [NB_ADDR-1:0]       i_rt_ex;       
//    reg                     i_PCSrc;
//    reg                     i_stall_flag;
    
    //Salidas
    wire [NB_ADDR-1:0]      o_rs;           //instruction[25:21]
    wire [NB_ADDR-1:0]      o_rt;           //instruction[20:16]
    wire [NB_ADDR-1:0]      o_rd;           //instruction[15:11]    
    wire [LEN-1:0]          o_PC;
    wire [LEN-1:0]          o_addr_ext;
    wire [LEN-1:0]          o_read_data_1;
    wire [LEN-1:0]          o_read_data_2;
    wire [LEN-1:0]          o_PC_dir_jump;
    wire                    o_jump_flag;
    wire                    o_stall_flag;
//    wire                    o_flush_if;     
//    wire                    o_flush_ex; 
    
    //Control outputs 
    wire [NB_CTRL_WB-1:0]   o_ctrl_wb_bus;
    wire [NB_CTRL_M-1:0]    o_ctrl_mem_bus;
    wire [NB_CTRL_EX-1:0]   o_ctrl_exc_bus;

    initial begin
        i_clk = 1'b0;
        i_rst = 1'b0;
        i_write_data    = 32'h0000abcd;
        i_PC[31:26]     = 6'b111100; i_PC[25:0] = $random; 
        i_instruction   = 32'b00000000;
        i_write_reg     = 5'b00010;
        i_rt_ex         = 5'b00001;
        i_RegWrite      = 1'b0;
        i_flush         = 1'b1;

        #5 i_rst    = 1'b1;
           i_flush  = 1'b0;
        
        //R-TYPE ---------------------------------------------
        #5  i_instruction [31:26]   = 6'b000000;        //R-Type
            i_instruction [25:6 ]   = $random;
            i_instruction [5 :0 ]   = 6'b100001;        //ADDU 
            i_RegWrite              = 1'b1;        
        
        #5  i_instruction [5 :0 ]   = 6'b100100;        //AND 
        #5  i_instruction [5 :0 ]   = 6'b100101;        //OR
  
        #5  i_instruction [5 :0 ]   = 6'b001000;        //JR
        #5  i_instruction [5 :0 ]   = 6'b001001;        //JALR

       //LOAD TYPE ------------------------------------------
       
       #5  i_instruction [31:26]   = 6'b100000;        //LB
           i_instruction [25:21]   = 5'b01011;
           i_instruction [20:16]   = 5'b00001;
           i_instruction [15:0 ]   = $random;
           i_RegWrite              = 1'b1;
           

       #5  i_instruction [31:26]   = 6'b100001;        //LH
           i_RegWrite              = 1'b1;
        
       #5  i_instruction [31:26]   = 6'b100011;        //LW
           i_instruction [25:0 ]   = $random;
           i_RegWrite              = 1'b1;

       #5  i_instruction [31:26]   = 6'b100111;        //LWU
           i_instruction [25:0 ]   = $random;
           i_RegWrite              = 1'b1;
        
       #5  i_instruction [31:26]   = 6'b100100;        //LBU
           i_instruction [25:0 ]   = $random;
           i_RegWrite              = 1'b1;
        
       #5  i_instruction [31:26]   = 6'b100101;        //LHU
           i_instruction [25:0 ]   = $random;
           i_RegWrite              = 1'b1;

        //STORE TYPE -----------------------------------------
        #5  i_instruction [31:26]   = 6'b101000;        //SB
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b0;

        #5  i_instruction [31:26]   = 6'b101001;        //SH
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b0;

        #5  i_instruction [31:26]   = 6'b101011;        //SW
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b0;

        //INMEDIATE -------------------------------------------
        #5  i_instruction [31:26]   = 6'b001000;        //ADDI
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b1;

        //BRANCH - JUMP ---------------------------------------
        #5  i_instruction [31:26]   = 6'b000100;        //BEQ
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b0;

        #5  i_instruction [31:26]   = 6'b000101;        //BNQ
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b0;

        #5  i_instruction [31:26]   = 6'b000010;        //JUMP
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b0;

        #5  i_instruction [31:26]   = 6'b000011;        //JAL
            i_instruction [25:0 ]   = $random;
            i_RegWrite              = 1'b0;


        #5  i_instruction           = 32'h01094020;     //R-Type
                    
        #5 $finish;
    end

    always #2.5 i_clk = ~i_clk;

    seg_instruction_decode 
    #(
        .LEN        (LEN        ),
        .NB_REG     (NB_REG     ),
        .NB_ADDRESS (NB_ADDRESS ),
        .NB_OPCODE  (NB_OPCODE  ),
        .NB_ADDR    (NB_ADDR    ),
        .NB_CTRL_EX (NB_CTRL_EX ),
        .NB_CTRL_M  (NB_CTRL_M  ),
        .NB_CTRL_WB (NB_CTRL_WB )
    )
    u_seg_instruction_decode(
    	.i_clk          (i_clk          ),
        .i_rst          (i_rst          ),
        .i_PC           (i_PC           ),
        .i_instruction  (i_instruction  ),
        .i_write_reg    (i_write_reg    ),
        .i_write_data   (i_write_data   ),
        .i_RegWrite     (i_RegWrite     ),
        .i_flush        (i_flush        ),
        .i_rt_ex        (i_rt_ex        ),
//        .i_PCSrc        (i_PCSrc        ),
//        .i_stall_flag   (i_stall_flag   ),
        .o_rs           (o_rs           ),
        .o_rt           (o_rt           ),
        .o_rd           (o_rd           ),
        .o_PC           (o_PC           ),
        .o_addr_ext     (o_addr_ext     ),
        .o_read_data_1  (o_read_data_1  ),
        .o_read_data_2  (o_read_data_2  ),
        .o_PC_dir_jump  (o_PC_dir_jump  ),
        .o_jump_flag    (o_jump_flag    ),
        .o_stall_flag   (o_stall_flag   ),
//        .o_flush_if     (o_flush_if     ),
//        .o_flush_ex     (o_flush_ex     ),
        .o_ctrl_wb_bus  (o_ctrl_wb_bus  ),
        .o_ctrl_mem_bus (o_ctrl_mem_bus ),
        .o_ctrl_exc_bus (o_ctrl_exc_bus )
    );

endmodule