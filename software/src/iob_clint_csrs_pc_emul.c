/*
 * SPDX-FileCopyrightText: 2026 IObundle
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

/* PC Emulation of CLINT peripheral */

#include <stdint.h>
#include <time.h>

#include "iob_clint_csrs.h"

static int base;
void iob_clint_csrs_init_baseaddr(uint32_t addr) {
  base = addr;
  return;
}

// Core Setters and Getters
void iob_clint_csrs_set_dummy_reg(uint32_t value, int addr) {
  // Not implemented for PC emulation
  (void)value;
  (void)addr;
  return;
}

uint32_t iob_clint_csrs_get_version() {
  // Not implemented for PC emulation
  return 1;
}
