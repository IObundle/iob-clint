/*########
  MyCLINT
  #######*/

module myclint #(
    parameter ADDR_W  = 32,
    parameter DATA_W  = 32,
    parameter N_CORES = 1 // Number of cores, therefore the number of timecmp registers and timer interrupts
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

  // NEED to generate a real time clock -> input  rt_clk, // Real-time clock in (usually 32.768 kHz)

  /* Machine-level Timer Device (MTIMER) */
  wire [64:0]         mtime;
  wire [N_CORES*64:0] mtimecmp;
  wire                write;

  reg  [64:0]         mtime_reg;
  reg  [N_CORES*64:0] mtimecmp_reg;

  assign write = valid && (wstrb != {4'h0});

  integer k;
  always @ ( posedge clk ) begin
    for (k=0; k<N_CORES; k=k+1){
      mtip[k] = (mtime_reg >= mtimecmp_reg[(k+1)*64 -:64]);
    }
  end
  // write
  always @ ( posedge clk ) begin
    if (reset) begin
      mtime_reg    <= {64{1'b0}};
      mtimecmp_reg <= {64{1'b1}};
    end else if (write) begin
      mtimecmp_reg <= wdata;
    end else begin
      mtimecmp_reg <= mtimecmp_reg;
      mtime_reg <= mtime_reg + 1;
    end
  end
  // read
  always @ ( posedge clk ) begin
    if (valid) begin
      rdata <= {32{1'b0}};
      ready <= {1'b1};
    end else begin
      ready <= {1'b0};
    end
  end

  /* Machine-level Software Interrupt Device (MSWI) */
  reg [N_CORES*32:0] msip_reg;

  integer i;
  always @ ( posedge clk ) begin
    for (i=0; i<N_CORES; i=i+1){
      msip[i] = msip_reg[i*32];
    }
  end
  // write
  always @ ( posedge clk ) begin
    if (reset) begin
      msip_reg <= {32{1'b0}};
    end else if (address==`MSWI_BASE) begin
      if (write)
        msip_reg <= {31{1'b0}, wdata[0]};
      else
        rdata <= {31{1'b0}, msip_reg[0]}
    end else begin
      msip_reg <= msip_reg;
    end
  end
endmodule
