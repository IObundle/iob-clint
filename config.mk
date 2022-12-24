######################################################################
#
# CLINT Configuration File
#
######################################################################

SHELL = bash

TOP_MODULE:=iob_clint

#
# PRIMARY PARAMETERS: CAN BE CHANGED BY USERS OR OVERRIDEN BY ENV VARS
#

#CPU ARCHITECTURE
DATA_W ?=32
ADDR_W ?=16
N_CORES ?=1

#CLINT DIRECTORY ON REMOTE MACHINES
REMOTE_CLINT_DIR ?=sandbox/iob_clint

#SIMULATION
#default simulator running locally or remotely
#check the respective Makefile in hardware/simulation/$(SIMULATOR) for specific settings
SIMULATOR ?=icarus

####################################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE BELOW THIS POINT
####################################################################

#sw paths
CLINT_SW_DIR=$(CLINT_DIR)/software

#hw paths
CLINT_HW_DIR=$(CLINT_DIR)/hardware
CLINT_SIM_DIR=$(CLINT_HW_DIR)/simulation/$(SIMULATOR)


#default baud and system clock freq
BAUD ?= 5000000
FREQ ?= 100000000
DEFINE+=$(defmacro)FREQ=$(FREQ)

#RULES
clint_gen_clean:
	@rm -f *# *~

.PHONY: gen-clean
