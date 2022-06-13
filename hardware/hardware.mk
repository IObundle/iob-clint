include $(CLINT_DIR)/config.mk

#add itself to MODULES list
HW_MODULES+=CLINT

#HARDWARE PATHS
CLINT_INC_DIR:=$(CLINT_HW_DIR)/include
CLINT_SRC_DIR:=$(CLINT_HW_DIR)/src

#INCLUDES
INCLUDE+=$(incdir). $(incdir)$(CLINT_INC_DIR)

#headers
VHDR+=$(wildcard $(CLINT_INC_DIR)/*.vh)
#VHDR+=iob_clint_swreg_def.vh

#sources
VSRC+=$(wildcard $(CLINT_SRC_DIR)/*.v)

iob_clint_swreg_def.vh: $(CLINT_INC_DIR)/iob_clint_swreg.vh
	cp $(CLINT_INC_DIR)/iob_clint_swreg_def.vh ./iob_clint_swreg_def.vh

#clean general hardware files
clint_hw_clean: clint_gen_clean
	@rm -f *.vh

.PHONY: hw-clean
