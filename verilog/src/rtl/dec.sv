`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 09:32:38 AM
// Design Name: 
// Module Name: dec
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

module dec # (
    parameter RAW  = 5, 
    parameter DW  = 32
) (
    input  [DW-1:0] i_instr_data, //instruction data
    
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
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
    assign opcode = i_instr_data[6:0];
    assign funct3 = i_instr_data[14:12];
    assign funct7 = i_instr_data[31:25];
    
    wire is_lui = (opcode == 7'b0110111);
    wire is_auipc = (opcode == 7'b0010111);
    wire is_jal = (opcode == 7'b1101111);
    wire is_jalr = (opcode == 7'b1100111);
    wire is_jb = (opcode == 7'b1100011);
    wire is_load = (opcode == 7'b0000011);
    wire is_store = (opcode == 7'b0100011);
    wire is_math_i = (opcode == 7'b0010011);
    wire is_math = (opcode == 7'b0110011);
    wire is_fence = (opcode == 7'b0001111);
    wire is_sys = (opcode == 7'b1110011);
    
    wire is_U = (is_lui | is_auipc);
    wire is_J = (is_jal);
    wire is_I = (is_jalr | is_load | is_math_i | is_fence | is_sys);
    wire is_B = (is_jb);
    wire is_S = (is_store);
    wire is_R = (is_math);
    
    assign o_instr_illegal = ~(is_U | is_J | is_I | is_B | is_S | is_R);
    
    assign o_rd_en = (is_U | is_J | is_I | is_R);
    assign o_rd = (o_rd_en) ? (i_instr_data[11:7]) : (0);
    assign o_rs_1_en = (is_B | is_S | is_I | is_R);
    assign o_rs_1 = (o_rs_1_en) ? (i_instr_data[19:15]) : (0);
    assign o_rs_2_en = (is_B | is_S | is_R);
    assign o_rs_2 = (o_rs_2_en) ? (i_instr_data[24:20]) : (0);
    assign o_imm_en = (is_U | is_J | is_I | is_B | is_S);
    assign o_imm = (is_U) ? ({i_instr_data[31:12], 12'b0}) : (
                   (is_J) ? ({{12{i_instr_data[31]}}, i_instr_data[19:12], i_instr_data[20], i_instr_data[30:21], 1'b0}) : (
                   (is_I) ? ({{20{i_instr_data[31]}}, i_instr_data[31:20]}) : (
                   (is_B) ? ( {{20{i_instr_data[31]}}, i_instr_data[7], i_instr_data[30:25], i_instr_data[11:8], 1'b0}) : (
                   (is_S) ? ({{20{i_instr_data[31]}}, i_instr_data[31:25], i_instr_data[11:7]}) : (32'h0)))));

    assign o_instr_type[`IS_LUI] = is_lui;
    assign o_instr_type[`IS_AUIPC] = is_auipc;
    assign o_instr_type[`IS_JAL] = is_jal;
    assign o_instr_type[`IS_JALR] = is_jalr;
    assign o_instr_type[`IS_JB] = is_jb;
    assign o_instr_type[`IS_LOAD] = is_load;
    assign o_instr_type[`IS_STORE] = is_store;
    assign o_instr_type[`IS_MATH_I] = is_math_i;
    assign o_instr_type[`IS_MATH] = is_math;
    assign o_instr_type[`IS_FENCE] = is_fence;
    
    assign o_instr_math_i[`IS_ADDI] = is_math_i & (funct3 == 3'b000);
    assign o_instr_math_i[`IS_SLTI] = is_math_i & (funct3 == 3'b010);
    assign o_instr_math_i[`IS_SLTIU] = is_math_i & (funct3 == 3'b011);
    assign o_instr_math_i[`IS_XORI] = is_math_i & (funct3 == 3'b100);
    assign o_instr_math_i[`IS_ORI] = is_math_i & (funct3 == 3'b110);
    assign o_instr_math_i[`IS_ANDI] = is_math_i & (funct3 == 3'b111);
    assign o_instr_math_i[`IS_SLLI] = is_math_i & (funct3 == 3'b001);
    wire is_srli_srai = is_math_i & (funct3 == 3'b101);
    assign o_instr_math_i[`IS_SRLI] = is_srli_srai & (i_instr_data[31:30] == 2'b00);
    assign o_instr_math_i[`IS_SRAI] = is_srli_srai & (i_instr_data[31:30] == 2'b01);
    
    wire is_add_sub = is_math & (funct3 == 3'b000);
    assign o_instr_math[`IS_ADD] = is_add_sub & (funct7[6:0] == 7'b0000000);
    assign o_instr_math[`IS_SUB] = is_add_sub & (funct7[6:0] == 7'b0100000);
    assign o_instr_math[`IS_SLL] = is_math & (funct3 == 3'b001) & (funct7[6:0] == 7'b0000000);
    assign o_instr_math[`IS_SLT] = is_math & (funct3 == 3'b010) & (funct7[6:0] == 7'b0000000);
    assign o_instr_math[`IS_SLTU] = is_math & (funct3 == 3'b011) & (funct7[6:0] == 7'b0000000);
    assign o_instr_math[`IS_XOR] = is_math & (funct3 == 3'b100) & (funct7[6:0] == 7'b0000000);
    wire is_srl_sra = is_math & (funct3 == 3'b101);
    assign o_instr_math[`IS_SRL] = is_srl_sra & (funct7[6:0] == 7'b0000000);
    assign o_instr_math[`IS_SRA] = is_srl_sra & (funct7[6:0] == 7'b0100000);
    assign o_instr_math[`IS_OR] = is_math & (funct3 == 3'b110) & (funct7[6:0] == 7'b0000000);
    assign o_instr_math[`IS_AND] = is_math & (funct3 == 3'b111) & (funct7[6:0] == 7'b0000000);
    
`ifdef CFG_M
    assign o_instr_m[`IS_MUL] = is_math & (funct3 == 3'b000) & (funct7[6:0] == 7'b0000001);
    assign o_instr_m[`IS_MULH] = is_math & (funct3 == 3'b001) & (funct7[6:0] == 7'b0000001);
    assign o_instr_m[`IS_MULHSU] = is_math & (funct3 == 3'b010) & (funct7[6:0] == 7'b0000001);
    assign o_instr_m[`IS_MULHU] = is_math & (funct3 == 3'b011) & (funct7[6:0] == 7'b0000001);
    assign o_instr_m[`IS_DIV] = 1'b0;
    assign o_instr_m[`IS_DIVU] = 1'b0;
    assign o_instr_m[`IS_REM] = 1'b0;
    assign o_instr_m[`IS_REMU] = 1'b0;
`endif
    
    assign o_instr_jb[`IS_BEQ] = is_jb & (funct3 == 3'b000);
    assign o_instr_jb[`IS_BNE] = is_jb & (funct3 == 3'b001);
    assign o_instr_jb[`IS_BLT] = is_jb & (funct3 == 3'b100);
    assign o_instr_jb[`IS_BGE] = is_jb & (funct3 == 3'b101);
    assign o_instr_jb[`IS_BLTU] = is_jb & (funct3 == 3'b110);
    assign o_instr_jb[`IS_BGEU] = is_jb & (funct3 == 3'b111);
    
    assign o_instr_load[`IS_LB] = is_load & (funct3 == 3'b000);
    assign o_instr_load[`IS_LH] = is_load & (funct3 == 3'b001);
    assign o_instr_load[`IS_LW] = is_load & (funct3 == 3'b010);
    assign o_instr_load[`IS_LBU] = is_load & (funct3 == 3'b100);
    assign o_instr_load[`IS_LHU] = is_load & (funct3 == 3'b101);
    
    assign o_instr_store[`IS_SB] = is_store & (funct3 == 3'b000);
    assign o_instr_store[`IS_SH] = is_store & (funct3 == 3'b001);
    assign o_instr_store[`IS_SW] = is_store & (funct3 == 3'b010);

    assign o_instr_sys[`IS_CSR_RW] = is_sys & (funct3 == 3'b001);
    assign o_instr_sys[`IS_CSR_RS] = is_sys & (funct3 == 3'b010);
    assign o_instr_sys[`IS_CSR_RC] = is_sys & (funct3 == 3'b011);
    assign o_instr_sys[`IS_CSR_RWI] = is_sys & (funct3 == 3'b101);
    assign o_instr_sys[`IS_CSR_RSI] = is_sys & (funct3 == 3'b110);
    assign o_instr_sys[`IS_CSR_RCI] = is_sys & (funct3 == 3'b111);
    assign o_instr_type[`IS_CSR] = o_instr_sys[`IS_CSR_RW] | o_instr_sys[`IS_CSR_RS] |
                                    o_instr_sys[`IS_CSR_RC] | o_instr_sys[`IS_CSR_RWI] |
                                    o_instr_sys[`IS_CSR_RSI] | o_instr_sys[`IS_CSR_RCI];
    
    wire is_e = is_sys & (funct3 == 3'b000);
    assign o_instr_sys[`IS_ECALL] = is_e & (i_instr_data[31:20] ==12'h0);
    assign o_instr_sys[`IS_EBREAK] = is_e & (i_instr_data[31:20] ==12'h1);
    assign o_instr_sys[`IS_MRET] = is_e & (i_instr_data[31:20] ==12'h302);
    assign o_instr_type[`IS_SYS] = o_instr_sys[`IS_ECALL] | o_instr_sys[`IS_EBREAK] |
                                    o_instr_sys[`IS_MRET];
endmodule
