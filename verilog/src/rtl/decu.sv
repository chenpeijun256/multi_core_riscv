`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2024 03:30:57 PM
// Design Name: 
// Module Name: decu
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


module decu # (
    parameter RAW  = 5, 
    parameter AW  = 32, 
    parameter DW  = 32
) (
    input [AW-1: 0] i_pc,
    input [DW-1: 0] i_instr, //instruction data
    
    input i_jump_valid,
    input i_holding,
    
    output [AW-1: 0] o_pc,
    output o_instr_illegal,

    output o_rs_1_en,
    output [RAW-1:0] o_rs_1,
    output o_rs_2_en,
    output [RAW-1:0] o_rs_2,
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

    dec # (
        .RAW(RAW), 
        .DW(DW)
    ) u_dec (
        .i_instr_data(i_instr),
        
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
    
    localparam P_LEN_DEC = 1+AW+1+RAW+1+RAW+1+RAW+1+DW
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
    wire [P_LEN_DEC-1: 0] p_dec_in = {dec_instr_illegal, 
                                        i_pc, dec_rs_1_en, 
                                        dec_rs_1, 
                                        dec_rs_2_en, 
                                        dec_rs_2,
                                        dec_rd_en, 
                                        dec_rd, 
                                        dec_imm_en,
                                        dec_imm, 
                                        dec_instr_type, 
`ifdef CFG_M
                                        dec_instr_m,
`endif                                        
                                        dec_instr_math_i, 
                                        dec_instr_math, 
                                        dec_instr_jb,
                                        dec_instr_load, 
                                        dec_instr_store, 
                                        dec_instr_sys};
    
    wire [P_LEN_DEC-1: 0] p_dec_out;
    
    pipe # (
        .DATAW(P_LEN_DEC),
        .DEPTH(0)
    ) u_decu_pipe (
        .enable(!i_holding),
        .data_in(p_dec_in),
        .data_out(p_dec_out),
        
        .clk(clk),
        .rst((rst_n == 1'b0) | i_jump_valid)
    );
    
    assign {o_instr_illegal, 
            o_pc, o_rs_1_en,
            o_rs_1, 
            o_rs_2_en, 
            o_rs_2,
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
            o_instr_sys} = p_dec_out;
endmodule
