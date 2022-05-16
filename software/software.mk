include $(CLINT_DIR)/config.mk


CLINT_SW_INC_DIR = $(CLINT_SW_DIR)/include

#include
INCLUDE+=-I$(CLINT_SW_DIR) -I$(CLINT_SW_INC_DIR)

#headers
HDR+=$(CLINT_SW_DIR)/*.h $(CLINT_SW_INC_DIR)/*.h

#sources
SRC+=$(CLINT_SW_DIR)/myclint.c $(CLINT_SW_INC_DIR)/*.c
