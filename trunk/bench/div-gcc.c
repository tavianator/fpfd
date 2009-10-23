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
gcc32_bench_div(sandglass_t *sandglass, unsigned int trials)
{
  fpfd32_union_t fp, lhs, rhs;
  unsigned int i;

  for (i = 0; i < trials; ++i) {
    fpfd32_random(lhs.fpfd);
    fpfd32_random(rhs.fpfd);

    sandglass_bench_fine(sandglass, {
#if GCC_DPD
      fp.dec = __dpd_divsd3(lhs.dec, rhs.dec);
#elif GCC_BID
      fp.dec = __bid_divsd3(lhs.dec, rhs.dec);
#endif
    });

    if (GCC_DPD) {
      record_ticks("__dpd_divsd3", sandglass->grains);
    } else if (GCC_BID) {
      record_ticks("__bid_divsd3", sandglass->grains);
    }
  }
}

void
gcc64_bench_div(sandglass_t *sandglass, unsigned int trials)
{
  fpfd64_union_t fp, lhs, rhs;
  unsigned int i;

  for (i = 0; i < trials; ++i) {
    fpfd64_random(lhs.fpfd);
    fpfd64_random(rhs.fpfd);

    sandglass_bench_fine(sandglass, {
#if GCC_DPD
      fp.dec = __dpd_divdd3(lhs.dec, rhs.dec);
#elif GCC_BID
      fp.dec = __bid_divdd3(lhs.dec, rhs.dec);
#endif
    });

    if (GCC_DPD) {
      record_ticks("__dpd_divdd3", sandglass->grains);
    } else if (GCC_BID) {
      record_ticks("__bid_divdd3", sandglass->grains);
    }
  }
}

void
gcc128_bench_div(sandglass_t *sandglass, unsigned int trials)
{
  fpfd128_union_t fp, lhs, rhs;
  unsigned int i;

  for (i = 0; i < trials; ++i) {
    fpfd128_random(lhs.fpfd);
    fpfd128_random(rhs.fpfd);

    sandglass_bench_fine(sandglass, {
#if GCC_DPD
      fp.dec = __dpd_divtd3(lhs.dec, rhs.dec);
#elif GCC_BID
      fp.dec = __bid_divtd3(lhs.dec, rhs.dec);
#endif
    });

    if (GCC_DPD) {
      record_ticks("__dpd_divtd3", sandglass->grains);
    } else if (GCC_BID) {
      record_ticks("__bid_divtd3", sandglass->grains);
    }
  }
}
