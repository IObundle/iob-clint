# MyCLINT
RISC-V Core Local Interrupt Controller (CLINT) written in Verilog. The initial focus is for it to work as a IOb-SoC-VexRiscv peripheral.

## How to build the core w/ python-setup
The python-setup workflow allows to automatically generate verilog components used by the projects core Verilog. It allows to create bus interfaces with ease and use existing Verilog modules. To use python-setup the project should have a *project*_setup.py file in the root directory. The main commands to use the python-setup workflow are:
- `make setup`: creates a build directory in the projects parent directory.
- `make clean`: removes the build directory.

An example of cleaning a previous build, creating a new build and simulating the project is:
- `make clean && make setup && make -C ../iob_clint_V0.10 sim-run`


## Simulation
To simulate the CLINT unit the user can use both "icarus verilog" and "verilator". Simply run:
```
make sim-run
# or
make sim-run SIMULATOR=verilator
```
Before running new simulation do not forget to run `make sim-clean`.

## Register Map
This clint unit follows the RISC-V Specification.
| **Register** | **Base Address** | **Width** | **Privilege Level** |             **Functionality**            |
|:---------------:|:----------------:|:---------:|:-------------------:|:----------------------------------------:|
|       MSIP      |     xxxx0000     | n*4 Bytes |       Machine       | Inter-processor (or software) interrupts |
|     MTIMECMP    |     xxxx4000     | n*8 Bytes |       Machine       |               Timer events               |
|      MTIME      |     xxxxbff8     |  8 Bytes  |       Machine       |          Fixed-frequency counter         |

*note: n correspond to the number of HART's (hardware threads) on a system. The system has been tested to work with 1 HART.
## Machine-level Timer Device (MTIMER)
The MTIMER hardware component corresponds to the MTIME and MTIMECMP registers.
On reset the MTIME register is set to have all bits at 0 and the MTIMECMP register has all bits at 1.
If the value in MTIME is greater than the value stored in MTIMECMP than the Machine Timer Interrupt is enabled and the clint mtip output is set to high.

## Machine-level Software Interrupt Device (MSWI)
The MSWI hardware component corresponds to the MSIP register.
On reset the MSIP register is set to 0.
The each Machine Software Interrupt is wired to the corresponding MSIP register. In accordance the clint msip output is set to high if the less significant bit of the corresponding MSIP registers is set to 1. In the MSIP register all bits except the less significant one should be hardwired to 0.

## Supervisor-level Software Interrupt Device (SSWI)
(TO DO)

## References
- RISC-V Advanced Core Local Interruptor Specification -> https://github.com/riscv/riscv-aclint/blob/main/riscv-aclint.adoc
- IOb-SoC -> https://github.com/IObundle/iob-soc
- CVA6 CLINT -> https://github.com/openhwgroup/cva6/tree/master/corev_apu/clint
- Bare Metal Interrupt Software -> https://github.com/five-embeddev/riscv-scratchpad/tree/master/baremetal-startup-c/src
