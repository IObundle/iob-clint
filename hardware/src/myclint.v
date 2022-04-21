/*########
  MyCLINT
  #######*/
`timescale 1ns / 1ps


module myclint #(
    parameter ADDR_W  = 32,
    parameter DATA_W  = 32,
    parameter N_CORES = 1
) (
    input                 clk,
    input                 reset,
    input                 valid,
    input  [ADDR_W-1:0]   address,
    input  [DATA_W-1:0]   wdata,
    input  [DATA_W/8-1:0] wstrb,
    output [DATA_W-1:0]   rdata,
    output                ready,
    output [N_CORES-1:0]  mtip, // Machine timer interrupt pin
    output [N_CORES-1:0]  msip  // Machine software interrupt (a.k.a inter-process-interrupt)
);

`ifdef VCD
  initial begin
     $dumpfile("system.vcd");
     $dumpvars();
  end
`endif

  // NEED to generate a real time clock -> input  rt_clk, // Real-time clock in (usually 32.768 kHz)
  localparam AddrSelWidth = (N_CORES == 1) ? 1 : $clog2(N_CORES);
  // register offset, base address are Backward Compatible With SiFive CLINT
  localparam [15:0] MSIP_BASE     = 16'h0;
  localparam [15:0] MTIMECMP_BASE = 16'h4000;
  localparam [15:0] MTIME_BASE    = 16'hbff8;

  wire   write;
  assign write = (wstrb == {4'hF});

  reg [DATA_W-1:0] rdata_reg;
  assign rdata = rdata_reg;

  /* Machine-level Timer Device (MTIMER) */
  reg  [63:0]        mtime_reg;
  reg  [63:0]        mtimecmp_reg [N_CORES-1:0];
  reg  [N_CORES-1:0] mtip_reg;

  assign mtip = mtip_reg;

  integer k, c;
  always @ ( posedge clk ) begin
    if (reset)
      for (k=0; k<N_CORES; k=k+1) begin
        mtip_reg[k] = {1'b0};
      end
    else
      for (k=0; k<N_CORES; k=k+1) begin
        mtip_reg[k] = (mtime_reg >= mtimecmp_reg[k][63:0]);
      end
  end
  // mtimecmp
  always @ ( posedge clk ) begin
    if (reset) begin
      for (c=0; c<N_CORES; c=c+1) begin
        mtimecmp_reg[c] <= {64{1'b1}};
      end
    end else if (valid && (address[15:0]>=MTIME_BASE) && (address[15:0]<MTIME_BASE+8)) begin
      if (write)
        mtimecmp_reg[0][31 -:DATA_W] <= wdata;
      else
        rdata_reg <= mtimecmp_reg[0][31 -: DATA_W];
    end
  end
  // mtime
  always @ ( posedge clk ) begin
    mtime_reg = mtime_reg + 1;
    if (reset) begin
      mtime_reg = {64{1'b0}};
    end else if (valid && (address[15:0]==MTIMECMP_BASE) && (address[15:0]<MTIMECMP_BASE+8*N_CORES)) begin
      if (write)
        mtime_reg[(address[AddrSelWidth+1:2]+1)*DATA_W -: DATA_W] = wdata;
      else
        rdata_reg <= mtime_reg[(address[AddrSelWidth+1:2]+1)*DATA_W -: DATA_W];
    end
  end

  /* Machine-level Software Interrupt Device (MSWI) */
  reg [N_CORES-1:0] msip_reg;
  assign msip = msip_reg;

  integer j;
  // msip
  always @ ( posedge clk ) begin
    if (reset) begin
      for (j=0; j<N_CORES; j=j+1) begin
        msip_reg[j] <= {1'b0};
      end
    end else if (valid && (address[15:0]>=MSIP_BASE) && (address[15:0]<MSIP_BASE+4*N_CORES)) begin
      if (write) begin
        msip_reg[address[AddrSelWidth+1:2]] <= wdata[0];
      end
      else begin
        rdata_reg <= {{31{1'b0}}, msip_reg[address[AddrSelWidth+1:2]]};
      end
    end
  end
endmodule
