`timescale 1ns / 1ps

//PHEADER

module system_tb;

  parameter realtime clk_per = 1s/`FREQ;

  //clock
  reg clk = 1;
  always #(clk_per/2) clk = ~clk;

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

  initial begin
    //assert reset
    #100 reset = 1;

    // deassert rst
    repeat (100) @(posedge clk) #1;
    reset = 0;

    //wait an arbitray (10) number of cycles
    repeat (10) @(posedge clk) #1;



    //while(1) begin
      // TO DO
    //end
    $display("Testbench finished!");
    $finish;
  end

  myclint clint
    (
     //CPU interface
     .clk     (clk),
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


endmodule
