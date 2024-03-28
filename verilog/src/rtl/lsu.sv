`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2024 08:33:37 AM
// Design Name: 
// Module Name: lsu
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


module lsu # (
    parameter AW  = 32, 
    parameter DW  = 32
) (
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
    
    //reg file
    input [DW-1:0] i_read_reg1_data,
    input [DW-1:0] i_read_reg2_data,
    
    output o_write_en,
    output [DW-1:0] o_write_data,
    output o_holding,
    
    input i_imm_en,
    input [DW-1:0] i_imm,
    
    //exe ctrl
    input i_instr_illegal,
    
    input [`IS_SYS:`IS_LUI] i_instr_type,
    input [`IS_LHU:`IS_LB] i_instr_load,
    input [`IS_SW:`IS_SB] i_instr_store,

    input  clk,
    input  rst_n
);
    wire [DW-1:0] load_write_data;
    
    wire [AW-1:0] load_store_addr;
    wire [DW-1:0] load_data_h;
    wire [DW-1:0] load_data_b;
    wire [DW-1:0] store_data_h;
    wire [DW/8-1:0] store_mask_h;
    wire [DW-1:0] store_data_b;
    wire [DW/8-1:0] store_mask_b;

    assign store_data_h = (load_store_addr[1]) ? ((i_read_reg2_data<<16) & 32'hffff0000) : (i_read_reg2_data & 32'hffff);
    assign store_mask_h = 3<<load_store_addr[1:0];
    assign store_data_b = (load_store_addr[1:0] == 2'b11)? ((i_read_reg2_data<<24) & 32'hff000000) : (
                          (load_store_addr[1:0] == 2'b10) ? ((i_read_reg2_data<<16) & 32'hff0000) : (
                          (load_store_addr[1:0] == 2'b01) ? ((i_read_reg2_data<<8) & 32'hff00) : (i_read_reg2_data & 32'hff)));
    assign store_mask_b = 1<<load_store_addr[1:0];
    
    assign load_store_addr = i_read_reg1_data + i_imm;

    assign load_data_h = load_store_addr[1] ? (i_vrb_rsp_rdata>>16) : (i_vrb_rsp_rdata & 32'hffff);
    assign load_data_b = (load_store_addr[1:0] == 2'b11) ? ((i_vrb_rsp_rdata>>24) & 32'hff):  (
                          (load_store_addr[1:0] == 2'b10) ? ((i_vrb_rsp_rdata>>16) & 32'hff) : (
                          (load_store_addr[1:0] == 2'b01)  ? ((i_vrb_rsp_rdata>>8) & 32'hff) : (i_vrb_rsp_rdata & 32'hff)));
    assign load_write_data = (i_instr_load[`IS_LW]) ? (i_vrb_rsp_rdata) : (
                            (i_instr_load[`IS_LH]) ? ({{16{load_data_h[15]}}, load_data_h[15:0]}) : (
                            (i_instr_load[`IS_LHU]) ? (load_data_h) : (
                            (i_instr_load[`IS_LB]) ? ({{24{load_data_b[7]}}, load_data_b[7:0]}) : (
                            (i_instr_load[`IS_LBU]) ? (load_data_b) : (0)))));
    assign o_write_data = (i_instr_type[`IS_LOAD]) ? load_write_data : 0;
    assign o_write_en = i_instr_type[`IS_LOAD];

    assign o_vrb_cmd_valid = i_instr_type[`IS_LOAD] | i_instr_type[`IS_STORE];
    assign o_vrb_cmd_addr = load_store_addr;
    assign o_vrb_cmd_read = i_instr_type[`IS_LOAD];
    assign o_vrb_cmd_wdata = i_instr_store[`IS_SW] ? (i_read_reg2_data) : (
                                i_instr_store[`IS_SH] ? (store_data_h) : (
                                i_instr_store[`IS_SB] ? (store_data_b) : (0)));
    assign o_vrb_cmd_wmask = i_instr_store[`IS_SW] ? (4'hf) : (
                              i_instr_store[`IS_SH] ? (store_mask_h) : (
                              i_instr_store[`IS_SB] ? (store_mask_b) : (0)));

    assign o_holding = o_vrb_cmd_valid & (!i_vrb_rsp_valid);
endmodule
