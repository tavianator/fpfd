/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library Benchmark Suite.                *
 *                                                                       *
 * The FPFD Library Benchmark Suite is free software; you can            *
 * redistribute it and/or modify it under the terms of the GNU General   *
 * Public License as published by the Free Software Foundation; either   *
 * version 3 of the License, or (at your option) any later version.      *
 *                                                                       *
 * The FPFD Library Benchmark Suite is distributed in the hope that it   *
 * will be useful, but WITHOUT ANY WARRANTY; without even the implied    *
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See *
 * the GNU General Public License for more details.                      *
 *                                                                       *
 * You should have received a copy of the GNU General Public License     *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *************************************************************************/

#include "bench.h"

void
x86_64_bench_mul(unsigned int trials)
{
  unsigned int i, j;
  long ticks1, ticks2;

  for (i = 0; i < trials; ++i) {
    /* mulb */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      __asm__ volatile ("mulb %%dl"
                        :
                        :
                        : "%al", "%dl");
    }
    ticks2 = ticks();
    record_ticks("mulb", ticks2 - ticks1, j);

    /* mulw */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      __asm__ volatile ("mulw %%dx"
                        :
                        :
                        : "%ax", "%dx");
    }
    ticks2 = ticks();
    record_ticks("mulw", ticks2 - ticks1, j);

    /* mull */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      __asm__ volatile ("mull %%edx"
                        :
                        :
                        : "%eax", "%edx");
    }
    ticks2 = ticks();
    record_ticks("mull", ticks2 - ticks1, j);

    /* mulq */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      __asm__ volatile ("mulq %%rdx"
                        :
                        :
                        : "%rax", "%rdx");
    }
    ticks2 = ticks();
    record_ticks("mulq", ticks2 - ticks1, j);
  }
}
