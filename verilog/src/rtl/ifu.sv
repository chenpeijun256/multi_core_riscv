`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 09:29:17 AM
// Design Name: 
// Module Name: ifu
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


module ifu # (
    parameter AW  = 32, 
    parameter DW  = 32
) (
    input i_pc_valid,
    input [AW-1:0] i_pc,
    
    input i_jump_valid,
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
    
    output o_holding,
    
    output [AW-1:0] o_pc,
    output [DW-1:0] o_instr,
    
    input clk,
    input rst_n
);

    assign o_ifu_vrb_cmd_valid = i_pc_valid;
    assign o_ifu_vrb_cmd_addr = i_pc;
    assign o_ifu_vrb_cmd_read = 1'b1;
    assign o_ifu_vrb_cmd_wdata = '0;
    assign o_ifu_vrb_cmd_wmask = '0;
    
    assign o_holding = i_pc_valid && !i_ifu_vrb_rsp_valid;
    
    ////////////////////////////////
    localparam P_LEN_IFU = DW+AW;
    wire [P_LEN_IFU-1: 0] p_ifu_in = {i_ifu_vrb_rsp_rdata, i_pc};
    
    wire [P_LEN_IFU-1: 0] p_ifu_out;
    
    pipe # (
        .DATAW(P_LEN_IFU),
        .DEPTH(0)
    ) u_ifu_pipe (
        .enable(!i_holding),
        .data_in(p_ifu_in),
        .data_out(p_ifu_out),
        
        .clk(clk),
        .rst(rst_n == 1'b0 | i_jump_valid)
    );
    
    assign {o_instr, o_pc} = p_ifu_out;

endmodule
