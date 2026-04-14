# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    CSR_IF = py_params_dict["csr_if"] if "csr_if" in py_params_dict else "iob"

    IF_DISPLAY_NAME = {
        "iob": "IOb",
        "axil": "AXI-Lite",
        "wb": "Wishbone",
    }

    # This CLINT module was developed to work in FPGAs and does not use a Real-time clock.
    # Real-time clock usually are 32.768 kHz.
    # One could be passed through the inputs of the module.
    # However, for it to work alterations must be made to the module.

    attributes_dict = {
        "generate_hw": True,
        "description": "IObundle's Core Local Interrupt Controller (CLINT).",
        "version": "0.1.0",
        #
        # Confs
        #
        "confs": [
            {
                "name": "DATA_W",
                "descr": "Data bus width",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "ADDR_W",
                "descr": "Address bus width",
                "type": "P",
                "val": "16",
                "min": "NA",
                "max": "NA",
            },
            {
                "name": "N_CORES",
                "descr": "Number of RISC-V Cores in the SoC",
                "type": "P",
                "val": "1",
                "min": "NA",
                "max": "8",
            },
            {
                "name": "FREQ",
                "descr": "Clock frequency",
                "type": "P",
                "val": "100000000",
            },
        ],
        #
        # Ports
        #
        "ports": [
            {
                "name": "clk_en_rst_s",
                "descr": "Clock, clock enable and reset",
                "signals": {
                    "type": "iob_clk",
                },
            },
            {
                "name": "rt_clk_i",
                "signals": [
                    {
                        "name": "rt_clk_i",
                        "descr": "Real Time clock input if available (usually 32.768 kHz)",
                        "width": "1",
                    },
                ],
            },
            {
                "name": "interrupt_o",
                "descr": "RISC-V interrupt interface",
                "signals": [
                    {
                        "name": "mtip_o",
                        "descr": "Machine timer interrupt pin",
                        "width": "N_CORES",
                    },
                    {
                        "name": "msip_o",
                        "descr": "Machine software interrupt (a.k.a inter-process-interrupt)",
                        "width": "N_CORES",
                    },
                ],
            },
            {
                "name": "timebase_o",
                "descr": "Timebase interface",
                "signals": [
                    {
                        "name": "mtime_o",
                        "descr": "Output from counter for CPU time CSRs. Current implementation increments at every 10us (ticks at 100kHz).",
                        "width": "64",
                        "isvar": True,
                    },
                ],
            },
            {
                "name": "csrs_cbus_s",
                "descr": f"Control and status interface, when selecting the {IF_DISPLAY_NAME[CSR_IF]} CSR interface.",
                "signals": {
                    "type": CSR_IF,
                    "ADDR_W": 16,
                    "DATA_W": 32,
                    "STRB_W": 4,
                },
            },
        ],
        #
        # Wires
        #
        "wires": [
            {
                "name": "internal_wires",
                "descr": "",
                "signals": [
                    {"name": "write", "width": 1},
                    {"name": "iob_rdata_reg", "width": "DATA_W", "isvar": True},
                    {"name": "mtimecmp", "width": "N_CORES*64", "isvar": True},
                    {"name": "mtip_reg", "width": "N_CORES", "isvar": True},
                    {"name": "msip_reg", "width": "N_CORES", "isvar": True},
                    {"name": "increment_timer", "width": 1},
                    {"name": "increment_timer_r", "width": 1},
                ],
            },
            # Counter IO signals
            {"name": "cnt_en", "signals": [{"name": "counter_e", "width": 1}]},
            {
                "name": "cnt_rst",
                "signals": [{"name": "counter_e_inverted", "width": 1}],
            },
            {"name": "cnt_o", "signals": [{"name": "counter", "width": "10"}]},
        ],
        #
        # Subblocks
        #
        "subblocks": [
            {  # Currently used for docs only
                "core_name": "iob_csrs",
                "instantiate": False,
                "instance_name": "csrs",
                "instance_description": "Control/Status Registers",
                "csrs": [
                    {
                        "name": "dummy_reg",
                        "descr": "Dummy register for demo",
                        "type": "NOAUTO",
                        "mode": "W",
                        "n_bits": 32,
                        "rst_val": 0,
                        "log2n_items": 14,
                        # "addr": 0x8000,
                    },
                ],
                "csr_if": "iob",
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    # 'control_if_m' port connected automatically
                },
            },
            {
                "core_name": "iob_counter",
                "instance_name": "iob_counter_0",
                "parameters": {
                    "DATA_W": "10",
                    "RST_VAL": "0",
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "counter_rst_i": "cnt_rst",
                    "counter_en_i": "cnt_en",
                    "data_o": "cnt_o",
                },
            },
        ],
        "sw_modules": [
            # Software modules
            {
                "core_name": "iob_linux_device_drivers",
                "compatible_str": "riscv,clint0",
                # Extra device tree properties specific to this peripheral
                # - Connect to system CPU 's inteerrupt controller, identified by 'CPU0_intc'
                # - Set symbolic 'control' name for the reg region
                "dts_extra_properties": r"""
       interrupts-extended = < &CPU0_intc 3
                               &CPU0_intc 7 >;
       reg-names = "control";
""",
            },
        ],
        #
        # Snippets
        #
        "snippets": [
            {
                "verilog_code": """
   // Local parameters
   localparam integer AddrSelWidth = (N_CORES == 1) ? 1 : $clog2(N_CORES);
   // register offset, base address are Backward Compatible With SiFive CLINT
   localparam integer MSIBase = 16'h0;
   localparam integer MTimeCMPBase = 16'h4000;
   localparam integer MTimeBase = 16'hbff8;

   integer j, k, c;

   // Logic and registers
   assign write       = |iob_wstrb_i;
   assign iob_rdata_o = iob_rdata_reg;
   // Address decoder
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         iob_rdata_reg <= {(DATA_W) {1'b0}};
      end else if (iob_addr_i < MTimeCMPBase) begin
         iob_rdata_reg <= {{(DATA_W - 1) {1'b0}}, msip_o[iob_addr_i[AddrSelWidth+1:2]]};
      end else if (iob_addr_i < MTimeBase) begin
         iob_rdata_reg <= mtimecmp[(iob_addr_i[AddrSelWidth+2:3]*64)+(iob_addr_i[2]+1)*DATA_W-1-:DATA_W];
      end else begin
         iob_rdata_reg <= mtime_o[(iob_addr_i[2]+1)*DATA_W-1-:DATA_W];
      end
   end

   // Increment timer every 10uS
   assign counter_e       = (counter < FREQ / 100000 - 1);
   assign increment_timer = (counter == FREQ / 100000 - 1);

   // Machine-level Timer Device (MTIMER)
   assign mtip_o            = mtip_reg;
   always @(*) begin
      if (arst_i)
         for (k = 0; k < N_CORES; k = k + 1) begin
            mtip_reg[k] = {1'b0};
         end
      else
         for (k = 0; k < N_CORES; k = k + 1) begin
            mtip_reg[k] = (mtime_o >= mtimecmp[k*64+:64]);
         end
   end

   // mtimecmp
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         for (c = 0; c < N_CORES; c = c + 1) begin
            mtimecmp[c*64+:64] <= {64{1'b1}};
         end
      end else if (iob_valid_i & write & (iob_addr_i >= MTimeCMPBase) & (iob_addr_i < (MTimeCMPBase + 8 * N_CORES))) begin
         mtimecmp[(iob_addr_i[AddrSelWidth+2:3]*64)+(iob_addr_i[2]+1)*DATA_W-1-:DATA_W] <= iob_wdata_i;
      end
   end

   // mtime_o
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         mtime_o <= {64{1'b0}};
      end else if (iob_valid_i & write & (iob_addr_i >= MTimeBase) & (iob_addr_i < (MTimeBase + 8))) begin
         mtime_o[(iob_addr_i[2]+1)*DATA_W-1-:DATA_W] <= iob_wdata_i;
      end else if (increment_timer_r) begin
         mtime_o <= mtime_o + 1'b1;
      end
   end

   // Machine-level Software Interrupt Device (MSWI) - msip_o
   assign msip_o = msip_reg;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         for (j = 0; j < N_CORES; j = j + 1) begin
            msip_reg[j] <= {1'b0};
         end
      end else if (iob_valid_i & write & (iob_addr_i >= MSIBase) & (iob_addr_i < (MSIBase + 4 * N_CORES))) begin
         msip_reg[iob_addr_i[AddrSelWidth+1:2]] <= iob_wdata_i[0];
      end
   end


   /*
  // Real Time Clock and Device Clock Synconizer, in order to minimize meta stability
  localparam STAGES = 2;

  wire rtc_value;
  reg  rtc_previous;
  reg [STAGES-1:0] rtc_states;

  wire increment_timer = rtc_value & ~rtc_previous; // detects rising edge
  assign rtc_value = rtc_states[STAGES-1];

  // Sync rt clk_i with clk_i
  always @(posedge clk_i, posedge arst_i) begin
     if (arst_i) begin
        rtc_states <= {STAGES{1'b0}};
     end else begin
        rtc_states <= {rtc_states[STAGES-2:0], rt_clk_i};
     end
  end

  always @(posedge clk_i, posedge arst_i) begin
     if (arst_i) begin
        rtc_previous <= 1'b0;
     end else begin
        rtc_previous <= rtc_value;
     end
  end
  */
""",
            },
        ],
    }
    #
    # Combs
    #
    attributes_dict["comb"] = {
        "code": """
    // Interface Registers

    // Read data valid
    iob_rvalid_o_en = ~write;
    iob_rvalid_o_nxt = iob_valid_i;

    // Ready signal, is always 1 since the read and write to the CLINT only take one clock cycle.
    iob_ready_o = 1'b1;

    increment_timer_r_nxt = increment_timer;

    counter_e_inverted = ~counter_e;
"""
    }

    return attributes_dict
