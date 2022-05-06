#default baud rate for hardware
BAUD ?=115200

include $(CLINT_DIR)/config.mk

#add itself to MODULES list
HW_MODULES+=$(MYCLINT_NAME)

#HARDWARE PATHS
CLINT_INC_DIR:=$(CLINT_HW_DIR)/include
CLINT_SRC_DIR:=$(CLINT_HW_DIR)/src

#INCLUDES
INCLUDE+=$(incdir). $(incdir)$(CLINT_INC_DIR)

#system
#VSRC+=$(CLINT_SRC_DIR)/myclint.v
VSRC+=$(wildcard $(CLINT_SRC_DIR)/*.v)

#headers
VHDR+=$(wildcard $(CLINT_INC_DIR)/*.vh)
#VHDR+=clint_swreg_def.vh

clint_swreg_def.vh: $(CLINT_INC_DIR)/clint_swreg.vh
	cp $(CLINT_INC_DIR)/clint_swreg_def.vh ./clint_swreg_def.vh

#clean general hardware files
clint_hw_clean: clint_gen_clean
	@rm -f *.v *.hex *.bin $(CLINT_SRC_DIR)/system.v $(CLINT_TB_DIR)/system_tb.v *.vh

.PHONY: hw-clean
