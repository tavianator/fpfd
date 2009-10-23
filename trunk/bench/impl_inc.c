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

#include "bench-fpfd.h"

void
fpfd32_bench_impl_inc(sandglass_t *sandglass, unsigned int trials)
{
  fpfd32_t fp;
  fpfd32_impl_t impl;
  unsigned int i;

  for (i = 0; i < trials; ++i) {
    fpfd32_random(fp);
    fpfd32_impl_expand(&impl, fp);

    sandglass_bench_fine(sandglass, fpfd32_impl_inc(&impl));
    record_ticks("fpfd32_impl_inc", sandglass->grains);
  }
}
