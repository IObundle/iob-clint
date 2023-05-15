#pragma once

#define MSIP_BASE 0
#define MTIMECMP_BASE 16384
#define MTIME_BASE 49144

//Functions
static int base;
void clint_init(int);

void clint_set_timer(unsigned long long);
void clint_set_timercmp(unsigned long long, int);
void clint_set_msip(unsigned long, int);

unsigned long long clint_get_timer();
unsigned long long clint_get_timercmp(int);
unsigned long clint_get_msip(int);
