`timescale 1ns / 1ps

module registers
    #(
        parameter NB_DATA               = 32,
        parameter NB_REG                = 32,
        parameter NB_ADDR               = 5
    )
    (
        //Inputs
        input                       i_clk,
        input                       i_rst,
        input                       i_RegWrite,
        input       [NB_ADDR-1:0]   i_read_register_1,
        input       [NB_ADDR-1:0]   i_read_register_2,
        input       [NB_ADDR-1:0]   i_write_register,
        input       [NB_DATA-1:0]   i_write_data,
        //Outputs
        output  reg [NB_DATA-1:0]   o_read_data_1,
        output  reg [NB_DATA-1:0]   o_read_data_2        
    );
    
    reg [NB_DATA-1:0] register [NB_REG-1:0];
    
    generate
        integer ram_index;
        initial
        for (ram_index = 0; ram_index < NB_REG; ram_index = ram_index + 1) 
            register[ram_index] = ram_index;
    endgenerate
    
    always@(negedge i_clk)
    begin
        if(i_rst)
        begin
            if(i_RegWrite)
                register[i_write_register] <= i_write_data;
        end
    end
    
    always@(posedge i_clk)
    begin
        if(~i_rst)
        begin
            o_read_data_1 <= {NB_DATA{1'b0}};
            o_read_data_2 <= {NB_DATA{1'b0}};
        end
        else
        begin
            o_read_data_1 <= register[i_read_register_1];
            o_read_data_2 <= register[i_read_register_2];
        end
    end
    
endmodule
