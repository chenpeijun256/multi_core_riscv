`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 09:41:22 AM
// Design Name: 
// Module Name: cpu
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

module cpu # (
    parameter RAW = 5,
    parameter AW  = 32, 
    parameter DW  = 32
) (
    input i_holding,
    
    //IFU master cmd to vrb
    output o_ifu_vrb_cmd_valid,
    output [AW-1:0] o_ifu_vrb_cmd_addr, 
    output o_ifu_vrb_cmd_read, 
    output [DW-1:0] o_ifu_vrb_cmd_wdata,
    output [DW/8-1:0] o_ifu_vrb_cmd_wmask,
    //IFU master response from vrb
    input i_ifu_vrb_rsp_valid,
    input i_ifu_vrb_rsp_err,
    input [DW-1:0] i_ifu_vrb_rsp_rdata,
    
    //LSU master cmd to vrb
    output o_lsu_vrb_cmd_valid,
    output [AW-1:0] o_lsu_vrb_cmd_addr, 
    output o_lsu_vrb_cmd_read, 
    output [DW-1:0] o_lsu_vrb_cmd_wdata,
    output [DW/8-1:0] o_lsu_vrb_cmd_wmask,
    //LSU master response from vrb
    input i_lsu_vrb_rsp_valid,
    input i_lsu_vrb_rsp_err,
    input [DW-1:0] i_lsu_vrb_rsp_rdata,
    
    input clk, 
    input rst_n 
);
    /////////////////////////////////////////
    wire jump_valid;
    wire [AW-1:0] jump_pc;
    
    wire holding;
    wire ifu_holding;
    wire exeu_holding;
    
    assign holding = (i_holding | ifu_holding | exeu_holding);
    
    //////////////////////////////////////////
    wire gen_pc_valid;
    wire [AW-1: 0] gen_pc;
    
    pcu # (
        .AW(AW), 
        .DW(DW)
    ) u_pc_u (
        .i_jump_valid(jump_valid),
        .i_jump_pc(jump_pc),
        
        .i_holding(holding),
        
        .o_pc_valid(gen_pc_valid),
        .o_pc(gen_pc),
        
        .clk(clk),
        .rst_n(rst_n)
    );

    ////////////////////////////////////////
    //ifu output // dec input
    wire [AW-1:0] ifu_pc;
    wire [DW-1:0] ifu_instr;

    ifu # (
        .AW(AW), 
        .DW(DW)
    ) u_ifu (
        .i_pc_valid(gen_pc_valid),
        .i_pc(gen_pc),
        
        .i_jump_valid(jump_valid),
        .i_holding(holding),
        
        .o_ifu_vrb_cmd_valid(o_ifu_vrb_cmd_valid),
        .o_ifu_vrb_cmd_addr(o_ifu_vrb_cmd_addr), 
        .o_ifu_vrb_cmd_read(o_ifu_vrb_cmd_read), 
        .o_ifu_vrb_cmd_wdata(o_ifu_vrb_cmd_wdata),
        .o_ifu_vrb_cmd_wmask(o_ifu_vrb_cmd_wmask),

        .i_ifu_vrb_rsp_valid(i_ifu_vrb_rsp_valid),
        .i_ifu_vrb_rsp_err(i_ifu_vrb_rsp_err),
        .i_ifu_vrb_rsp_rdata(i_ifu_vrb_rsp_rdata),
        
        .o_holding(ifu_holding),
        .o_pc(ifu_pc),
        .o_instr(ifu_instr),
        
        .clk(clk),
        .rst_n(rst_n)
    );
    
    //dec output // fetch input
    wire [AW-1:0] dec_pc;
    wire dec_instr_illegal;
    
    wire dec_rs_1_en;
    wire [RAW-1:0] dec_rs_1;
    wire dec_rs_2_en;
    wire [RAW-1:0] dec_rs_2;
    wire dec_rd_en;
    wire [RAW-1:0] dec_rd;
    wire dec_imm_en;
    wire [DW-1:0] dec_imm;
    
    wire [`IS_SYS:`IS_LUI] dec_instr_type;
    wire [`IS_SRAI:`IS_ADDI] dec_instr_math_i;
    wire [`IS_AND:`IS_ADD] dec_instr_math;
    wire [`IS_BGEU:`IS_BEQ] dec_instr_jb;
    wire [`IS_LHU:`IS_LB] dec_instr_load;
    wire [`IS_SW:`IS_SB] dec_instr_store;
    wire [`IS_CSR_RCI:`IS_ECALL] dec_instr_sys;
`ifdef CFG_M
    wire [`IS_REMU:`IS_MUL] dec_instr_m;
