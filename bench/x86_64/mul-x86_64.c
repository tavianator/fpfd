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
x86_64_bench_mul(sandglass_t *sandglass, unsigned int trials)
{
  unsigned int i;

  for (i = 0; i < trials; ++i) {
    /* mulb */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("mulb %%dl"
                        :
                        :
                        : "%al", "%dl");
    });
    record_ticks("mulb", sandglass->grains);

    /* mulw */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("mulw %%dx"
                        :
                        :
                        : "%ax", "%dx");
    });
    record_ticks("mulw", sandglass->grains);

    /* mull */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("mull %%edx"
                        :
                        :
                        : "%eax", "%edx");
    });
    record_ticks("mull", sandglass->grains);

    /* mulq */
    sandglass_bench_fine(sandglass, {
      __asm__ volatile ("mulq %%rdx"
                        :
                        :
                        : "%rax", "%rdx");
    });
    record_ticks("mulq", sandglass->grains);
  }
}
