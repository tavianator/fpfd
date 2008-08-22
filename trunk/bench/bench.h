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
#include <search.h> /* For ENTRY, ACTION */
#include <stddef.h> /* For size_t        */
#include <stdio.h>  /* For FILE          */

/*
 * The type that stores the tick count of each trial, which is used by the hash
 * table.
 */
typedef struct {
  unsigned int trials;
  unsigned long *list;
  size_t size, capacity;
} ticklist_t;

/*
 * These work like the standard library functions without the 'x' prefix, but
 * call exit(EXIT_FAILURE) upon failure, so are guaranteed to have succeeded if
 * they return.
 */

void *xmalloc(size_t size);
void *xrealloc(void *ptr, size_t size);

FILE *xfopen(const char *path, const char *mode);
void xfclose(FILE *fp);

ENTRY *xhsearch(ENTRY item, ACTION action);

/*
 * Gets the number of clock ticks since some time. Extremely high-resolution
 * timer.
 */
unsigned long fpfd_rdtsc();

/*
 * Functions which deal with the hash table.
 *   fpfd_record_ticks stores the tick count of the trial in the hash table.
 *   fpfd_write_ticks writes the tick count of each trial to file.
 *   fpfd_write_tick_summary writes the mean tick count and standard deviation
 *     to file.
 */
void fpfd_record_ticks(const char *key, unsigned long ticks);
void fpfd_write_ticks(const char *key, FILE *file);
void fpfd_write_tick_summary(const char *key, FILE *file, int *i);

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
