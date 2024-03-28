`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 09:17:46 AM
// Design Name: 
// Module Name: reg_file
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


module reg_file # (
    parameter RAW  = 5, 
    parameter DW  = 32
) (
    input [RAW-1:0] i_write_reg,
    input [DW-1:0] i_write_data,
    input i_write_en,
    
    input i_read_reg1_en,
    input [RAW-1:0] i_read_reg1,
    output [DW-1:0] o_read_data1,
    
    input i_read_reg2_en,
    input [RAW-1:0] i_read_reg2,
    output [DW-1:0] o_read_data2,

    input  clk,
    input  rst_n
);
    localparam DP = (2**RAW); 
    
    reg [DW-1:0] reg_file [1:DP-1];
    
//    reg [DW-1:0] r_data1;
//    reg [DW-1:0] r_data2;
    
    always @(posedge clk) begin
        if (i_write_en && (i_write_reg != 0))
            reg_file[i_write_reg] <= #1 i_write_data;
        else
            ;
    end
    
//    always @(posedge clk) begin
//        if (rst_n == 1'b0) begin
//            r_data1 <= #1 '0;
//        end
//        else if (i_read_reg1_en) begin
//            if (i_read_reg1 == 0) begin
//                r_data1 <= #1 '0;
//            end
//            else begin
////                r_data1 <= (i_read_reg1 == i_write_reg) ? i_write_data : reg_file[i_read_reg1];
//                r_data1 <= #1 reg_file[i_read_reg1];
//            end
//        end
//        else begin
////            r_data1 <= '0;
//        end
//    end
//    always @(posedge clk) begin
//        if (rst_n == 1'b0) begin
//            r_data2 <= #1 '0;
//        end
//        else if (i_read_reg2_en) begin
//            if (i_read_reg2 == 0) begin
//                r_data2 <= #1 '0;
//            end
//            else begin
////                r_data2 <= (i_read_reg2 == i_write_reg) ? i_write_data : reg_file[i_read_reg2];
//                r_data2 <= #1 reg_file[i_read_reg2];
//            end
//        end
//        else begin
////            r_data2 <= '0;
//        end
//    end

//    assign o_read_data1 = r_data1;
//    assign o_read_data2 = r_data2;
    assign o_read_data1 = (i_read_reg1 == 0) ? 0 : reg_file[i_read_reg1];
    assign o_read_data2 = (i_read_reg2 == 0) ? 0 : reg_file[i_read_reg2];
endmodule
