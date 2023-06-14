#!/usr/bin/env python3

import os
import sys

from iob_module import iob_module
from setup import setup

# Submodules
from iob_lib import iob_lib
from iob_utils import iob_utils
from iob_clkenrst_portmap import iob_clkenrst_portmap
from iob_clkenrst_port import iob_clkenrst_port
from iob_reg_re import iob_reg_re
from iob_counter import iob_counter


class iob_clint(iob_module):
    name = "iob_clint"
    version = "V0.10"
    flows = "sim emb"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        # Hardware headers & modules
        iob_module.generate("iob_s_port")
        iob_module.generate("iob_s_portmap")
        iob_module.generate("iob_wire")
        iob_lib.setup()
        iob_utils.setup()
        iob_clkenrst_portmap.setup()
        iob_clkenrst_port.setup()
        iob_reg_re.setup()
        iob_counter.setup()

        cls._setup_confs()
        cls._setup_ios()
        cls._setup_regs()
        cls._setup_block_groups()

        # Verilog modules instances
        # TODO

        # Copy sources of this module to the build directory
        super()._run_setup()

        # Setup core using LIB function
        setup(cls)

    @classmethod
    def _setup_confs(cls):
        super()._setup_confs(
            [
                # Macros
                # Parameters
                {
                    "name": "DATA_W",
                    "type": "P",
                    "val": "32",
                    "min": "NA",
                    "max": "NA",
                    "descr": "Data bus width",
                },
                {
                    "name": "ADDR_W",
                    "type": "P",
                    "val": "16",
                    "min": "NA",
                    "max": "NA",
                    "descr": "Address bus width",
                },
                {
                    "name": "N_CORES",
                    "type": "P",
                    "val": "1",
                    "min": "NA",
                    "max": "8",
                    "descr": "Number of RISC-V Cores in the SoC",
                },
            ]
        )

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "general",
                "descr": "GENERAL INTERFACE SIGNALS",
                "ports": [
                    {
                        "name": "clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock input",
                    },
                    {
                        "name": "arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System reset, asynchronous and active high",
                    },
                    {
                        "name": "cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Clock enable signal",
                    },
                ],
            },
            {
                "name": "clint_io",
                "descr": "CLINT specific IO.",
                "ports": [
                    # {'name':'interrupt', 'type':'O', 'n_bits':'1', 'descr':'be done'},
                    {
                        "name": "rt_clk",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Real Time clock input if available (usually 32.768 kHz)",
                    },
                    {
                        "name": "mtip",
                        "type": "O",
                        "n_bits": "N_CORES",
                        "descr": "Machine timer interrupt pin",
                    },
                    {
                        "name": "msip",
                        "type": "O",
                        "n_bits": "N_CORES",
                        "descr": "Machine software interrupt (a.k.a inter-process-interrupt)",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.regs += [
            {
                "name": "clint_regs",
                "descr": "CLINT timer and software interrupt registers.",
                "regs": [
                    {
                        "name": "MSI",
                        "type": "R",
                        "n_bits": 32,
                        "rst_val": 0,
                        "addr": 0,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "Machine Software Interrupts.",
                    },
                    {
                        "name": "MTIMECMP",
                        "type": "R",
                        "n_bits": 64,
                        "rst_val": 0,
                        "addr": 0x4000,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "Machine Timer compare register.",
                    },
                    {
                        "name": "MTIME",
                        "type": "R",
                        "n_bits": 64,
                        "rst_val": 0,
                        "addr": 0xBFF8,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "Machine Time register.",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
