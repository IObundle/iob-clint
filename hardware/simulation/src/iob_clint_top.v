`timescale 1ns / 1ps

module iob_clint_top #(
    parameter ADDR_W  = 16,
    parameter DATA_W  = 32,
    parameter N_CORES = 1
  )  (
    input                clk_i,
    input                arst_i,

    input                rtc,

    input [0:0]          iob_avalid,
    input [ADDR_W-1:0]   iob_addr,
    input [DATA_W-1:0]   iob_wdata,
    input [DATA_W/8-1:0] iob_wstrb,
    output [0:0]         iob_rvalid,
    output [DATA_W-1:0]  iob_rdata,
    output [0:0]         iob_ready,

    output [N_CORES-1:0] mtip,
    output [N_CORES-1:0] msip
    );

`ifdef VCD
  initial begin
    $dumpfile("iob_clint.vcd");
    $dumpvars();
  end
`endif

  wire cke_i = 1'b1;

  iob_clint #(
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W),
      .N_CORES(N_CORES)
    ) clint (
      `include "iob_s_portmap.vh"

      .rt_clk  (rtc),

      .mtip    (mtip),
      .msip    (msip),

      `include "iob_clkenrst_portmap.vh"
      );

endmodule
