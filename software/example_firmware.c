#include <stdio.h>
#include <stdint.h>
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "myclint.h"
#include "printf.h"

int main()
{
    unsigned long long elapsed = 0;

    //init uart
    uart_init(UART_BASE,FREQ/BAUD);
    clint_init(CLINT_BASE);

    // clint_set_timer(0);

    uart_puts("\n\n\nHello world!\n\n\n");
    printf("Value of Pi = %f\n\n", 3.1415);

    elapsed = clint_get_timer();
    printf("\nCLINT timer value: %llu\n", elapsed);

    printf("CLINT elapsed time: %f\n", elapsed/32768.0);
    uart_finish();
}
