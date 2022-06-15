`timescale 1ns / 1ps

module iob_clint_top
  #(
    parameter ADDR_W  = 16,
    parameter DATA_W  = 32,
    parameter N_CORES = 1
    )
  (
    input                clk,
    input                rst,

    input                rtc,

    input                valid,
    input [ADDR_W-1:0]   address,
    input [DATA_W-1:0]   wdata,
    input [DATA_W/8-1:0] wstrb,
    output [DATA_W-1:0]  rdata,
    output               ready,

    output [N_CORES-1:0] mtip,
    output [N_CORES-1:0] msip
   );

`ifdef VCD
   initial begin
      $dumpfile("iob_clint.vcd");
      $dumpvars();
   end
`endif

   iob_clint
     #(
       .ADDR_W(ADDR_W),
       .DATA_W(DATA_W),
       .N_CORES(N_CORES)
       )
   clint
     (
      .clk     (clk),
      .rst     (rst),

      .rt_clk  (rtc),

      .valid   (valid),
      .address (address),
      .wdata   (wdata),
      .wstrb   (wstrb),
      .rdata   (rdata),
      .ready   (ready),

      .mtip    (mtip),
      .msip    (msip)
      );

endmodule
