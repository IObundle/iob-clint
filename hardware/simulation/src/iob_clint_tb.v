`timescale 1ns / 1ps

`include "iob_clint_conf.vh"
`include "bsp.vh"
`define RTC_FREQ 100000

`define MSIP_BASE 0
`define MTIMECMP_BASE 16384
`define MTIME_BASE 49144

module iob_clint_tb;

   parameter realtime clk_per = 1s/`FREQ;
   parameter realtime rtc_per = 1s/`RTC_FREQ;

   //clock & real-time clock
   reg                clk_i = 1;
   reg                rtc = 1;
   always #(clk_per/2) clk_i = ~clk_i;
   always #(rtc_per/2) rtc = ~rtc;

   //reset
   reg                arst_i = 0;

   // DUT inputs
   reg                           iob_avalid;
   reg [`IOB_CLINT_ADDR_W-1:0]   iob_addr;
   reg [`IOB_CLINT_DATA_W-1:0]   iob_wdata;
   reg [`IOB_CLINT_DATA_W/8-1:0] iob_wstrb;

   // DUT outputs
   wire                          iob_rvalid;
   wire [`IOB_CLINT_DATA_W-1:0]  iob_rdata;
   wire                          iob_ready;
   wire [`IOB_CLINT_N_CORES-1:0] mtip;
   wire [`IOB_CLINT_N_CORES-1:0] msip;

   integer             i = 0;
   reg [63:0]          timer_read;

   initial begin
      //assert reset
      #100 arst_i = 1;
      iob_avalid = 0;
      iob_addr = 0;
      iob_wdata = 0;
      iob_wstrb = 0;
      timer_read = 0;

      // deassert arst_i
      repeat (100) @(posedge clk_i) #1;
      arst_i = 0;
      //wait an arbitray (10) number of cycles
      repeat (10) @(posedge clk_i) #1;
      set_inputs(`MTIMECMP_BASE, 200, 15);
      set_inputs(`MTIMECMP_BASE+4, 0, 15);
      $display("Timer Interrupt set.");
      while (1) begin
         if (mtip > 0) begin
            $display("Machine Timer Interrupt is trigered.");
            set_inputs(`MSIP_BASE, 1, 15);
            get_time(timer_read);
            $display("Timer count: %0d.", timer_read);
            set_inputs(`MTIME_BASE, 0, 15);
            set_inputs(`MTIMECMP_BASE, rtc_per*100, 4'hF);
         end
         if (msip > 0) begin
            $display("Machine Software Interrupt is trigered.");
            set_inputs(`MSIP_BASE, 0, 15);
         end
         @(posedge clk_i) #1 i = i + clk_per;
         if (i > rtc_per*250) begin
            @(posedge clk_i) #1 $display("Testbench finished!");
            $finish;
         end
      end
   end

   iob_clint_top clint_top
     (
      .clk_i  (clk_i),
      .arst_i (arst_i),

      .rtc (rtc),

      .iob_avalid (iob_avalid),
      .iob_addr   (iob_addr),
      .iob_wdata  (iob_wdata),
      .iob_wstrb  (iob_wstrb),
      .iob_rvalid (iob_rvalid),
      .iob_rdata  (iob_rdata),
      .iob_ready  (iob_ready),

      .mtip    (mtip),
      .msip    (msip)
      );

   task wait_responce;
      output [31:0] data_read;
      begin
         data_read = iob_rdata;
         while(iob_rvalid != 1) begin
           @ (posedge clk_i) data_read = iob_rdata;
          end
      end
   endtask

   task set_inputs;
      input [31:0]  set_address;
      input [31:0]  set_data;
      input [3:0]   set_strb;
      begin
         iob_avalid = 1;
         iob_addr = set_address;
         iob_wdata = set_data;
         iob_wstrb = set_strb;
         @ (posedge clk_i) #1 iob_avalid = 0;
         iob_wstrb = 0;
      end
   endtask

   task get_time;
      output [63:0] read_time;
      begin
         read_time = 0;
         set_inputs(`MTIME_BASE, 0, 0);
         wait_responce(read_time[31:0]);
         set_inputs(`MTIME_BASE+4, 0, 0);
         wait_responce(read_time[63:32]);
      end
   endtask

endmodule
