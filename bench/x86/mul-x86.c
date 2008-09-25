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
x86_bench_mul(unsigned int trials)
{
  int i;
  unsigned long tsc1, tsc2;

  for (i = 0; i < trials; ++i) {
    /* mulb */
    tsc1 = fpfd_rdtsc();
    __asm__ volatile ("mulb %%dl"
                      :
                      :
                      : "%al", "%dl");
    tsc2 = fpfd_rdtsc();

    fpfd_record_ticks("mulb", tsc2 - tsc1);

    /* mulw */
    tsc1 = fpfd_rdtsc();
    __asm__ volatile ("mulw %%dx"
                      :
                      :
                      : "%ax", "%dx");
    tsc2 = fpfd_rdtsc();

    fpfd_record_ticks("mulw", tsc2 - tsc1);

    /* mull */
    tsc1 = fpfd_rdtsc();
    __asm__ volatile ("mull %%edx"
                      :
                      :
                      : "%eax", "%edx");
    tsc2 = fpfd_rdtsc();

    fpfd_record_ticks("mull", tsc2 - tsc1);
  }
}
