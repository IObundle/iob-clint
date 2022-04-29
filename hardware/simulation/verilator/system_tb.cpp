#include <stdio.h>
#include <stdlib.h>

#include "Vmyclint.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

// other macros
#define CLK_PERIOD 10 // 10 ns
#define RTC_PERIOD 30517 // 30.517us

#define MSIP_BASE 0
#define MTIMECMP_BASE 16384
#define MTIME_BASE 49144

vluint64_t main_time = 0;
VerilatedVcdC* tfp = NULL;
Vmyclint* dut = NULL;

double sc_time_stamp(){
  return main_time;
}

void Timer(unsigned int ns){
  for(int i = 0; i<ns; i++){
    if(!(main_time%(CLK_PERIOD/2))){
      dut->clk = !(dut->clk);
    }
    if(!(main_time%(RTC_PERIOD/2))){
      dut->rt_clk = !(dut->rt_clk);
    }
    dut->eval();
#ifdef VCD
    tfp->dump(main_time);
#endif
    main_time += 1;
  }
}

void set_inputs(int address, int data, int strb){
  unsigned int aux_num = 0;
  dut->valid = 1;
  dut->address = address;
  dut->wdata = data;
  dut->wstrb = strb;
  Timer(CLK_PERIOD);
  dut->valid = 0;
}

int read_outputs(){
  while(dut->ready != 1){
    Timer(CLK_PERIOD);
  }
  return dut->rdata;
}

int main(int argc, char **argv, char **env){
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  dut = new Vmyclint;

#ifdef VCD
  tfp = new VerilatedVcdC;

  dut->trace(tfp, 1);
  tfp->open("system.vcd");
#endif
  main_time = 0;

  dut->clk = 0;
  dut->rt_clk = 0;
  dut->reset = 0;
  dut->valid = 0;
  dut->address = 0;
  dut->wdata = 0;
  dut->wstrb = 0;

  dut->eval();
#ifdef VCD
  tfp->dump(main_time);
#endif

  // Reset sequence
  Timer(CLK_PERIOD);
  dut->reset = !(dut->reset);
  Timer(CLK_PERIOD);
  dut->reset = !(dut->reset);

  // set timer compare Register
  // set_inputs(address, data, strb);
  set_inputs(MTIMECMP_BASE, 20, 15);
  read_outputs();
  set_inputs(MTIMECMP_BASE+4, 0, 15);
  read_outputs();

  while(1){
    if(dut->mtip > 0){
        printf("Machine Timer Interrupt is trigered\n");
        break;
    }
    if(dut->msip > 0){
        printf("Machine Software Interrupt is trigered\n");
        break;
    }
    Timer(CLK_PERIOD);
    if (main_time>RTC_PERIOD*100) break;
  }
  Timer(CLK_PERIOD);

  printf("Testbench finished!\n");
  dut->final();
#ifdef VCD
  tfp->close();
#endif
  delete dut;
  dut = NULL;
  exit(0);

}
