`timescale 1ns / 1ps

`include "system.vh"


//PHEADER

module system_tb;

  parameter realtime clk_per = 1s/`FREQ;

  //clock
  reg clk = 1;
  always #(clk_per/2) clk = ~clk;

  //reset
  reg reset = 0;

  // DUT inputs

  // DUT outputs

  initial begin
    //assert reset
    #100 reset = 1;

    // deassert rst
    repeat (100) @(posedge clk) #1;
    reset = 0;

    //wait an arbitray (10) number of cycles
    repeat (10) @(posedge clk) #1;



    while(1) begin
      // TO DO
    end
  end

  myclint clint
    (
     //CPU interface
     .clk     (clk),
     .rst     (reset),

     .valid   (valid),
     .address ({16{1'b0}, address[15:0]}),
     .wdata   (wdata),
     .wstrb   (strb),
     .rdata   (rdata),
     .ready   (ready),

     .mtip    (timerInterrupt),
     .msip    (softwareInterrupt)
     );


endmodule
