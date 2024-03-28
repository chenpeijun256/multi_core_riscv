`ifndef SIMULATION
`define CFG_FPGA
`endif

//`define CFG_M

`define CFG_ADDR_WIDTH 32
//`define AW `CFG_ADDR_WIDTH

`define CFG_DATA_WIDTH 32
//`define DW `CFG_DATA_WIDTH

`define CFG_RESET_PC 32'hf0000000

`define CFG_REG_ADDR_WIDTH 5 //32 regs
//`define RAW `CFG_REG_ADDR_WIDTH

//`define CFG_CSR_ADDR_WIDTH 12
//`define CAW `CFG_CSR_ADDR_WIDTH

`define CFG_I_CACHE_ADDR_WIDTH 12 //4k
`define CFG_D_CACHE_ADDR_WIDTH 12 //4k
//`define CFG_MROM_ADDR_WIDTH 8 //256B, 64 instruction for MROM
//`define RAM_AW `CFG_RAM_ADDR_WIDTH
//`define ROM_AW `CFG_ROM_ADDR_WIDTH
//`define MROM_AW `CFG_MROM_ADDR_WIDTH

//`define CFG_GPIO_PIN_WIDTH 32

//`define CFG_GPIO_A
//`define GPIO_A_PIN_N 6 //gpio a pin number

//`define CFG_UART_0

`define IS_U 0
`define IS_J 1
`define IS_I 2
`define IS_B 3
`define IS_S 4
`define IS_R 5
    
`define IS_LUI 0 
`define IS_AUIPC 1
`define IS_JAL 2
`define IS_JALR 3
`define IS_JB 4
`define IS_LOAD 5
`define IS_STORE 6
`define IS_MATH_I 7
`define IS_MATH 8
`define IS_FENCE 9
`define IS_CSR 10
`define IS_SYS 11
    
`define IS_ADDI 0
`define IS_SLTI 1
`define IS_SLTIU 2
`define IS_XORI 3
`define IS_ORI 4
`define IS_ANDI 5
`define IS_SLLI 6
`define IS_SRLI 7
`define IS_SRAI 8
    
`define IS_ADD 0
`define IS_SUB 1
`define IS_SLL 2
`define IS_SLT 3
`define IS_SLTU 4
`define IS_XOR 5
`define IS_SRL 6
`define IS_SRA 7
`define IS_OR 8
`define IS_AND 9

`define IS_MUL 0
`define IS_MULH 1
`define IS_MULHSU 2
`define IS_MULHU 3
`define IS_DIV 4
`define IS_DIVU 5
`define IS_REM 6
`define IS_REMU 7
    
`define IS_BEQ 0
`define IS_BNE 1
`define IS_BLT 2
`define IS_BGE 3
`define IS_BLTU 4
`define IS_BGEU 5
    
`define IS_LB 0
`define IS_LH 1
`define IS_LW 2
`define IS_LBU 3
`define IS_LHU 4

`define IS_SB 0
`define IS_SH 1
`define IS_SW 2

`define IS_ECALL 0
`define IS_EBREAK 1
`define IS_MRET 2
`define IS_CSR_RW 3
`define IS_CSR_RS 4
`define IS_CSR_RC 5
`define IS_CSR_RWI 6
`define IS_CSR_RSI 7
`define IS_CSR_RCI 8
