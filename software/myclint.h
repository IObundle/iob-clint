#pragma once

#include <stdint.h>

#define MSIP_BASE 0
#define MTIMECMP_BASE 16384
#define MTIME_BASE 49144

//Functions
void clint_set_timer(unsigned long long);
void clint_set_timercmp(unsigned long long, int);
void clint_set_msip(int, int);

unsigned long long clint_get_timer();
unsigned long long clint_get_timercmp(int);
unsigned int clint_get_msip(int);
