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

/*
 * AMD chips seem to update the TSC every clock cycle, which is good. Old Intel
 * chips (PIII, Pentium-M, and earlier) do this also. However, new ones, with
 * the CONSTANT_TSC feature, update the counter  as if the processor is being
 * run at its highest multiplier, even when it isn't, and furthermore only
 * increment the TSC at FSB ticks, not CPU ticks. Thus, every TSC returned by
 * rdtsc will be a multiple of the highest multiplier supported by the CPU. To
 * support this, we set bench_loops to 256, which has a small remainder when
 * divided into any concievable clock multiplier.
 */
unsigned int bench_loops = 256;
