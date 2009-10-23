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

#include "bench-x86_64.h"

void
x86_64_bench_div(sandglass_t *sandglass, unsigned int trials)
{
  unsigned int i;

  for (i = 0; i < trials; ++i) {
    /* divb */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("movw $0xFDFF, %%ax\n\t"
                        "divb %%al"
                        :
                        :
                        : "%ax");
    });
    /* The mov takes 1 cycle */
    record_ticks("divb", sandglass->grains - 1);

    /* divw */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("movw $0xFFFD, %%dx\n\t"
                        "movw $0xFFFF, %%ax\n\t"
                        "divw %%ax"
                        :
                        :
                        : "%ax", "%dx");
    });
    /* The two mov's take 2 cycles */
    record_ticks("divw", sandglass->grains - 2);

    /* divl */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("movl $0xFFFFFFFD, %%edx\n\t"
                        "movl $0xFFFFFFFF, %%eax\n\t"
                        "divl %%eax"
                        :
                        :
                        : "%eax", "%edx");
    });
    record_ticks("divl", sandglass->grains - 2);

    /* divq */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("movq $0xFFFFFFFFFFFFFFFD, %%rdx\n\t"
                        "movq $0xFFFFFFFFFFFFFFFF, %%rax\n\t"
                        "divq %%rax"
                        :
                        :
                        : "%rax", "%rdx");
    });
    record_ticks("divq", sandglass->grains - 2);
  }
}
