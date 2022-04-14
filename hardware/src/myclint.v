/*########
  MyCLINT
  #######*/

module myclint #(
    parameter ADDR_W  = 32,
    parameter DATA_W  = 32,
    parameter N_CORES = 1 // Number of cores, therefore the number of timecmp registers and timer interrupts
) (
    input                 clk,
    input                 reset,
    input                 valid,
    input  [ADDR_W-1:0]   address,
    input  [DATA_W-1:0]   wdata,
    input  [DATA_W/8-1:0] wstrb,
    output [DATA_W-1:0]   rdata,
    output                ready,
    output [N_CORES-1:0]  mtip, // Machine timer interrupt pin
    output [N_CORES-1:0]  msip  // Machine software interrupt (a.k.a inter-process-interrupt)
);

  // NEED to generate a real time clock -> input  rt_clk, // Real-time clock in (usually 32.768 kHz)
endmodule
