
RTL_DIR := ../src/rtl
TB_DIR := ../src/tb
INC_DIR := ../src/rtl

IVERILOG     := /usr/bin/iverilog

RTL_SRCS := $(RTL_DIR)/config.vh \
			$(RTL_DIR)/alu.sv \
			$(RTL_DIR)/cpu.sv \
			$(RTL_DIR)/dec.sv \
			$(RTL_DIR)/decu.sv \
			$(RTL_DIR)/dfu.sv \
			$(RTL_DIR)/exeu.sv \
			$(RTL_DIR)/ifu.sv \
			$(RTL_DIR)/imem.sv \
			$(RTL_DIR)/lsu.sv \
			$(RTL_DIR)/mult.sv \
			$(RTL_DIR)/pcu.sv \
			$(RTL_DIR)/pipe.sv \
			$(RTL_DIR)/reg_file.sv \
			$(RTL_DIR)/room.sv

.PHONY: room

room: room_tb.vvp

room_tb.vvp: $(RTL_SRCS) $(TB_DIR)/room_tb.sv
	iverilog -g2005-sv -o room_tb.vvp -I $(INC_DIR) $(RTL_SRCS) $(TB_DIR)/room_tb.sv -s room_tb
	vvp room_tb.vvp

.PHONY: clean
clean:
	rm -f *.vvp *.vcd