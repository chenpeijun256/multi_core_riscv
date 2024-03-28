`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2024 09:14:38 AM
// Design Name: 
// Module Name: pipe
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


module pipe # (
    parameter DATAW  = 1, 
    parameter DEPTH  = 1
) (
    input enable,
    input [DATAW-1:0] data_in,
    output [DATAW-1:0] data_out,
    
    input clk,
    input rst
);
    if (DEPTH == 0) begin        
        assign data_out = data_in;  
    end else if (DEPTH == 1) begin        
        reg [DATAW-1:0] value_r;

        always @(posedge clk) begin
            if (rst)
                value_r <= #1 DATAW'(0);
            else if (enable) 
                value_r <= #1 data_in;
            else
                ;
        end
        assign data_out = value_r;//enable ? value_r : DATAW'(0);
    end else begin
        wire [DEPTH:0][DATAW-1:0] data_delayed;        
        assign data_delayed[0] = data_in;
        for (genvar i = 1; i <= DEPTH; i=i+1) begin
            pipe #(
                .DATAW  (DATAW)
            ) pipe_reg (
                .clk      (clk),
                .rst      (rst),
                .enable   (enable),
                .data_in  (data_delayed[i-1]),
                .data_out (data_delayed[i])
            );
        end
        assign data_out = data_delayed[DEPTH];
    end
endmodule
