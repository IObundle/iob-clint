`timescale 1ns / 1ps

module iob_clint
  #(
    parameter ADDR_W  = 16,
    parameter DATA_W  = 32,
    parameter N_CORES = 1
    )
   (
    input                    clk,
    input                    rst,

    input                    rt_clk,  // Real-time clock in (usually 32.768 kHz)

    input                    valid,
    input [ADDR_W-1:0]       address,
    input [DATA_W-1:0]       wdata,
    input [DATA_W/8-1:0]     wstrb,
    output reg [DATA_W-1:0]  rdata,
    output reg               ready,

    output reg [N_CORES-1:0] mtip,    // Machine timer interrupt pin
    output reg [N_CORES-1:0] msip     // Machine software interrupt (a.k.a inter-process-interrupt)
    );

   // NEED to generate a real time clock -> input  rt_clk, // Real-time clock in (usually 32.768 kHz)
   localparam AddrSelWidth = (N_CORES == 1) ? 1 : $clog2(N_CORES);
   // register offset, base address are Backward Compatible With SiFive CLINT
   localparam [15:0] MSIP_BASE     = 16'h0;
   localparam [15:0] MTIMECMP_BASE = 16'h4000;
   localparam [15:0] MTIME_BASE    = 16'hbff8;

   wire                     write = |wstrb;

   // Address decoder
   always @ ( address ) begin
      if (address < MTIMECMP_BASE) begin
         rdata = {{(DATA_W-1){1'b0}}, msip[address[AddrSelWidth+1:2]]};
      end else if (address < MTIME_BASE) begin
         rdata = mtimecmp[address[AddrSelWidth+2:3]][(address[2]+1)*DATA_W-1 -: DATA_W];
      end else begin
         rdata = mtime[(address[2]+1)*DATA_W-1 -: DATA_W];
      end
   end

   // ready
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         ready <= 1'b0;
      end else begin
         ready <= valid;
      end
   end

   // Real Time Clock and Device Clock Synconizer, in order to minimize meta stability
   localparam STAGES = 2;

   wire rtc_value;
   reg  rtc_previous;
   reg [STAGES-1:0] rtc_states;

   wire increment_timer = rtc_value & ~rtc_previous; // detects rising edge
   assign rtc_value = rtc_states[STAGES-1];

   // Sync rt clk with clk
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         rtc_states <= {STAGES{1'b0}};
      end else begin
         rtc_states <= {rtc_states[STAGES-2:0], rt_clk};
      end
   end

   always @(posedge clk, posedge rst) begin
      if (rst) begin
         rtc_previous <= 1'b0;
      end else begin
         rtc_previous <= rtc_value;
      end
   end

   // Machine-level Timer Device (MTIMER)
   reg [63:0]        mtimecmp [N_CORES-1:0];
   integer           k, c;
   always @* begin
      if (rst)
        for (k=0; k < N_CORES; k=k+1) begin
           mtip[k] = {1'b0};
        end
      else
        for (k=0; k < N_CORES; k=k+1) begin
           mtip[k] = (mtime >= mtimecmp[k][63:0]);
        end
   end

   // mtimecmp
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         for (c=0; c < N_CORES; c=c+1) begin
            mtimecmp[c] <= {64{1'b1}};
         end
      end else if (valid && write && (address >= MTIMECMP_BASE) && (address < (MTIMECMP_BASE+8*N_CORES))) begin
         mtimecmp[address[AddrSelWidth+2:3]][(address[2]+1)*DATA_W-1 -:DATA_W] <= wdata;
      end
   end

   // mtime
   reg [63:0]        mtime;
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         mtime <= {64{1'b0}};
      end else if (valid && write && (address >= MTIME_BASE) && (address < (MTIME_BASE+8))) begin
         mtime[(address[2]+1)*DATA_W-1 -: DATA_W] <= wdata;
      end else if (increment_timer) begin
         mtime <= mtime + 1'b1;
      end
   end

   // Machine-level Software Interrupt Device (MSWI) - msip
   integer           j;
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         for (j=0; j < N_CORES; j=j+1) begin
            msip[j] <= {1'b0};
         end
      end else if (valid && write && (address >= MSIP_BASE) && (address < (MSIP_BASE+4*N_CORES))) begin
         msip[address[AddrSelWidth+1:2]] <= wdata[0];
      end
   end

endmodule
