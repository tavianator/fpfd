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
x86_bench_div(unsigned int trials)
{
  unsigned int i, j;
  unsigned long ticks1, ticks2;

  for (i = 0; i < trials; ++i) {
    /* divb */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      __asm__ volatile ("movb $0xFD, %%dl\n\t"
                        "movb $0xFF, %%al\n\t"
                        "divb %%al"
                        :
                        :
                        : "%al", "%dl");
    }
    ticks2 = ticks();
    /* The two mov's take 2 cycles */
    record_ticks("divb", ticks2 - ticks1 - (2 * bench_loops));

    /* divw */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      __asm__ volatile ("movw $0xFFFD, %%dx\n\t"
                        "movw $0xFFFF, %%ax\n\t"
                        "divw %%ax"
                        :
                        :
                        : "%ax", "%dx");
    }
    ticks2 = ticks();
    record_ticks("divw", ticks2 - ticks1 - (2 * bench_loops));

    /* divl */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      __asm__ volatile ("movl $0xFFFFFFFD, %%edx\n\t"
                        "movl $0xFFFFFFFF, %%eax\n\t"
                        "divl %%eax"
                        :
                        :
                        : "%eax", "%edx");
    }
    ticks2 = ticks();
    record_ticks("divl", ticks2 - ticks1 - (2 * bench_loops));
  }
}
