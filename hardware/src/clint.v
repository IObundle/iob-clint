/*########
  MyCLINT
  #######*/

module clint #(
    parameter ADDR_W  = 32,
    parameter DATA_W  = 32,
    parameter N_CORES = 1 // Number of cores, therefore the number of timecmp registers and timer interrupts
) (
    input  clk,
    input  reset,
    input  [`REQ_W-1:0] req,
    output [`RESP_W-1:0] resp,
    input  rt_clk, // Real-time clock in (usually 32.768 kHz)
    output [N_CORES-1:0] mtip, // Machine timer interrupt pin
    output [N_CORES-1:0] msip  // Machine software interrupt (a.k.a inter-process-interrupt)
);


endmodule
