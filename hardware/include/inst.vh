//instantiate core in system

   //
   // CLINT
   //

   iob_clint clint
     (
      .clk     (clk),
      .rst     (cpu_reset),

      .rt_clk  (1'b0),

      .valid   (slaves_req[`valid(`CLINT)]),
      .address (slaves_req[`address(`CLINT, `iob_clint_ADDR_W)]),
      .wdata   (slaves_req[`wdata(`CLINT)]),
      .wstrb   (slaves_req[`wstrb(`CLINT)]),
      .rdata   (slaves_resp[`rdata(`CLINT)]),
      .ready   (slaves_resp[`ready(`CLINT)]),

      .mtip    (timerInterrupt),
      .msip    (softwareInterrupt)
      );
