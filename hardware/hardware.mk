#default baud rate for hardware
BAUD ?=115200

include $(ROOT_DIR)/config.mk

#add itself to MODULES list
HW_MODULES+=$(MYCLINT_NAME)

#HARDWARE PATHS
INC_DIR:=$(HW_DIR)/include
SRC_DIR:=$(HW_DIR)/src

#INCLUDES
INCLUDE+=$(incdir). $(incdir)$(INC_DIR)

#system
VSRC+=$(SRC_DIR)/myclint.v

#clean general hardware files
hw-clean: gen-clean
	@rm -f *.v *.hex *.bin $(SRC_DIR)/system.v $(TB_DIR)/system_tb.v *.vh

.PHONY: hw-clean
