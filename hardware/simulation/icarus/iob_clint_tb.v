`timescale 1ns / 1ps

`define MSIP_BASE 0
`define MTIMECMP_BASE 16384
`define MTIME_BASE 49144

module iob_clint_tb;

   parameter realtime clk_per = 1s/`FREQ;
   parameter realtime rtc_per = 1s/`RTC_FREQ;

   //clock & real-time clock
   reg                clk = 1;
   reg                rtc = 1;
   always #(clk_per/2) clk = ~clk;
   always #(rtc_per/2) rtc = ~rtc;

   //reset
   reg                rst = 0;

   // DUT inputs
   reg                valid;
   reg [`ADDR_W-1:0]  address;
   reg [`DATA_W-1:0]  wdata;
   reg [`DATA_W/8-1:0] wstrb;

   // DUT outputs
   wire                ready;
   wire [`DATA_W-1:0]  rdata;
   wire [`N_CORES-1:0] mtip;
   wire [`N_CORES-1:0] msip;

   integer             i = 0;
   reg [63:0]          timer_read;

   initial begin
      //assert reset
      #100 rst = 1;
      valid = 0;
      address = 0;
      wdata = 0;
      wstrb = 0;
      timer_read = 0;

      // deassert rst
      repeat (100) @(posedge clk) #1;
      rst = 0;
      //wait an arbitray (10) number of cycles
      repeat (10) @(posedge clk) #1;
      set_inputs(`MTIMECMP_BASE, 20, 15);
      wait_responce(timer_read[31:0]);
      set_inputs(`MTIMECMP_BASE+4, 0, 15);
      wait_responce(timer_read[31:0]);
      while (1) begin
         if (mtip > 0) begin
            $display("Machine Timer Interrupt is trigered.");
            set_inputs(`MSIP_BASE, 1, 15);
            wait_responce(timer_read[31:0]);
            get_time(timer_read);
            $display("Timer count: %0d.", timer_read);
            set_inputs(`MTIME_BASE, 0, 15);#1
            wait_responce(timer_read[31:0]);
            set_inputs(`MTIMECMP_BASE, rtc_per*100, 4'hF);
            wait_responce(timer_read[31:0]);
         end
         if (msip > 0) begin
            $display("Machine Software Interrupt is trigered.");
            set_inputs(`MSIP_BASE, 0, 15);#1
            wait_responce(timer_read[31:0]);
         end
         @(posedge clk) #1 i = i + clk_per;
         if (i > rtc_per*100) begin
            @(posedge clk) #1 $display("Testbench finished!");
            $finish;
         end
      end
   end

   iob_clint_top clint_top
     (
      .clk     (clk),
      .rst     (rst),

      .rtc     (rtc),

      .valid   (valid),
      .address (address),
      .wdata   (wdata),
      .wstrb   (wstrb),
      .rdata   (rdata),
      .ready   (ready),

      .mtip    (mtip),
      .msip    (msip)
      );

   task wait_responce;
      output [31:0] data_read;
      begin
         data_read = rdata;
         while(ready != 1) begin
           @ (posedge clk) data_read = rdata;
          end
      end
   endtask

   task set_inputs;
      input [31:0]  set_address;
      input [31:0]  set_data;
      input [3:0]   set_strb;
      begin
         valid = 1;
         address = set_address;
         wdata = set_data;
         wstrb = set_strb;
         @ (posedge clk) #1 valid = 0;
         wstrb = 0;
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
