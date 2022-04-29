//instantiate core in system

   //
   // CLINT
   //

   myclint clint
     (
      //CPU interface
      .clk     (clk),
      .rt_clk  (rtc),
      .reset   (reset),

      .valid   (slaves_req[`valid(`CLINT)]),
      .address (slaves_req[`address(`CLINT, 0)]),
      .wdata   (slaves_req[`wdata(`CLINT)]),
      .wstrb   (slaves_req[`wstrb(`CLINT)]),
      .rdata   (slaves_resp[`rdata(`CLINT)]),
      .ready   (slaves_resp[`ready(`CLINT)]),

      .mtip    (timerInterrupt),
      .msip    (softwareInterrupt)
      );
