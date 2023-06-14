`timescale 1ns / 1ps
`include "iob_lib.vh"
`include "iob_clint_conf.vh"
`include "bsp.vh"

/*
  This CLINT module was developed to work in FPGAs and does not use a Real-time clock.
  Real-time clock usually are 32.768 kHz.
  One could be passed through the inputs of the module.
  However, for it to work alterations must be made to the module.
*/
module iob_clint #(
   `include "iob_clint_params.vs"
) (
   `include "iob_clint_io.vs"
);

   // Local parameters
   localparam integer AddrSelWidth = (N_CORES == 1) ? 1 : $clog2(N_CORES);
   // register offset, base address are Backward Compatible With SiFive CLINT
   localparam integer MSIBase = 16'h0;
   localparam integer MTimeCMPBase = 16'h4000;
   localparam integer MTimeBase = 16'hbff8;

   // Wires, regs and variables
   wire               write;
   reg  [ DATA_W-1:0] iob_rdata_reg;
   reg  [       63:0] mtimecmp          [N_CORES];
   reg  [       63:0] mtime;
   reg  [N_CORES-1:0] mtip_reg;
   reg  [N_CORES-1:0] msip_reg;
   wire [        9:0] counter;
   wire               counter_e;
   wire               increment_timer;
   wire               increment_timer_r;
   integer j, k, c;

   // Logic and registers
   assign write       = |iob_wstrb_i;
   assign iob_rdata_o = iob_rdata_reg;
   // Address decoder
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         iob_rdata_reg <= {(DATA_W) {1'b0}};
      end else if (iob_addr_i < MTimeCMPBase) begin
         iob_rdata_reg <= {{(DATA_W - 1) {1'b0}}, msip[iob_addr_i[AddrSelWidth+1:2]]};
      end else if (iob_addr_i < MTimeBase) begin
         iob_rdata_reg <= mtimecmp[iob_addr_i[AddrSelWidth+2:3]][(iob_addr_i[2]+1)*DATA_W-1-:DATA_W];
      end else begin
         iob_rdata_reg <= mtime[(iob_addr_i[2]+1)*DATA_W-1-:DATA_W];
      end
   end

   assign counter_e       = (counter < `FREQ / 100000 - 1);
   assign increment_timer = (counter == `FREQ / 100000 - 1);

   // Machine-level Timer Device (MTIMER)
   assign mtip            = mtip_reg;
   always @(*) begin
      if (arst_i)
         for (k = 0; k < N_CORES; k = k + 1) begin
            mtip_reg[k] = {1'b0};
         end
      else
         for (k = 0; k < N_CORES; k = k + 1) begin
            mtip_reg[k] = (mtime >= mtimecmp[k][63:0]);
         end
   end

   // mtimecmp
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         for (c = 0; c < N_CORES; c = c + 1) begin
            mtimecmp[c] <= {64{1'b1}};
         end
      end else if (iob_avalid_i & write & (iob_addr_i >= MTimeCMPBase) & (iob_addr_i < (MTimeCMPBase + 8 * N_CORES))) begin
         mtimecmp[iob_addr_i[AddrSelWidth+2:3]][(iob_addr_i[2]+1)*DATA_W-1-:DATA_W] <= iob_wdata_i;
      end
   end

   // mtime
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         mtime <= {64{1'b0}};
      end else if (iob_avalid_i & write & (iob_addr_i >= MTimeBase) & (iob_addr_i < (MTimeBase + 8))) begin
         mtime[(iob_addr_i[2]+1)*DATA_W-1-:DATA_W] <= iob_wdata_i;
      end else if (increment_timer_r) begin
         mtime <= mtime + 1'b1;
      end
   end

   // Machine-level Software Interrupt Device (MSWI) - msip
   assign msip = msip_reg;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         for (j = 0; j < N_CORES; j = j + 1) begin
            msip_reg[j] <= {1'b0};
         end
      end else if (iob_avalid_i & write & (iob_addr_i >= MSIBase) & (iob_addr_i < (MSIBase + 4 * N_CORES))) begin
         msip_reg[iob_addr_i[AddrSelWidth+1:2]] <= iob_wdata_i[0];
      end
   end


   /*
  // Real Time Clock and Device Clock Synconizer, in order to minimize meta stability
  localparam STAGES = 2;

  wire rtc_value;
  reg  rtc_previous;
  reg [STAGES-1:0] rtc_states;

  wire increment_timer = rtc_value & ~rtc_previous; // detects rising edge
  assign rtc_value = rtc_states[STAGES-1];

  // Sync rt clk_i with clk_i
  always @(posedge clk_i, posedge arst_i) begin
     if (arst_i) begin
        rtc_states <= {STAGES{1'b0}};
     end else begin
        rtc_states <= {rtc_states[STAGES-2:0], rt_clk};
     end
  end

  always @(posedge clk_i, posedge arst_i) begin
     if (arst_i) begin
        rtc_previous <= 1'b0;
     end else begin
        rtc_previous <= rtc_value;
     end
  end
  */


   // Module intanciation
   // // Interface Registers
   // // // Read data valid
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_rvalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (~write),
      .data_i(iob_avalid_i),
      .data_o(iob_rvalid_o)
   );
   // // // Ready signal, is always 1 since the read and write to the CLINT only take one clock cycle.
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_ready (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(1'b1),
      .data_o(iob_ready_o)
   );
   // // Internal Registers
   iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
   ) iob_reg_increment_timer (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(increment_timer),
      .data_o(increment_timer_r)
   );
   // counter
   iob_counter #(
      .DATA_W (10),
      .RST_VAL(0)
   ) iob_counter_0 (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (~counter_e),
      .en_i  (counter_e),
      .data_o(counter)
   );

endmodule
