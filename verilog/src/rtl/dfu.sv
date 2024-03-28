`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2024 03:45:20 PM
// Design Name: 
// Module Name: dfu
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


module dfu # (
    parameter RAW  = 5, 
    parameter AW  = 32, 
    parameter DW  = 32
) (
    input i_jump_valid,
    input i_holding,
    
    input [AW-1: 0] i_pc,
    input i_instr_illegal,

    input i_rs_1_en,
    input [RAW-1:0] i_rs_1,
    input i_rs_2_en,
    input [RAW-1:0] i_rs_2,
    
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
    input [DW-1:0] i_rs_1_data,
    input [DW-1:0] i_rs_2_data,
    
//    input i_exe_rd_en,
//    input [RAW-1:0] i_exe_rd,
//    input [DW-1:0] i_exe_rd_data,

//    input i_wb_rd_en,
//    input [RAW-1:0] i_wb_rd,
//    input [DW-1:0] i_wb_rd_data,
    
    output [AW-1: 0] o_pc,
    output o_instr_illegal,

    output [DW-1:0] o_rs_1_data,
    output [DW-1:0] o_rs_2_data,
    output o_rd_en,
    output [RAW-1:0] o_rd,
    output o_imm_en,
    output [DW-1:0] o_imm,
    
    output [`IS_SYS:`IS_LUI] o_instr_type,
    output [`IS_SRAI:`IS_ADDI] o_instr_math_i,
    output [`IS_AND:`IS_ADD] o_instr_math,
    output [`IS_BGEU:`IS_BEQ] o_instr_jb,
    output [`IS_LHU:`IS_LB] o_instr_load,
    output [`IS_SW:`IS_SB] o_instr_store,
    output [`IS_CSR_RCI:`IS_ECALL] o_instr_sys,
`ifdef CFG_M
    output [`IS_REMU:`IS_MUL] o_instr_m,
`endif
    input  clk,
    input  rst_n
);
//    wire [DW-1:0] rs_1_data;
//    wire [DW-1:0] rs_2_data;    
    
//    assign rs_1_data = (i_rs_1_en && (i_rs_1 != 0)) ? 
//                    ((i_exe_rd_en && (i_rs_1 == i_exe_rd)) ? i_exe_rd_data : 
//                    ((i_wb_rd_en && (i_rs_1 == i_wb_rd)) ? i_wb_rd_data : i_rs_1_data)) : ('0);

//    assign rs_2_data = (i_rs_2_en && (i_rs_2 != 0)) ? 
//                    ((i_exe_rd_en && (i_rs_2 == i_exe_rd)) ? i_exe_rd_data : 
//                    ((i_wb_rd_en && (i_rs_2 == i_wb_rd)) ? i_wb_rd_data : i_rs_2_data)) : ('0);
                    
    localparam P_LEN_FETCH = 1+AW+DW+DW+1+RAW+1+DW
`ifdef CFG_M
                                +(`IS_REMU-`IS_MUL+1)
`endif
                                +(`IS_SYS-`IS_LUI+1)
                                +(`IS_SRAI-`IS_ADDI+1)
                                +(`IS_AND-`IS_ADD+1)
                                +(`IS_BGEU-`IS_BEQ+1)
                                +(`IS_LHU-`IS_LB+1)
                                +(`IS_SW-`IS_SB+1)
                                +(`IS_CSR_RCI-`IS_ECALL+1);
    wire [P_LEN_FETCH-1: 0] p_dfu_in = {i_instr_illegal, 
                                            i_pc,
                                            i_rs_1_data, 
                                            i_rs_2_data,
                                            i_rd_en, 
                                            i_rd, 
                                            i_imm_en,
                                            i_imm, 
                                            i_instr_type,
`ifdef CFG_M
                                            i_instr_m,
`endif 
                                            i_instr_math_i, 
                                            i_instr_math, 
                                            i_instr_jb,
                                            i_instr_load, 
                                            i_instr_store, 
                                            i_instr_sys};
    wire [P_LEN_FETCH-1: 0] p_dfu_out;
                    
    pipe # (
        .DATAW(P_LEN_FETCH),
        .DEPTH(0)
    ) u_dfu_pipe (
        .enable(!i_holding),
        .data_in(p_dfu_in),
        .data_out(p_dfu_out),
        
        .clk(clk),
        .rst((rst_n==0) | i_jump_valid)
    );

    assign {o_instr_illegal, 
            o_pc,
            o_rs_1_data, 
            o_rs_2_data,
            o_rd_en, 
            o_rd, 
            o_imm_en,
            o_imm, 
            o_instr_type, 
`ifdef CFG_M
            o_instr_m,
`endif 
            o_instr_math_i, 
            o_instr_math, 
            o_instr_jb,
            o_instr_load, 
            o_instr_store, 
            o_instr_sys} = p_dfu_out;
    
endmodule
