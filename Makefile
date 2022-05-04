CLINT_DIR:=.
include ./config.mk


#
# SIMULATE RTL
#

sim-build:
	make -C $(CLINT_SIM_DIR) build

sim-run: sim-build
	make -C $(CLINT_SIM_DIR) run

sim-clean:
	make -C $(CLINT_SIM_DIR) clean

.PHONY: sim-build sim-run sim-clean
