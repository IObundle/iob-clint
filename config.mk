######################################################################
#
# MyCLINT Configuration File
#
######################################################################

MyCLINT_NAME:=MyCLINT

#
# PRIMARY PARAMETERS: CAN BE CHANGED BY USERS OR OVERRIDEN BY ENV VARS
#

#CPU ARCHITECTURE
DATA_W := 32
ADDR_W := 32

#ROOT DIRECTORY ON REMOTE MACHINES
REMOTE_ROOT_DIR ?=sandbox/myclint

#SIMULATION
#default simulator running locally or remotely
#check the respective Makefile in hardware/simulation/$(SIMULATOR) for specific settings
SIMULATOR ?=icarus

#DOCUMENTATION
#default document to compile
DOC ?= pb

####################################################################
# DERIVED FROM PRIMARY PARAMETERS: DO NOT CHANGE BELOW THIS POINT
####################################################################

#sw paths
SW_DIR:=$(ROOT_DIR)/software

#hw paths
HW_DIR=$(ROOT_DIR)/hardware
SIM_DIR=$(HW_DIR)/simulation/$(SIMULATOR)

#doc paths
DOC_DIR=$(ROOT_DIR)/document/$(DOC)

#define macros
DEFINE+=$(defmacro)DATA_W=$(DATA_W)
DEFINE+=$(defmacro)ADDR_W=$(ADDR_W)
DEFINE+=$(defmacro)N_CORES=$(N_CORES) #peripherals

#default baud and system clock freq
BAUD=5000000
FREQ=100000000

SHELL = /bin/bash

#RULES
gen-clean:
	@rm -f *# *~

.PHONY: gen-clean
