`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2024 04:38:39 PM
// Design Name: 
// Module Name: exeu
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
`include "config.vh"

module exeu # (
    parameter RAW = 5, 
    parameter AW  = 32, 
    parameter DW  = 32
) (
    input i_jump_valid,
    input i_holding,
    
    input i_instr_illegal,
    input [AW-1:0] i_pc,
    
    input [DW-1:0] i_rs_1_data,
    input [DW-1:0] i_rs_2_data,
    input i_rd_en,
    input [RAW-1:0] i_rd,
    input i_imm_en,
    input [DW-1:0] i_imm,
    
    input [`IS_SYS:`IS_LUI] i_instr_type,
    input [`IS_SRAI:`IS_ADDI] i_instr_math_i,
    input [`IS_AND:`IS_ADD] i_instr_math,
    input [`IS_BGEU:`IS_BEQ] i_instr_jb,
    input [`IS_LHU:`IS_LB] i_instr_load,
    input [`IS_SW:`IS_SB] i_instr_store,
    input [`IS_CSR_RCI:`IS_ECALL] i_instr_sys,
`ifdef CFG_M
    input [`IS_REMU:`IS_MUL] i_instr_m,
`endif
 
//    output [DW-1:0] o_exe_rd_data,
    
    output o_wb_rd_en,
    output [RAW-1:0] o_wb_rd,
    output [DW-1:0] o_wb_rd_data,

    output o_jump_valid,
    output [AW-1:0] o_jump_pc,
    output o_holding,
    
    //LSU master cmd to vrb
    output o_vrb_cmd_valid,
    output [AW-1:0] o_vrb_cmd_addr, 
    output o_vrb_cmd_read, 
    output [DW-1:0] o_vrb_cmd_wdata,
    output [DW/8-1:0] o_vrb_cmd_wmask,
    //LSU master response from vrb
    input i_vrb_rsp_valid,
    input i_vrb_rsp_err,
    input [DW-1:0] i_vrb_rsp_rdata,

    input  clk,
    input  rst_n
);
    wire alu_rd_en;
    wire [DW-1:0] alu_rd_data;
    wire lsu_rd_en;
    wire [DW-1:0] lsu_rd_data;
    
    wire alu_jump_valid;
    wire [AW-1:0] alu_jump_pc;
    
    wire lsu_holding;
    
    alu # (
        .AW(AW), 
        .DW(DW)
    ) u_alu (
        .i_read_reg1_data(i_rs_1_data),
        .i_read_reg2_data(i_rs_2_data),
        
        .i_instr_illegal(i_instr_illegal),
        .i_pc_cur(i_pc),
        
        .i_imm_en(i_imm_en),
        .i_imm(i_imm),

        .i_instr_type(i_instr_type),
        .i_instr_math_i(i_instr_math_i),
        .i_instr_math(i_instr_math),
        .i_instr_jb(i_instr_jb),
        .i_instr_sys(i_instr_sys),
`ifdef CFG_M
        .i_instr_m(i_instr_m),
`endif
        .o_jump_valid(alu_jump_valid),
        .o_jump_pc(alu_jump_pc),
        
        .o_write_en(alu_rd_en),
        .o_write_data(alu_rd_data),
    
        .clk(clk),
        .rst_n(rst_n)
    );
    
    lsu # (
        .AW(AW), 
        .DW(DW)
    ) u_lsu (
        //LSU master cmd to vrb
        .o_vrb_cmd_valid(o_vrb_cmd_valid),
        .o_vrb_cmd_addr(o_vrb_cmd_addr), 
        .o_vrb_cmd_read(o_vrb_cmd_read), 
        .o_vrb_cmd_wdata(o_vrb_cmd_wdata),
        .o_vrb_cmd_wmask(o_vrb_cmd_wmask),
        //LSU master response from vrb
        .i_vrb_rsp_valid(i_vrb_rsp_valid),
        .i_vrb_rsp_err(i_vrb_rsp_err),
        .i_vrb_rsp_rdata(i_vrb_rsp_rdata),
        
        .i_read_reg1_data(i_rs_1_data),
        .i_read_reg2_data(i_rs_2_data),
        
        .o_write_en(lsu_rd_en),
        .o_write_data(lsu_rd_data),
        .o_holding(lsu_holding),
        
        .i_imm_en(i_imm_en),
        .i_imm(i_imm),
        
        .i_instr_illegal(i_instr_illegal),

        .i_instr_type(i_instr_type),
        .i_instr_load(i_instr_load),
        .i_instr_store(i_instr_store),

        .clk(clk),
        .rst_n(rst_n)
    );
    
    assign o_holding = lsu_holding;
    wire [DW-1:0] o_exe_rd_data = alu_rd_en ? alu_rd_data : (
                            lsu_rd_en ? lsu_rd_data : 0);
    
    localparam P_LEN_EXEU = 1+RAW+DW+1+AW;
    wire [P_LEN_EXEU-1: 0] p_exeu_in = {i_rd_en, i_rd, o_exe_rd_data, alu_jump_valid, alu_jump_pc};
    
    wire [P_LEN_EXEU-1: 0] p_exeu_out;
    
    pipe # (
        .DATAW(P_LEN_EXEU),
        .DEPTH(0)
    ) u_exeu_pipe (
        .enable(!i_holding),
        .data_in(p_exeu_in),
        .data_out(p_exeu_out),
        
        .clk(clk),
        .rst((rst_n == 1'b0) | i_jump_valid)
    );
    
    assign {o_wb_rd_en, o_wb_rd, o_wb_rd_data, o_jump_valid, o_jump_pc} = p_exeu_out;
endmodule