`endif

    decu # (
        .RAW(RAW), 
        .AW(AW), 
        .DW(DW)
    ) u_decu (
        .i_pc(ifu_pc),
        .i_instr(ifu_instr),
        
        .i_jump_valid(jump_valid),
        .i_holding(holding),
        
        .o_pc(dec_pc),
        .o_instr_illegal(dec_instr_illegal),
        
        .o_rs_1_en(dec_rs_1_en),
        .o_rs_1(dec_rs_1),
        .o_rs_2_en(dec_rs_2_en),
        .o_rs_2(dec_rs_2),
        .o_rd_en(dec_rd_en),
        .o_rd(dec_rd),
        .o_imm_en(dec_imm_en),
        .o_imm(dec_imm),

        .o_instr_type(dec_instr_type),
        .o_instr_math_i(dec_instr_math_i),
        .o_instr_math(dec_instr_math),
        .o_instr_jb(dec_instr_jb),
        .o_instr_load(dec_instr_load),
        .o_instr_store(dec_instr_store),
        .o_instr_sys(dec_instr_sys),
`ifdef CFG_M
        .o_instr_m(dec_instr_m),
`endif
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // FETCH to ALU pipe//////////////////////////////////////////////
    wire [DW-1:0] fetch_rs_1_data;
    wire [DW-1:0] fetch_rs_2_data;
    
//    wire exe_rd_en;
//    wire [RAW-1:0] exe_rd;
//    wire [DW-1:0] exe_rd_data;

    wire wb_rd_en;
    wire [RAW-1:0] wb_rd;
    wire [DW-1:0] wb_rd_data;
    
    //dfu output
    wire [DW-1:0] dfu_rs_1_data;
    wire [DW-1:0] dfu_rs_2_data;
    
    wire [AW-1: 0] dfu_pc;
    wire dfu_instr_illegal;

    wire dfu_rd_en;
    wire [RAW-1:0] dfu_rd;
    wire dfu_imm_en;
    wire [DW-1:0] dfu_imm;
    
    wire [`IS_SYS:`IS_LUI] dfu_instr_type;
    wire [`IS_SRAI:`IS_ADDI] dfu_instr_math_i;
    wire [`IS_AND:`IS_ADD] dfu_instr_math;
    wire [`IS_BGEU:`IS_BEQ] dfu_instr_jb;
    wire [`IS_LHU:`IS_LB] dfu_instr_load;
    wire [`IS_SW:`IS_SB] dfu_instr_store;
    wire [`IS_CSR_RCI:`IS_ECALL] dfu_instr_sys;
`ifdef CFG_M
    wire [`IS_REMU:`IS_MUL] dfu_instr_m;
`endif
    dfu # (
        .RAW(RAW), 
        .AW(AW), 
        .DW(DW)
    ) u_dfu (
        .i_jump_valid(jump_valid),
        .i_holding(holding),
        
        .i_pc(dec_pc),
        .i_instr_illegal(dec_instr_illegal),
    
        .i_rs_1_en(dec_rs_1_en),
        .i_rs_1(dec_rs_1),
        .i_rs_2_en(dec_rs_2_en),
        .i_rs_2(dec_rs_2),
        .i_rd_en(dec_rd_en),
        .i_rd(dec_rd),
        .i_imm_en(dec_imm_en),
        .i_imm(dec_imm),
        
        .i_instr_type(dec_instr_type),
        .i_instr_math_i(dec_instr_math_i),
        .i_instr_math(dec_instr_math),
        .i_instr_jb(dec_instr_jb),
        .i_instr_load(dec_instr_load),
        .i_instr_store(dec_instr_store),
        .i_instr_sys(dec_instr_sys),
`ifdef CFG_M
        .i_instr_m(dec_instr_m),
