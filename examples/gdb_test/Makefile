RISCV_ARCH := rv32i
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow

# TARGET = test_main
CFLAGS += -ggdb
LDFLAGS += -ggdb

RISCV_PATH := /home/chenpj/riscv_gcc

RISCV_GCC     := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-gcc)
RISCV_AS      := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-as)
RISCV_GXX     := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-g++)
RISCV_OBJDUMP := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-objdump)
RISCV_GDB     := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-gdb)
RISCV_AR      := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-ar)
RISCV_OBJCOPY := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-objcopy)
RISCV_READELF := $(abspath $(RISCV_PATH)/bin/riscv64-unknown-elf-readelf)

ASM_SRCS += start.S
ASM_SRCS += trap_entry.S
C_SRCS := $(TARGET).c
C_SRCS += init.c
C_SRCS += trap_handler.c

LINKER_SCRIPT := link.lds

INCLUDES += -I.

LDFLAGS += -T $(LINKER_SCRIPT) -nostartfiles -Wl,--gc-sections -Wl,--check-sections 

ASM_OBJS := $(ASM_SRCS:.S=.o)
C_OBJS := $(C_SRCS:.c=.o)

LINK_OBJS += $(ASM_OBJS) $(C_OBJS)
LINK_DEPS += $(LINKER_SCRIPT)

CLEAN_OBJS += $(TARGET) $(LINK_OBJS) $(TARGET).dump $(TARGET).verilog $(TARGET).bin

CFLAGS += -march=$(RISCV_ARCH)
CFLAGS += -mabi=$(RISCV_ABI)
CFLAGS += -mcmodel=$(RISCV_MCMODEL) -ffunction-sections -fdata-sections -fno-builtin-printf -fno-builtin-malloc

.PHONY: all
all: $(TARGET)
$(TARGET): $(LINK_OBJS) $(LINK_DEPS) Makefile
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) $(LINK_OBJS) -o $@ $(LDFLAGS)
	$(RISCV_OBJCOPY) -O binary $@ $@.bin
	$(RISCV_OBJCOPY) -O verilog $@ $@.verilog
	$(RISCV_OBJDUMP) --disassemble-all $@ > $@.dump

$(ASM_OBJS): %.o: %.S
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

$(C_OBJS): %.o: %.c
	$(RISCV_GCC) $(CFLAGS) $(INCLUDES) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(CLEAN_OBJS)
