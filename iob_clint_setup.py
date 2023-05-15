#!/usr/bin/env python3

import os, sys

sys.path.insert(0, os.getcwd() + "/submodules/LIB/scripts")
import setup

name = "iob_clint"
version = "V0.10"
flows = "sim emb"
if setup.is_top_module(sys.modules[__name__]):
    setup_dir = os.path.dirname(__file__)
    build_dir = f"../{name}_{version}"
submodules = {
    "hw_setup": {
        "headers": [
            "iob_s_port",
            "iob_s_portmap",
            "iob_wire",
            "iob_lib.vh",
            "iob_utils.vh",
            "iob_clkenrst_portmap.vh",
            "iob_clkenrst_port.vh",
        ],
        "modules": [
            "iob_reg_re",
            "iob_counter",
        ],
    },
}

confs = [
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

ios = [
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
                "descr": "System reset, asynchronous and active high",
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

regs = []
blocks = []


# Main function to setup this core and its components
def main():
    setup.setup(sys.modules[__name__])


if __name__ == "__main__":
    main()