`endif
        .i_rs_1_data(fetch_rs_1_data),
        .i_rs_2_data(fetch_rs_2_data),
        
//        .i_exe_rd_en(exe_rd_en),
//        .i_exe_rd(exe_rd),
//        .i_exe_rd_data(exe_rd_data),
    
//        .i_wb_rd_en(wb_rd_en),
//        .i_wb_rd(wb_rd),
//        .i_wb_rd_data(wb_rd_data),
        
        .o_pc(dfu_pc),
        .o_instr_illegal(dfu_instr_illegal),
    
        .o_rs_1_data(dfu_rs_1_data),
        .o_rs_2_data(dfu_rs_2_data),
        .o_rd_en(dfu_rd_en),
        .o_rd(dfu_rd),
        .o_imm_en(dfu_imm_en),
        .o_imm(dfu_imm),
        
        .o_instr_type(dfu_instr_type),
        .o_instr_math_i(dfu_instr_math_i),
        .o_instr_math(dfu_instr_math),
        .o_instr_jb(dfu_instr_jb),
        .o_instr_load(dfu_instr_load),
        .o_instr_store(dfu_instr_store),
        .o_instr_sys(dfu_instr_sys),
`ifdef CFG_M
        .o_instr_m(dfu_instr_m),
`endif
        .clk(clk),
        .rst_n(rst_n)
    );

    //EXE Unit//////////////////////////////////////////////////

//    assign exe_rd_en = dfu_rd_en;
//    assign exe_rd = dfu_rd;
    
    exeu # (
        .RAW(RAW), 
        .AW(AW), 
        .DW(DW)
    ) u_exeu (
        .i_jump_valid(jump_valid),
        .i_holding(holding),
        
        .i_instr_illegal(dfu_instr_illegal),
        .i_pc(dfu_pc),
        
        .i_rs_1_data(dfu_rs_1_data),
        .i_rs_2_data(dfu_rs_2_data),
        .i_rd_en(dfu_rd_en),
        .i_rd(dfu_rd),
        .i_imm_en(dfu_imm_en),
        .i_imm(dfu_imm),
        
        .i_instr_type(dfu_instr_type),
        .i_instr_math_i(dfu_instr_math_i),
        .i_instr_math(dfu_instr_math),
        .i_instr_jb(dfu_instr_jb),
        .i_instr_load(dfu_instr_load),
        .i_instr_store(dfu_instr_store),
        .i_instr_sys(dfu_instr_sys),
`ifdef CFG_M
        .i_instr_m(dfu_instr_m),
`endif
//        .o_exe_rd_data(exe_rd_data),
        
        .o_wb_rd_en(wb_rd_en),
        .o_wb_rd(wb_rd),
        .o_wb_rd_data(wb_rd_data),
    
        .o_jump_valid(jump_valid),
        .o_jump_pc(jump_pc),
        .o_holding(exeu_holding),
        
        //LSU master cmd to vrb
        .o_vrb_cmd_valid(o_lsu_vrb_cmd_valid),
        .o_vrb_cmd_addr(o_lsu_vrb_cmd_addr), 
        .o_vrb_cmd_read(o_lsu_vrb_cmd_read), 
        .o_vrb_cmd_wdata(o_lsu_vrb_cmd_wdata),
        .o_vrb_cmd_wmask(o_lsu_vrb_cmd_wmask),
        //LSU master response from vrb
        .i_vrb_rsp_valid(i_lsu_vrb_rsp_valid),
        .i_vrb_rsp_err(i_lsu_vrb_rsp_err),
        .i_vrb_rsp_rdata(i_lsu_vrb_rsp_rdata),
    
        .clk(clk),
        .rst_n(rst_n)
    );
    
    //reg file////////////////////////////////////////////////////
    
    reg_file u_reg_file (
        .i_write_reg(wb_rd),
        .i_write_data(wb_rd_data),
        .i_write_en(wb_rd_en),
        
        .i_read_reg1_en(dec_rs_1_en),
        .i_read_reg1(dec_rs_1),
        .o_read_data1(fetch_rs_1_data),
        
        .i_read_reg2_en(dec_rs_2_en),
        .i_read_reg2(dec_rs_2),
        .o_read_data2(fetch_rs_2_data),
    
        .clk(clk),
        .rst_n(rst_n)
    );
    
endmodule
