`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2024 08:46:15 AM
// Design Name: 
// Module Name: imem
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

//inner memory unit////
module imem # (
    parameter AW  = 11, 
    parameter DW  = 32
) (
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

    input  clk,
    input  rst_n
);
    localparam ND = DW / 8;
    localparam EA = $clog2(ND);
    localparam DP = (2**AW) / ND; 
    
    reg [DW-1:0] _data [DP-1: 0];
    
    wire [DW-1:0] mask;
    
    generate
        genvar i;
        for(i = 0; i < ND; i = i + 1)
            assign mask[i*8+7: i*8] = {8{i_cmd_wmask[i]}};
    endgenerate

    always @(posedge clk) begin
        if (!i_cmd_read && i_cmd_valid) begin
            _data[i_cmd_addr[AW-1:EA]] <= #1 (_data[i_cmd_addr[AW-1:EA]] & (~mask)) | (i_cmd_wdata & mask);
        end
        else begin
            ;
        end
    end
    
    assign o_rsp_err = 1'b0;
    assign o_rsp_valid = i_cmd_valid;
    assign o_rsp_rdata = o_rsp_valid ? _data[i_cmd_addr[AW-1:EA]] : 0;
endmodule
