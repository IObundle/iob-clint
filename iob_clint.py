#!/usr/bin/env python3

import os

from iob_module import iob_module

# Submodules
from iob_utils import iob_utils
from iob_reg_re import iob_reg_re
from iob_counter import iob_counter


class iob_clint(iob_module):
    name = "iob_clint"
    version = "V0.10"
    flows = "sim emb"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "iob_s_port"},
                {"interface": "iob_s_portmap"},
                {"interface": "iob_wire"},
                iob_utils,
                {"interface": "clk_en_rst_s_s_portmap"},
                {"interface": "clk_en_rst_s_port"},
                iob_reg_re,
                iob_counter,
            ]
        )

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
                "name": "dummy",
                "descr": "Dummy registers to run register setup functions",
                "regs": [
                    {
                        "name": "DUMMY",
                        "type": "W",
                        "n_bits": 8,
                        "rst_val": 0,
                        "addr": 0x8000,
                        "log2n_items": 0,
                        "autoreg": False,
                        "descr": "Dummy Register",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
