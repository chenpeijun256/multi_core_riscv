`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 09:35:57 AM
// Design Name: 
// Module Name: alu
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

module alu # (
    parameter AW  = 32, 
    parameter DW  = 32
) (
    //reg file
    input [DW-1:0] i_read_reg1_data,
    input [DW-1:0] i_read_reg2_data,
    
    output o_write_en,
    output [DW-1:0] o_write_data,
    
    //exe ctrl
    input i_instr_illegal,
    input [AW-1:0] i_pc_cur,
    
    input i_imm_en,
    input [DW-1:0] i_imm,
    
    input [`IS_SYS:`IS_LUI] i_instr_type,
    input [`IS_SRAI:`IS_ADDI] i_instr_math_i,
    input [`IS_AND:`IS_ADD] i_instr_math,
    input [`IS_BGEU:`IS_BEQ] i_instr_jb,
    input [`IS_CSR_RCI:`IS_ECALL] i_instr_sys,
`ifdef CFG_M
    input [`IS_REMU:`IS_MUL] i_instr_m,
`endif

    output o_jump_valid,
    output [AW-1:0] o_jump_pc,

    input  clk,
    input  rst_n
);
    wire [DW-1:0] math_i_write_data;
    wire [DW-1:0] math_write_data;
    wire [DW-1:0] math_data;
    
    wire [DW-1:0] srai_t;
    wire [DW-1:0] sra_t;
    
`ifdef CFG_M
    wire m_rd_en;
    wire [DW-1:0] m_rd_data;
    
    mult # (
        .DW(DW)
    ) u_mult (
        .i_instr_m(i_instr_m),
        
        .i_rs_1_data(i_read_reg1_data),
        .i_rs_2_data(i_read_reg2_data),
        
        .o_rd_en(m_rd_en),
        .o_rd_data(m_rd_data),
    
        .clk(clk),
        .rst_n(rst_n)
    );
`endif

    assign srai_t = ($signed(i_read_reg1_data) >>> i_imm[4:0]);
    assign sra_t = ($signed(i_read_reg1_data) >>> i_read_reg2_data[4:0]);

    assign math_i_write_data = (i_instr_math_i[`IS_ADDI]) ? (i_read_reg1_data + i_imm) :(
                                  (i_instr_math_i[`IS_SLTI]) ? (($signed(i_read_reg1_data) < $signed(i_imm)) ? 32'h1 : 32'h0) : (
                                  (i_instr_math_i[`IS_SLTIU]) ? ((i_read_reg1_data < i_imm) ? 32'h1 : 32'h0) : (
                                  (i_instr_math_i[`IS_XORI]) ? (i_read_reg1_data ^ i_imm) : (
                                  (i_instr_math_i[`IS_ORI]) ? (i_read_reg1_data | i_imm) : (
                                  (i_instr_math_i[`IS_ANDI]) ? (i_read_reg1_data & i_imm) : (
                                  (i_instr_math_i[`IS_SLLI]) ? (i_read_reg1_data << i_imm[4:0]) : (
                                  (i_instr_math_i[`IS_SRLI]) ? (i_read_reg1_data >> i_imm[4:0]) : (
                                  (i_instr_math_i[`IS_SRAI]) ? (srai_t) : (0)))))))));
    assign math_data = (i_instr_math[`IS_ADD]) ? (i_read_reg1_data + i_read_reg2_data) :(
                              (i_instr_math[`IS_SUB]) ? (i_read_reg1_data - i_read_reg2_data) : (
                              (i_instr_math[`IS_SLT]) ? (($signed(i_read_reg1_data) < $signed(i_read_reg2_data)) ? 32'h1 : 32'h0) : (
                              (i_instr_math[`IS_SLTU]) ? ((i_read_reg1_data < i_read_reg2_data) ? 32'h1 : 32'h0) : (
                              (i_instr_math[`IS_XOR]) ? (i_read_reg1_data ^ i_read_reg2_data) : (
                              (i_instr_math[`IS_OR]) ? (i_read_reg1_data | i_read_reg2_data) : (
                              (i_instr_math[`IS_AND]) ? (i_read_reg1_data & i_read_reg2_data) : (
                              (i_instr_math[`IS_SLL]) ? (i_read_reg1_data << i_read_reg2_data[4:0]) : (
                              (i_instr_math[`IS_SRL]) ? (i_read_reg1_data >> i_read_reg2_data[4:0]) : (
                              (i_instr_math[`IS_SRA]) ? (sra_t) : (0))))))))));

    assign math_write_data = 
`ifdef CFG_M
                                m_rd_en ? m_rd_data :
`endif
                                math_data;

    wire is_jb_valid = (i_instr_jb[`IS_BEQ]) ? (i_read_reg1_data == i_read_reg2_data) : (
                            (i_instr_jb[`IS_BNE]) ? (i_read_reg1_data != i_read_reg2_data) : (
                            (i_instr_jb[`IS_BLT]) ? ($signed(i_read_reg1_data) < $signed(i_read_reg2_data)) : (
                            (i_instr_jb[`IS_BGE]) ? ($signed(i_read_reg1_data) >= $signed(i_read_reg2_data)) : (
                            (i_instr_jb[`IS_BLTU]) ? (i_read_reg1_data < i_read_reg2_data) : (
                            (i_instr_jb[`IS_BGEU]) ? (i_read_reg1_data >= i_read_reg2_data) : (0))))));
    assign o_jump_valid = (i_instr_type[`IS_JALR] | i_instr_type[`IS_JAL]) ? (1'b1) : (
                            (i_instr_type[`IS_JB]) ? (is_jb_valid) : (0));
    assign o_jump_pc = (i_instr_type[`IS_JAL] | i_instr_type[`IS_JB]) ? (i_imm + i_pc_cur) : (
                        (i_instr_type[`IS_JALR]) ? (i_imm + i_read_reg1_data) : (0));

    assign o_write_data = (i_instr_type[`IS_MATH_I]) ? (math_i_write_data) : (
                            (i_instr_type[`IS_MATH]) ? (math_write_data) : (
                            (i_instr_type[`IS_LUI]) ? (i_imm) : (
                            (i_instr_type[`IS_AUIPC]) ? (i_imm + i_pc_cur) : (
                            (i_instr_type[`IS_JALR] | i_instr_type[`IS_JAL]) ? (3'h4 + i_pc_cur) : (0)))));
    assign o_write_en = i_instr_type[`IS_MATH_I] | i_instr_type[`IS_MATH] |
                        i_instr_type[`IS_LUI] | i_instr_type[`IS_AUIPC] |
                        i_instr_type[`IS_JALR] | i_instr_type[`IS_JAL];

endmodule
