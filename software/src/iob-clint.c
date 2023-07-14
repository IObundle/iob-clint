#include <stdint.h>

#include "iob-clint.h"

void clint_init(int base_address){
  base = base_address;
}

void clint_set_timer(unsigned long long time){
  (*(volatile uint32_t *) (base + MTIME_BASE))     = (uint32_t)(time & 0x0FFFFFFFFUL);
  (*(volatile uint32_t *) (base + MTIME_BASE + 4)) = (uint32_t)(time >> 32);
}

uint64_t clint_get_timer(){
  uint64_t read_time;

  read_time  = (uint64_t)(*(volatile uint32_t *) (base + MTIME_BASE));
  read_time |= (uint64_t)(*(volatile uint32_t *) (base + MTIME_BASE + 4)) << 32;

  return read_time;
}

void clint_set_timercmp(unsigned long long time, int hart){
  (*(volatile uint32_t *) (base + MTIMECMP_BASE + 8*hart + 4)) = 0xFFFFFFFF;
  (*(volatile uint32_t *) (base + MTIMECMP_BASE + 8*hart))     = (uint32_t)(time & 0x0FFFFFFFFUL);
  (*(volatile uint32_t *) (base + MTIMECMP_BASE + 8*hart + 4)) = (uint32_t)(time >> 32);
}

unsigned long long clint_get_timercmp(int hart){
  unsigned long long read_time;

  read_time  = (unsigned long long)(*(volatile uint32_t *) (base + MTIMECMP_BASE + 8*hart));
  read_time |= (unsigned long long)(*(volatile uint32_t *) (base + MTIMECMP_BASE + 8*hart + 4)) << 32;

  return read_time;
}

void clint_set_msip(unsigned long msip_value, int hart){
  (*(volatile uint32_t *) (base + MSIP_BASE + 4*hart)) = msip_value;
}

unsigned long clint_get_msip(int hart){
  unsigned long msip_value;

  msip_value = (*(volatile uint32_t *) (base + MSIP_BASE + 4*hart));

  return msip_value;
}
