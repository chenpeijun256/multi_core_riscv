#include <stdint.h>


extern void ext_irq_handler(uint32_t mcause, uint32_t mepc) __attribute__((weak));


void trap_handler(uint32_t mcause, uint32_t mepc)
{
    ext_irq_handler(mcause, mepc);
}
