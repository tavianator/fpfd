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

#include "../libfpfd/fpfd_impl.h"
#include <search.h> /* For hsearch, etc. */
#include <stddef.h> /* For size_t        */
#include <stdio.h>  /* For FILE          */

typedef struct
{
  unsigned long ticks;
  unsigned long ticks_sq;
  unsigned int trials;
} tickinfo;

/*
 * Gets the number of clock ticks since some time. Extremely high-resolution
 * timer.
 */
unsigned long fpfd_rdtsc();

/*
 * Functions which deal with the hash table.
 *   fpfd_record_ticks stores the tick count of the trial in the hash table.
 *   fpfd_mean_ticks returns the mean tick count for a particular key.
 *   fpfd_stddev_ticks returns the standard deviation in the tick count for a
 *     particular key.
 */
void fpfd_record_ticks(const char *key, unsigned long ticks);
double fpfd_mean_ticks(const char *key);
double fpfd_stddev_ticks(const char *key);

/*
 * Routines which benchmark part of the programmer or implementation interfaces.
 * Each stores information about the number of clock ticks in a global hash
 * table, with strings describing the routine being profiled as the key.
 */

void fpfd32_bench_impl_expand(unsigned int trials);
void fpfd32_bench_impl_compress(unsigned int trials);
void fpfd32_bench_impl_scale(unsigned int trials);
void fpfd32_bench_impl_inc(unsigned int trials);
void fpfd32_bench_impl_addsub(unsigned int trials);
void fpfd32_bench_impl_mul(unsigned int trials);
void fpfd32_bench_impl_div(unsigned int trials);

void fpfd32_bench_addsub(unsigned int trials);
void fpfd32_bench_mul(unsigned int trials);
void fpfd32_bench_div(unsigned int trials);
