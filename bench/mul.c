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
fpfd32_bench_mul(unsigned int trials)
{
  fpfd32_t fp, lhs, rhs;
  long ticks1, ticks2;
  unsigned int i, j;
  fpfd_flags_t flags = FPFD_NONE;

  for (i = 0; i < trials; ++i) {
    fpfd32_random(lhs);
    fpfd32_random(rhs);

    /* Warm up cache */
    fpfd32_mul(fp, lhs, rhs, FPFD_RNDN, &flags);

    /* Perform the benchmark */
    ticks1 = ticks();
    BENCH_LOOP(j) {
      NO_UNROLL();
      fpfd32_mul(fp, lhs, rhs, FPFD_RNDN, &flags);
    }
    ticks2 = ticks();

    record_ticks("fpfd32_mul", ticks2 - ticks1);
  }
}
