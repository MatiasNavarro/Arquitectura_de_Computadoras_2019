`timescale 1ns / 1ps

module tb_seg_write_back();
    parameter   LEN          = 32;
    parameter   NB_ADDR      = 5;
    parameter   NB_CTRL_WB   = 2;
    
    // INPUTS
    reg [LEN-1 : 0]      i_read_data;
    reg [LEN-1 : 0]      i_ALU_result;
    reg [NB_ADDR-1:0]    i_write_register;
    //Control Inputs
    reg [NB_CTRL_WB-1:0] i_ctrl_wb_bus;       //[RegWrite, MemtoReg]
    
    // OUTPUTS
    wire                 o_RegWrite;
    wire [LEN -1 : 0]    o_write_data;
    wire [NB_ADDR-1:0]   o_write_register;
    
    initial begin
        i_read_data = 0;
        i_ALU_result = 0;
        i_ctrl_wb_bus = 0;
        i_write_register = 0;
        
        #10
        i_read_data = 5'b00011;
        i_ALU_result = 5'b11100;
        i_ctrl_wb_bus = 2'b01;
        
        #10
        i_ctrl_wb_bus = 2'b00;
        
        #10 $finish;   
    end
    
    //Modulo para pasarle los estimulos del banco de pruebas.
    seg_write_back 
    #(
        .LEN        (LEN        ),
        .NB_ADDR    (NB_ADDR    ),
        .NB_CTRL_WB (NB_CTRL_WB )
    )
    u_seg_write_back(
    	.i_read_data      (i_read_data      ),
        .i_ALU_result     (i_ALU_result     ),
        .i_write_register (i_write_register ),
        .i_ctrl_wb_bus    (i_ctrl_wb_bus    ),
        .o_RegWrite       (o_RegWrite       ),
        .o_write_data     (o_write_data     ),
        .o_write_register (o_write_register )
    );
    
endmodule
