`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2024 02:10:51 PM
// Design Name: 
// Module Name: pc_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pcu # (
    parameter AW  = 32, 
    parameter DW  = 32
) (
    input i_jump_valid,
    input [AW-1:0] i_jump_pc,
    
    input i_holding,
    
    output o_pc_valid,
    output [AW-1:0] o_pc,
    
    input clk,
    input rst_n
);
    localparam RESET_PC = 32'h0;
    localparam RESET_CNT_W = 3;
    
    reg [AW-1:0] pc_cur;
    
    ////
    reg [RESET_CNT_W-1: 0] rst_cnt;
    reg rst_done;
    
    always @(posedge clk) begin 
        if (rst_n == 1'b0) begin
            rst_cnt <= #1 '0;
        end
        else begin
            if(!rst_done)
                rst_cnt <= #1 rst_cnt + 1;
            else
                ;
        end
    end
    
    always @(posedge clk) begin 
        if (rst_n == 1'b0) begin
            rst_done <= #1 '0;
        end
        else begin
            if(rst_cnt == {RESET_CNT_W{1'b1}})
                rst_done <= #1 1'b1;
            else
                ;
        end
    end

    always @(posedge clk) begin 
        if (!rst_done) 
            pc_cur <= #1 (RESET_PC);
        else if (i_jump_valid)
            pc_cur <= #1 i_jump_pc;
        else if (i_holding)
            pc_cur <= #1 pc_cur;
        else
            pc_cur <= #1 pc_cur + (DW/8);
    end
    
    assign o_pc = pc_cur;
    assign o_pc_valid = rst_done;
    
endmodule
