ifeq ($(filter CLINT, $(SW_MODULES)),)

#add itself to MODULES list
SW_MODULES+=CLINT

include $(CLINT_DIR)/software/software.mk

#embeded sources
SRC+=$(CLINT_SW_DIR)/embedded/iob_clint.c

endif
