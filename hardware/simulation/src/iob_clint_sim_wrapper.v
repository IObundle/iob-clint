`timescale 1ns / 1ps

module iob_clint_sim_wrapper #(
   parameter ADDR_W  = 16,
   parameter DATA_W  = 32,
   parameter N_CORES = 1
) (
   `include "iob_clint_iob_clk_s_port.vs"

   input rtc_i,

   `include "iob_clint_iob_s_port.vs"

   output [N_CORES-1:0] mtip_o,
   output [N_CORES-1:0] msip_o
);

`ifdef VCD
   initial begin
      $dumpfile("iob_clint.vcd");
      $dumpvars();
   end
`endif

   iob_clint #(
      .ADDR_W (ADDR_W),
      .DATA_W (DATA_W),
      .N_CORES(N_CORES)
   ) clint (
       `include "iob_clint_iob_clk_s_s_portmap.vs"

       .rt_clk_i(rtc_i),

       .mtip_o(mtip_o),
       .msip_o(msip_o),

       `include "iob_clint_iob_s_s_portmap.vs"
   );

endmodule
