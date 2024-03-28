`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2024 09:43:38 AM
// Design Name: 
// Module Name: room_tb
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


module room_tb(
);
    
    integer FN;

    integer ts_cycle[46: 0];
    string ts_filename[46: 0];

    string ts_dir = "/home/chenpj/smb/verilog/isa/";

    initial begin
        FN = 0;
        ts_filename[FN] = {ts_dir, "rv32ui-p-add.verilog"};   ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-addi.verilog"};  ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-and.verilog"};   ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-andi.verilog"};  ts_cycle[FN] = 250;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-auipc.verilog"}; ts_cycle[FN] = 100;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-beq.verilog"};   ts_cycle[FN] = 400;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-bge.verilog"};   ts_cycle[FN] = 450;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-bgeu.verilog"};  ts_cycle[FN] = 500;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-blt.verilog"};   ts_cycle[FN] = 400;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-bltu.verilog"};  ts_cycle[FN] = 450;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-bne.verilog"};   ts_cycle[FN] = 400;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-jal.verilog"};   ts_cycle[FN] = 100;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-jalr.verilog"};  ts_cycle[FN] = 150;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-lb.verilog"};    ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-lbu.verilog"};   ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-lh.verilog"};    ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-lhu.verilog"};   ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-lui.verilog"};   ts_cycle[FN] = 100;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-lw.verilog"};    ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-or.verilog"};    ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-ori.verilog"};   ts_cycle[FN] = 250;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sb.verilog"};    ts_cycle[FN] = 500;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sh.verilog"};    ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-simple.verilog"};ts_cycle[FN] = 50;    FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sll.verilog"};   ts_cycle[FN] = 600;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-slli.verilog"};  ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-slt.verilog"};   ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-slti.verilog"};  ts_cycle[FN] = 250;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sltiu.verilog"}; ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sltu.verilog"};  ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sra.verilog"};   ts_cycle[FN] = 600;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-srai.verilog"};  ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-srl.verilog"};   ts_cycle[FN] = 600;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-srli.verilog"};  ts_cycle[FN] = 300;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sub.verilog"};   ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-sw.verilog"};    ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-xor.verilog"};   ts_cycle[FN] = 550;   FN = FN + 1;
        ts_filename[FN] = {ts_dir, "rv32ui-p-xori.verilog"};  ts_cycle[FN] = 250;   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-mul.verilog"};   ts_cycle[FN] = 550;   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-mulh.verilog"};  ts_cycle[FN] = 550;   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-mulhsu.verilog"};ts_cycle[FN] = 550;   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-mulhu.verilog"}; ts_cycle[FN] = 550;   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-divu.verilog"};  ts_cycle[FN] = 1000   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-div.verilog"};   ts_cycle[FN] = 1000   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-rem.verilog"};   ts_cycle[FN] = 1000   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32um-p-remu.verilog"};  ts_cycle[FN] = 1000   FN = FN + 1;
        // ts_filename[FN] = {ts_dir, "rv32ui-p-fence_i.verilog"};ts_cycle[FN] = 100   FN = FN + 1;
    end

    localparam CLK_T = 10;
    localparam RST_T = 20;

    localparam AW = `CFG_ADDR_WIDTH;
    localparam DW = `CFG_DATA_WIDTH;
    
    localparam ROM_AW = `CFG_I_CACHE_ADDR_WIDTH;
    localparam RAM_AW = `CFG_D_CACHE_ADDR_WIDTH;
    localparam ROM_LEN = (2**ROM_AW);
    localparam RAM_LEN = (2**RAM_AW);
    localparam DAT_LEN = (ROM_LEN + RAM_LEN);
    reg [7:0] data[DAT_LEN-1: 0];
    
    reg clk;
    reg rst_n;
    
    //cmd in
    reg i_cmd_valid;
    reg [AW-1:0] i_cmd_addr; 
    reg i_cmd_read; 
    reg [DW-1:0] i_cmd_wdata;
    reg [DW/8-1:0] i_cmd_wmask;
    //response out
    wire o_rsp_valid;
    wire o_rsp_err;
    wire [DW-1:0] o_rsp_rdata;
    
    integer i, k;
    integer failed_case = 0;

    always begin 
        #(CLK_T/2) clk <= ~clk;
    end

    initial begin
        $dumpfile("room_tb.vcd");
        $dumpvars(0, room_tb);

        // ts_def[0] = '{550, "../isa/rv32ui-p-fence_i.verilog"};

        clk = 1'b1;
        i_cmd_valid = 1'b0;
        i_cmd_addr = 0;
        i_cmd_read = 1'b0;
        i_cmd_wdata = 0;
        i_cmd_wmask = 0;
        
        for (k = 0; k < FN; k=k+1) begin
            rst_n = 1'b0;
            
            $display("test file:%0s.",ts_filename[k]);
            $readmemh(ts_filename[k], data);
            for(i = 0; i < ROM_LEN; i = i + 4) begin
                u_room.u_icache._data[i/4] = {data[i+3], data[i+2], data[i+1], data[i]};
            end
            for(i = ROM_LEN; i < DAT_LEN; i = i + 4) begin
                u_room.u_dcache._data[(i-ROM_LEN)/4] = {data[i+3], data[i+2], data[i+1], data[i]};
            end

            #RST_T
            rst_n = 1'b1;
            
//            for(i = 0; i < DAT_LEN; i = i + 4) begin
//                i_cmd_valid = 1'b1;
//                i_cmd_addr = i;
//                i_cmd_read = 1'b0;
//                i_cmd_wdata = {data[i+3], data[i+2], data[i+1], data[i]};
//                i_cmd_wmask = 4'h0f;
//                #(CLK_T);
//            end
//            i_cmd_valid = 1'b0;
//            i_cmd_addr = 0;
//            i_cmd_read = 1'b0;
//            i_cmd_wdata = 0;
//            i_cmd_wmask = 4'h00;
            
            #(CLK_T*(ts_cycle[k]));
            
            if (u_room.u_cpu.u_reg_file.reg_file[27] == 0) begin
                $display("failed.");
                failed_case = failed_case + 1;
            end
            else begin
                $display("passed.");
            end
        end
        
        $display("total case: %0d, failed: %0d, success: %0d.", FN, failed_case, FN - failed_case);
        $finish(1);
    end
    
    room u_room (
        .*
    );
    
endmodule
