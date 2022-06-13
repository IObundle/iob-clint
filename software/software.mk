include $(CLINT_DIR)/config.mk

#include
INCLUDE+=-I$(CLINT_SW_DIR)

#headers
HDR+=$(CLINT_SW_DIR)/*.h

#sources
SRC+=$(CLINT_SW_DIR)/iob_clint_timer.c
