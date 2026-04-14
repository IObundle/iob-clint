# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT

CORE := iob_clint

SIMULATOR ?= icarus
SYNTHESIZER ?= yosys
LINTER ?= spyglass
BOARD ?= iob_cyclonev_gt_dk
CSR_IF ?= iob

#
# Fill PY_PARAMS if not defined
ifeq ($(PY_PARAMS),)
ifneq ($(CSR_IF),)
PY_PARAMS:=$(PY_PARAMS):csr_if=$(CSR_IF)
endif
# Remove first char (:) from PY_PARAMS
PY_PARAMS:=$(shell echo $(PY_PARAMS) | cut -c2-)
endif # ifndef PY_PARAMS

BUILD_DIR ?= $(shell nix-shell --run "py2hwsw $(CORE) print_build_dir --py_params '$(PY_PARAMS)'")

VERSION ?=$(shell cat $(CORE).py | grep version | cut -d '"' -f 4)

ifneq ($(DEBUG),)
EXTRA_ARGS +=--debug_level $(DEBUG)
endif

setup:
	nix-shell --run "py2hwsw $(CORE) setup --no_verilog_lint --py_params '$(PY_PARAMS)' $(EXTRA_ARGS)"

pc-emul-run:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/ pc-emul-run"

pc-emul-test:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/ pc-emul-run"

sim-run:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/ sim-run SIMULATOR=$(SIMULATOR)"

sim-test:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/ sim-run SIMULATOR=icarus"

fpga-build:
	nix-shell --run "make clean setup"
	make -C ../$(CORE)_V$(VERSION)/ fpga-build BOARD=$(BOARD)

fpga-run:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/ fpga-sw-build BOARD=$(BOARD)"
	make -C ../$(CORE)_V$(VERSION)/ fpga-run BOARD=$(BOARD)

fpga-test:
	make clean setup fpga-build BOARD=iob_aes_ku040_db_g

syn-build: clean
	nix-shell --run "make setup && make -C ../$(CORE)_V$(VERSION)/ syn-build SYNTHESIZER=$(SYNTHESIZER)"

lint-run: clean
	nix-shell --run "make setup && make -C ../$(CORE)_V$(VERSION)/ lint-run LINTER=$(LINTER)"

doc-build:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/ doc-build"

doc-test:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/ doc-test"


test-all: pc-emul-test sim-test fpga-test syn-build lint-run doc-build doc-test



.PHONY: setup sim-test fpga-test doc-test test-all


clean:
	nix-shell --run "py2hwsw $(CORE) clean --build_dir '$(BUILD_DIR)'"
	@rm -rf ../*.summary ../*.rpt fusesoc_exports *.core
	@find . -name \*~ -delete

# Remove all __pycache__ folders with python bytecode
python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune

.PHONY: clean python-cache-clean

# Tester

tester-sim-run:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/tester/ sim-run SIMULATOR=$(SIMULATOR)"

tester-fpga-run:
	nix-shell --run "make clean setup && make -C ../$(CORE)_V$(VERSION)/tester/ fpga-sw-build BOARD=$(BOARD)"
	make -C ../$(CORE)_V$(VERSION)/tester/ fpga-run BOARD=$(BOARD)

.PHONY: tester-sim-run tester-fpga-run

# FuseSoC

fusesoc-export: clean setup
	nix-shell --run "py2hwsw $(CORE) export_fusesoc --build_dir '$(BUILD_DIR)' --py_params '$(PY_PARAMS)'"

.PHONY: fusesoc-export

define MULTILINE_TEXT
provider:
  name: url
  url: https://github.com/IObundle/iob-clint/releases/latest/download/$(CORE)_V$(VERSION).tar.gz
  filetype: tar
endef

# Generate standalone FuseSoC .core file that references pre-built sources from the GitHub releases page.
export MULTILINE_TEXT
fusesoc-core-file: fusesoc-export
	cp fusesoc_exports/$(CORE).core .
	# Append provider remote url to .core file
	printf "\n%s\n" "$$MULTILINE_TEXT" >> $(CORE).core
	echo "Generated independent $(CORE).core file."

.PHONY: fusesoc-core-file

# Release Artifacts

release-artifacts:
	make fusesoc-export
	tar -czf $(CORE)_V$(VERSION).tar.gz -C ./fusesoc_exports .

.PHONY: release-artifacts
