#include "bsp.h"
#include "iob-uart16550.h"
#include "iob_soc_opencryptolinux_conf.h"
#include "iob_soc_opencryptolinux_periphs.h"
#include "iob_soc_opencryptolinux_system.h"
#include "iob-clint.h"
#include "printf.h"

#include "riscv-csr.h"
#include "riscv-interrupts.h"
#include "iob-clint-timer.h"

// Machine mode interrupt service routine
static void irq_entry(void) __attribute__ ((interrupt ("machine")));

// Global to hold current timestamp
static volatile uint64_t timestamp = 0;

int main() {
    //init uart
    uart_init(UART_BASE,FREQ/BAUD);
    clint_init(CLINT0_BASE);

    printf("\n\n\nHello world!\n\n\n");

    // Global interrupt disable
    csr_clr_bits_mstatus(MSTATUS_MIE_BIT_MASK);
    csr_write_mie(0);
    csr_clr_bits_mcause(MCAUSE_INTERRUPT_ALL_SET_MASK);
    csr_write_mcause(0);

    // Setup timer for 1 second interval
    timestamp = mtimer_get_raw_time();
    mtimer_set_raw_time_cmp(MTIMER_SECONDS_TO_CLOCKS(0.001));

    // Setup the IRQ handler entry point
    csr_write_mtvec((uint_xlen_t) irq_entry);

    // Enable MIE.MTI
    csr_set_bits_mie(MIE_MTI_BIT_MASK);

    // Global interrupt enable
    csr_set_bits_mstatus(MSTATUS_MIE_BIT_MASK);

    printf("Waiting...\n");
    // Wait for interrupt
    __asm__ volatile ("wfi");

    printf("Exit...\n");
    uart_finish();
    return 0;

}

#pragma GCC push_options
// Force the alignment for mtvec.BASE. A 'C' extension program could be aligned to to bytes.
#pragma GCC optimize ("align-functions=4")
static void irq_entry(void)  {
    printf("Entered IRQ.\n");
    uint_xlen_t this_cause = csr_read_mcause();
    if (this_cause &  MCAUSE_INTERRUPT_BIT_MASK) {
        this_cause &= 0xFF;
        // Known exceptions
        switch (this_cause) {
        case RISCV_INT_POS_MTI :
            printf("Time interrupt.\n");
            // Timer exception, keep up the one second tick.
            mtimer_set_raw_time_cmp(MTIMER_SECONDS_TO_CLOCKS(1));
            timestamp = mtimer_get_raw_time();
            break;
        }
    }
}
#pragma GCC pop_options
