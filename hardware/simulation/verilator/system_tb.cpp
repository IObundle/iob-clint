#include <stdio.h>
#include <stdlib.h>

#include "Vmyclint.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

// other macros
#define FREQ 100000000
#define BAUD 5000000
#define CLK_PERIOD 10000 // 10 ns

vluint64_t main_time = 0;
VerilatedVcdC* tfp = NULL;
Vmyclint* dut = NULL;

double sc_time_stamp () {
  return main_time;
}

void Timer(unsigned int half_cycles){
  for(int i = 0; i<half_cycles; i++){
    dut->clk = !(dut->clk);
    dut->eval();
#ifdef VCD
    tfp->dump(main_time);
#endif
    main_time += CLK_PERIOD/2;
  }
}

void set_inputs(char* address, char* data, char* strb){
  unsigned int aux_num = 0;
  dut->valid = 1;
  sscanf(address, "%x", &aux_num);
  dut->address = aux_num;
  sscanf(data, "%x", &aux_num);
  dut->wdata = aux_num;
  sscanf(strb, "%x", &aux_num);
  dut->wstrb = aux_num;
  Timer(2);
}

int read_outputs(){
  while(dut->ready != 1){
    Timer(2);
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

  dut->clk = 0;
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
  for(int i = 0; i<5; i++){
    dut->clk = !(dut->clk);
    if(i==2 || i==4) dut->reset = !(dut->reset);
    dut->eval();
#ifdef VCD
    tfp->dump(main_time);
#endif
    main_time += CLK_PERIOD/2;
  }

  // set timer compare Register
  set_inputs("0x4000", "0x000F", "0xF");

  while(1){
    if(dut->mtip > 0){
        printf("Machine Timer Interrupt is trigered\n");
        break;
    }
    if(dut->msip > 0){
        printf("Machine Software Interrupt is trigered\n");
        break;
    }

  }

  dut->final();
#ifdef VCD
  tfp->close();
#endif
  delete dut;
  dut = NULL;
  exit(0);

}
