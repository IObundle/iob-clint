ROOT_DIR:=.
include ./config.mk


#
# SIMULATE RTL
#

sim-build: fw-build
	make -C $(SIM_DIR) build

sim-run: sim-build
	make -C $(SIM_DIR) run

sim-clean: fw-clean
	make -C $(SIM_DIR) clean

sim-test:
	make -C $(SIM_DIR) test

#
# COMPILE DOCUMENTS
#
doc-build:
	make -C $(DOC_DIR) $(DOC).pdf

doc-clean:
	make -C $(DOC_DIR) clean

doc-test:
	make -C $(DOC_DIR) test

doc-test-clean:
	make -C $(DOC_DIR) test-clean




.PHONY: sim-build sim-run sim-clean sim-test sim-test-clean\
	doc-build doc-clean doc-test doc-test-clean
