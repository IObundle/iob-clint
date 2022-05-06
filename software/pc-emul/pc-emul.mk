ifeq ($(filter CLINT, $(SW_MODULES)),)

#add itself to MODULES list
SW_MODULES+=CLINT

#uart common parameters
include $(CLINT_DIR)/software/software.mk

# add pc-emul sources
SRC+=$(CLINT_SW_DIR)/pc-emul/clint_swreg_pc_emul.c

endif
