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

#include "bench-gcc.h"

void
gcc32_bench_div(unsigned int trials)
{
  fpfd32_union_t fp, lhs, rhs;
  long ticks1, ticks2;
  unsigned int i, j;

  /* Warm up cache */
  fpfd32_random(lhs.fpfd);
  fpfd32_random(rhs.fpfd);
#if GCC_DPD
  fp.dec = __dpd_divsd3(lhs.dec, rhs.dec);
#elif GCC_BID
  fp.dec = __bid_divsd3(lhs.dec, rhs.dec);
#endif

  for (i = 0; i < trials; ++i) {
    fpfd32_random(lhs.fpfd);
    fpfd32_random(rhs.fpfd);

    ticks1 = ticks();
    BENCH_LOOP(j) {
      NO_UNROLL();
#if GCC_DPD
      fp.dec = __dpd_divsd3(lhs.dec, rhs.dec);
#elif GCC_BID
      fp.dec = __bid_divsd3(lhs.dec, rhs.dec);
#endif
    }
    ticks2 = ticks();

    if (GCC_DPD) {
      record_ticks("__dpd_divsd3", ticks2 - ticks1);
    } else if (GCC_BID) {
      record_ticks("__bid_divsd3", ticks2 - ticks1);
    }
  }
}
