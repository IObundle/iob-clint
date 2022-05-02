`timescale 1ns / 1ps

`define MSIP_BASE 0
`define MTIMECMP_BASE 16384
`define MTIME_BASE 49144

//PHEADER

module system_tb;

  parameter realtime clk_per = 1s/`FREQ;
  parameter realtime rtc_per = 1s/`RTC_FREQ;

  //clock & real-time clock
  reg clk = 1;
  reg rtc = 1;
  always #(clk_per/2) clk = ~clk;
  always #(rtc_per/2) rtc = ~rtc;

  //reset
  reg reset = 0;

  // DUT inputs
  wire                 valid;
  wire [`ADDR_W-1:0] address;
  wire [`DATA_W-1:0]   wdata;
  wire [`DATA_W/8-1:0]  strb;

  // DUT outputs
  wire               ready;
  wire [`DATA_W-1:0] rdata;
  wire [`N_CORES-1:0] mtip;
  wire [`N_CORES-1:0] msip;

  integer i = 0;
  wire [63:0] timer_read;

  initial begin
    //assert reset
    #100 reset = 1;

    // deassert rst
    repeat (100) @(posedge clk) #1;
    reset = 0;

    //wait an arbitray (10) number of cycles
    repeat (10) @(posedge clk) #1;

    while(1) begin
        if(mtip > 0)begin
            $display("Machine Timer Interrupt is trigere.n");
            set_inputs(MSIP_BASE, 1, 15);
        end
        if(msip > 0)begin
            printf("Machine Software Interrupt is trigered.");
            set_inputs(MSIP_BASE, 0, 15);
            timer_read = get_time();
            $display("Timer count: %ld", timer_read);
            set_inputs(MTIME_BASE, 0, 15);
            set_inputs(MTIMECMP_BASE, RTC_PERIOD*100, 15);
        end
        #(clk_per)
        i = i + clk_per;
        if (i>RTC_PERIOD*100)begin
          #(clk_per)
          $display("Testbench finished!");
          $finish;
        end
    end
  end

  myclint clint
    (
     //CPU interface
     .clk     (clk),
     .rt_clk  (rtc),
     .reset   (reset),

     .valid   (valid),
     .address (address),
     .wdata   (wdata),
     .wstrb   (strb),
     .rdata   (rdata),
     .ready   (ready),

     .mtip    (mtip),
     .msip    (msip)
     );

  task wait_responce;
   output [31:0] data_read;
   while(ready != 1)
      #(clk_per)
   data_read = rdata;
  endtask

  task set_inputs;
   input [31:0]  set_address;
   input [31:0]  set_data;
   input [3:0]   set_strb;
   output [31:0] data_read;
   valid = 1;
   address = set_address;
   wdata = set_data;
   wstrb = set_strb;
   #(clk_per)
   valid = 0;
   data_read = wait_responce();
  endtask

  task get_time;
   output [63:0] read_reg;

   read_time[31:0]  = set_inputs(MTIME_BASE, 0, 0);
   read_time[63:32] = set_inputs(MTIME_BASE+4, 0, 0);
  endtask

endmodule
