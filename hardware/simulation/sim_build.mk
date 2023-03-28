# SOURCES
VTOP:=iob_clint_tb
ifeq ($(SIMULATOR),verilator)
# verilator top module
VTOP:=iob_clint_sim_wrapper
endif

#tests
TEST_LIST+=test1
test1:
	make run SIMULATOR=$(SIMULATOR)
