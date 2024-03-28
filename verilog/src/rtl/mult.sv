`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 09:04:36 AM
// Design Name: 
// Module Name: mult
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


module mult # (
    parameter DW  = 32
) (
    input [`IS_REMU:`IS_MUL] i_instr_m,
    
    input [DW-1:0] i_rs_1_data,
    input [DW-1:0] i_rs_2_data,
    
    output o_rd_en,
    output [DW-1:0] o_rd_data,

    input  clk,
    input  rst_n
);
    wire a_s;
    wire [DW-1:0] a_p;
    wire [DW-1:0] a;
    wire b_s;
    wire [DW-1:0] b_p;
    wire [DW-1:0] b;
    
    wire r_en;
    wire r_s;
    wire [DW*2-1:0] r_o;
    wire [DW*2-2:0] r_p;
    wire [DW*2-1:0] r;
    
    assign a_s = (i_instr_m[`IS_MUL] | i_instr_m[`IS_MULHU]) ? 1'b0 : i_rs_1_data[DW-1];
    assign a_p = {1'b0, ~i_rs_1_data[DW-2: 0]} + 1'b1;
    assign a = a_s ? a_p : i_rs_1_data;
    
    assign b_s = (i_instr_m[`IS_MULH]) ? i_rs_2_data[DW-1] : 1'b0;
    assign b_p = {1'b0, ~i_rs_2_data[DW-2: 0]} + 1'b1;
    assign b = b_s ? b_p : i_rs_2_data;
    
    assign r_en = (i_instr_m[`IS_MUL] | i_instr_m[`IS_MULHU] | i_instr_m[`IS_MULH] | i_instr_m[`IS_MULHSU]);
    assign r_s = (a_s ^ b_s) & (a != 0) & (b != 0);
    
    assign r_o = r_en ? (a * b) : 0;
    assign r_p = {1'b0, ~r_o[DW*2-2:0]} + 1'b1;
    assign r = ((i_instr_m[`IS_MULH] | i_instr_m[`IS_MULHSU]) & r_s) ? {r_s, r_p} : r_o;
    
    assign o_rd_en = r_en;
    assign o_rd_data = i_instr_m[`IS_MUL] ? r[DW-1:0] : r[DW*2-1:DW];
endmodule
