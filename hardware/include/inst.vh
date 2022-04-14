//instantiate core in system

   //
   // CLINT
   //

   myclint clint
     (
      //CPU interface
      .clk     (clk),
      .rst     (reset),

      .valid   (slaves_req[`valid(`CLINT)]),
      .address (slaves_req[`address(`CLINT,`iob_clint_swreg_ADDR_W+2)-2]),
      .wdata   (slaves_req[`wdata(`CLINT)]),
      .wstrb   (slaves_req[`wstrb(`CLINT)]),
      .rdata   (slaves_resp[`rdata(`CLINT)]),
      .ready   (slaves_resp[`ready(`CLINT)]),

      .mtip    (timerInterrupt),
      .msip   (softwareInterrupt)
      );
