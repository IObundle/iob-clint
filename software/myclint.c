#include "myclint.h"

void clint_init(int base_address){
  base = base_address;
}

void clint_set_timer(unsigned long long time){
  (*(volatile uint32_t *) (base+MTIME_BASE)) = *(int *)(&time);
  (*(volatile uint32_t *) (base+MTIME_BASE+4)) = *(int *)(&time+4);
}

unsigned long long clint_get_timer(){
  unsigned long long read_time = 0;

  *(int *)(&read_time) = (*(volatile uint32_t *) (base+MTIME_BASE));
  *(int *)(&read_time+4) = (*(volatile uint32_t *) (base+MTIME_BASE+4));

  return read_time;
}

void clint_set_timercmp(unsigned long long time, int hart){
  (*(volatile uint32_t *) (base+MTIMECMP_BASE+8*hart)) = *(int *)(&time);
  (*(volatile uint32_t *) (base+MTIMECMP_BASE+8*hart+4)) = *(int *)(&time+4);
}

unsigned long long clint_get_timercmp(int hart){
  unsigned long long read_time = 0;

  *(int *)(&read_time) = (*(volatile uint32_t *) (base+MTIMECMP_BASE+8*hart));
  *(int *)(&read_time+4) = (*(volatile uint32_t *) (base+MTIMECMP_BASE+8*hart+4));

  return read_time;
}

void clint_set_msip(int msip_value, int hart){
  (*(volatile uint32_t *) (base+MSIP_BASE+4*hart)) = msip_value;
}

unsigned int clint_get_msip(int hart){
  unsigned int msip_value = 0;

  msip_value = (*(volatile uint32_t *) (base+MSIP_BASE+4*hart));

  return msip_value;
}
