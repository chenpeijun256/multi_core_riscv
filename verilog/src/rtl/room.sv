`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2024 08:52:22 AM
// Design Name: 
// Module Name: room
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

module room # (
    parameter AW = `CFG_ADDR_WIDTH,
    parameter DW = `CFG_DATA_WIDTH
)(
    //cmd in
    input i_cmd_valid,
    input [AW-1:0] i_cmd_addr, 
    input i_cmd_read, 
    input [DW-1:0] i_cmd_wdata,
    input [DW/8-1:0] i_cmd_wmask,
    //response out
    output o_rsp_valid,
    output o_rsp_err,
    output [DW-1:0] o_rsp_rdata,
    
    input clk, 
    input rst_n
);
    localparam RAW = `CFG_REG_ADDR_WIDTH;

    localparam I_CACHE_AW = `CFG_I_CACHE_ADDR_WIDTH;
    localparam D_CACHE_AW = `CFG_D_CACHE_ADDR_WIDTH;
    
    //master cmd from LSU
    wire lsu_cmd_valid;
    wire [AW-1:0] lsu_cmd_addr; 
    wire lsu_cmd_read; 
    wire [DW-1:0] lsu_cmd_wdata;
    wire [DW/8-1:0] lsu_cmd_wmask;
    //master response to LSU
    wire lsu_rsp_valid;
    wire lsu_rsp_err;
    wire [DW-1:0] lsu_rsp_rdata;
    
    //master cmd from IFU
    wire ifu_cmd_valid;
    wire [AW-1:0] ifu_cmd_addr; 
    wire ifu_cmd_read; 
    wire [DW-1:0] ifu_cmd_wdata;
    wire [DW/8-1:0] ifu_cmd_wmask;
    //master response to IFU
    wire ifu_rsp_valid;
    wire ifu_rsp_err;
    wire [DW-1:0] ifu_rsp_rdata;

    cpu # (
        .RAW(RAW),
        .AW(AW),
        .DW(DW)
    ) u_cpu (
        .i_holding(i_cmd_valid),
        
        .o_ifu_vrb_cmd_valid(ifu_cmd_valid),
        .o_ifu_vrb_cmd_addr(ifu_cmd_addr), 
        .o_ifu_vrb_cmd_read(ifu_cmd_read), 
        .o_ifu_vrb_cmd_wdata(ifu_cmd_wdata),
        .o_ifu_vrb_cmd_wmask(ifu_cmd_wmask),

        .i_ifu_vrb_rsp_valid(ifu_rsp_valid),
        .i_ifu_vrb_rsp_err(ifu_rsp_err),
        .i_ifu_vrb_rsp_rdata(ifu_rsp_rdata),
        
        //LSU master cmd to vrb
        .o_lsu_vrb_cmd_valid(lsu_cmd_valid),
        .o_lsu_vrb_cmd_addr(lsu_cmd_addr), 
        .o_lsu_vrb_cmd_read(lsu_cmd_read), 
        .o_lsu_vrb_cmd_wdata(lsu_cmd_wdata),
        .o_lsu_vrb_cmd_wmask(lsu_cmd_wmask),
        //LSU master response from vrb
        .i_lsu_vrb_rsp_valid(lsu_rsp_valid),
        .i_lsu_vrb_rsp_err(lsu_rsp_err),
        .i_lsu_vrb_rsp_rdata(lsu_rsp_rdata),
        
        .clk(clk),
        .rst_n(rst_n)
    );
    
    wire icache_selected;
    wire dcache_selected;
    
    assign icache_selected = i_cmd_valid && (i_cmd_addr[I_CACHE_AW] == 0);
    assign dcache_selected = i_cmd_valid && (i_cmd_addr[I_CACHE_AW] == 1);
    
    wire icache_cmd_valid;
    wire [AW-1:0] icache_cmd_addr; 
    wire icache_cmd_read; 
    wire [DW-1:0] icache_cmd_wdata;
    wire [DW/8-1:0] icache_cmd_wmask;
    //master response to icache
    wire icache_rsp_valid;
    wire icache_rsp_err;
    wire [DW-1:0] icache_rsp_rdata;
    
    assign icache_cmd_valid = icache_selected | ifu_cmd_valid;
    assign icache_cmd_addr = icache_selected ? i_cmd_addr : ifu_cmd_addr;
    assign icache_cmd_read = icache_selected ? i_cmd_read : ifu_cmd_read;
    assign icache_cmd_wdata = icache_selected ? i_cmd_wdata : ifu_cmd_wdata;
    assign icache_cmd_wmask = icache_selected ? i_cmd_wmask : ifu_cmd_wmask;
    
    imem # (
        .AW(I_CACHE_AW), 
        .DW(DW)
    ) u_icache (
        .i_cmd_valid(icache_cmd_valid),
        .i_cmd_addr(icache_cmd_addr[I_CACHE_AW-1:0]),
        .i_cmd_read(icache_cmd_read), 
        .i_cmd_wdata(icache_cmd_wdata),
        .i_cmd_wmask(icache_cmd_wmask),
        
        .o_rsp_valid(icache_rsp_valid),
        .o_rsp_err(icache_rsp_err),
        .o_rsp_rdata(icache_rsp_rdata),
    
        .clk(clk),
        .rst_n(rst_n)
    );
    
    wire dcache_cmd_valid;
    wire [AW-1:0] dcache_cmd_addr; 
    wire dcache_cmd_read; 
    wire [DW-1:0] dcache_cmd_wdata;
    wire [DW/8-1:0] dcache_cmd_wmask;
    //master response to dcache
    wire dcache_rsp_valid;
    wire dcache_rsp_err;
    wire [DW-1:0] dcache_rsp_rdata;
    
    assign dcache_cmd_valid = dcache_selected | lsu_cmd_valid;
    assign dcache_cmd_addr = dcache_selected ? i_cmd_addr : lsu_cmd_addr;
    assign dcache_cmd_read = dcache_selected ? i_cmd_read : lsu_cmd_read;
    assign dcache_cmd_wdata = dcache_selected ? i_cmd_wdata : lsu_cmd_wdata;
    assign dcache_cmd_wmask = dcache_selected ? i_cmd_wmask : lsu_cmd_wmask;
    
    imem # (
        .AW(D_CACHE_AW), 
        .DW(DW)
    ) u_dcache (
        .i_cmd_valid(dcache_cmd_valid),
        .i_cmd_addr(dcache_cmd_addr[D_CACHE_AW-1:0]), 
        .i_cmd_read(dcache_cmd_read), 
        .i_cmd_wdata(dcache_cmd_wdata),
        .i_cmd_wmask(dcache_cmd_wmask),

        .o_rsp_valid(dcache_rsp_valid),
        .o_rsp_err(dcache_rsp_err),
        .o_rsp_rdata(dcache_rsp_rdata),
    
        .clk(clk),
        .rst_n(rst_n)
    );
    
    assign ifu_rsp_valid = i_cmd_valid ? 0 : icache_rsp_valid;
    assign lsu_rsp_valid = i_cmd_valid ? 0 : dcache_rsp_valid;
    assign o_rsp_valid = icache_selected ? icache_rsp_valid : (
                            dcache_selected ? lsu_rsp_valid : 0);
                            
    assign ifu_rsp_err = i_cmd_valid ? 0 : icache_rsp_err;
    assign lsu_rsp_err = i_cmd_valid ? 0 : dcache_rsp_err;
    assign o_rsp_err = icache_selected ? icache_rsp_err : (
                            dcache_selected ? dcache_rsp_err : 0);

    assign ifu_rsp_rdata = i_cmd_valid ? 0 : icache_rsp_rdata;
    assign lsu_rsp_rdata = i_cmd_valid ? 0 : dcache_rsp_rdata;
    assign o_rsp_rdata = icache_selected ? icache_rsp_rdata : (
                            dcache_selected ? dcache_rsp_rdata : 0);

endmodule
