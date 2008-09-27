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
#include <stdint.h> /* For uint64_6 */

unsigned int bench_loops;

uint64_t ticks64();
static uint64_t gcd(uint64_t a, uint64_t b);

/*
 * AMD chips seem to update the TSC every clock cycle, which is good. Old Intel
 * chips (PIII, Pentium-M, and earlier) do this also. However, new ones, with
 * the CONSTANT_TSC feature, update the counter  as if the processor is being
 * run at its highest multiplier, even when it isn't, and furthermore only
 * increment the TSC at FSB ticks, not CPU ticks. Thus, every TSC returned by
 * rdtsc will be a multiple of the highest multiplier supported by the CPU. To
 * detect this, we do a lot of rdtsc's, and find their greatest common
 * denominator. If it's > 1, we set bench_loops equal to twice it, to support
 * overclocked CPUs; otherwise, set bench_loops to 1.
 */
void
arch_init()
{
  #define COUNT 100
  unsigned int i;
  uint64_t mult, rdtsc[COUNT];

  for (i = 0; i < COUNT; ++i) {
    do {
      rdtsc[i] = ticks64();
    } while (ticks64() == rdtsc[i]);
  }

  for (i = 1; i < COUNT - 1; ++i) {
    mult = gcd(rdtsc[i] - rdtsc[0], rdtsc[i + 1] - rdtsc[0]);
  }

  if (mult > UINT64_C(1)) {
    bench_loops = 2 * mult;
  } else {
    bench_loops = 1;
  }

  #undef COUNT
}

static uint64_t
gcd(uint64_t a, uint64_t b)
{
  if (b == UINT64_C(0)) {
    return a;
  } else {
    return gcd(b, a % b);
  }
}
