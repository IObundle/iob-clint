`timescale 1ns / 1ps
`include "iob_lib.vh"
`include "iob_clint_conf.vh"
`include "bsp.vh"

module iob_clint #(    
   `include "iob_clint_params.vh"
   ) (
   `include "iob_clint_io.vh"
   );

   // NEED to generate a real time clock -> input  rt_clk, // Real-time clock in (usually 32.768 kHz)
   localparam AddrSelWidth = (N_CORES == 1) ? 1 : $clog2(N_CORES);
   // register offset, base address are Backward Compatible With SiFive CLINT
   localparam [15:0] MSIP_BASE     = 16'h0;
   localparam [15:0] MTIMECMP_BASE = 16'h4000;
   localparam [15:0] MTIME_BASE    = 16'hbff8;

   wire                     write = |iob_wstrb_i;

   reg [DATA_W-1:0] iob_rdata_reg;
   assign iob_rdata_o = iob_rdata_reg;
   // Address decoder
   always @ ( posedge clk_i, posedge arst_i ) begin
      if (arst_i) begin
         iob_rdata_reg <= {(DATA_W){1'b0}};
      end else if (iob_addr_i < MTIMECMP_BASE) begin
         iob_rdata_reg <= {{(DATA_W-1){1'b0}}, msip[iob_addr_i[AddrSelWidth+1:2]]};
      end else if (iob_addr_i < MTIME_BASE) begin
         iob_rdata_reg <= mtimecmp[iob_addr_i[AddrSelWidth+2:3]][(iob_addr_i[2]+1)*DATA_W-1 -: DATA_W];
      end else begin
         iob_rdata_reg <= mtime[(iob_addr_i[2]+1)*DATA_W-1 -: DATA_W];
      end
   end

   // Read data valid
   reg iob_rvalid_reg;
   assign iob_rvalid_o = iob_rvalid_reg;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
        iob_rvalid_reg <= 1'b0;
      end else if (~write) begin
        iob_rvalid_reg <= iob_avalid_i;
      end
   end
   // Ready signal
   assign iob_ready_o = 1'b1;

   reg	[9:0]	counter;
   always @(posedge clk_i, posedge arst_i)
      if (arst_i) begin
        counter <= 1'b0;
      end else if (counter < `FREQ/100000-1)
   		  counter <= counter + 1'b1;
     	else
     		counter <= 0;

   reg increment_timer;
   always @(posedge clk_i, posedge arst_i)
      if (arst_i) begin
        increment_timer <= 1'b0;
      end else increment_timer <= (counter == `FREQ/100000-1);


   // Real Time Clock and Device Clock Synconizer, in order to minimize meta stability
   //localparam STAGES = 2;

   //wire rtc_value;
   //reg  rtc_previous;
   //reg [STAGES-1:0] rtc_states;

   //wire increment_timer = rtc_value & ~rtc_previous; // detects rising edge
   //assign rtc_value = rtc_states[STAGES-1];

   //// Sync rt clk_i with clk_i
   //always @(posedge clk_i, posedge arst_i) begin
   //   if (arst_i) begin
   //      rtc_states <= {STAGES{1'b0}};
   //   end else begin
   //      rtc_states <= {rtc_states[STAGES-2:0], rt_clk};
   //   end
   //end

   //always @(posedge clk_i, posedge arst_i) begin
   //   if (arst_i) begin
   //      rtc_previous <= 1'b0;
   //   end else begin
   //      rtc_previous <= rtc_value;
   //   end
   //end

   // Machine-level Timer Device (MTIMER)
   reg [63:0]        mtimecmp [N_CORES-1:0];
   reg [N_CORES-1:0] mtip_reg;
   assign mtip = mtip_reg;
   integer           k, c;
   always @( * ) begin
      if (arst_i)
        for (k=0; k < N_CORES; k=k+1) begin
           mtip_reg[k] = {1'b0};
        end
      else
        for (k=0; k < N_CORES; k=k+1) begin
           mtip_reg[k] = (mtime >= mtimecmp[k][63:0]);
        end
   end

   // mtimecmp
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         for (c=0; c < N_CORES; c=c+1) begin
            mtimecmp[c] <= {64{1'b1}};
         end
      end else if (iob_avalid_i && write && (iob_addr_i >= MTIMECMP_BASE) && (iob_addr_i < (MTIMECMP_BASE+8*N_CORES))) begin
         mtimecmp[iob_addr_i[AddrSelWidth+2:3]][(iob_addr_i[2]+1)*DATA_W-1 -:DATA_W] <= iob_wdata_i;
      end
   end

   // mtime
   reg [63:0]        mtime;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         mtime <= {64{1'b0}};
      end else if (iob_avalid_i && write && (iob_addr_i >= MTIME_BASE) && (iob_addr_i < (MTIME_BASE+8))) begin
         mtime[(iob_addr_i[2]+1)*DATA_W-1 -: DATA_W] <= iob_wdata_i;
      end else if (increment_timer) begin
         mtime <= mtime + 1'b1;
      end
   end

   // Machine-level Software Interrupt Device (MSWI) - msip
   reg [N_CORES-1:0] msip_reg;
   assign msip = msip_reg;
   integer           j;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         for (j=0; j < N_CORES; j=j+1) begin
            msip_reg[j] <= {1'b0};
         end
      end else if (iob_avalid_i && write && (iob_addr_i >= MSIP_BASE) && (iob_addr_i < (MSIP_BASE+4*N_CORES))) begin
         msip_reg[iob_addr_i[AddrSelWidth+1:2]] <= iob_wdata_i[0];
      end
   end

endmodule
