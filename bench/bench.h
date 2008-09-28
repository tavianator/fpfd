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

/* Use this to loop bench_loop times in a consistent manner */
#define BENCH_LOOP(i) for (i = 0; i < bench_loops; ++i)

/* Use this to prevent the loop from being unrolled */
#define NO_UNROLL() __asm__ volatile ("")

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
 * Gets the number of clock ticks since some time. On systems with a time-stamp
 * counter, this is an extremely high-resolution timer, accurate to one clock
 * tick, or sometimes, one FSB tick.
 */
unsigned long ticks();

/*
 * This function is architecture-specific. It sets bench_loops correctly.
 */
void arch_init();

/*
 * The number of times to call a function in a loop between calls to ticks() -
 * should be 1 if ticks() is accurate to 1 CPU tick, equal to the multiplier if
 * ticks() is accurate to 1 bus tick, and very high if we are using the fallback
 * clock() implementation.
 */
extern unsigned int bench_loops;

/*
 * Functions which deal with the hash table.
 *   record_ticks stores the tick count of the trial in the hash table.
 *   write_ticks writes the tick count for each trial, the mean, and one
 *     standard deviation above and below it, to file, in a format readable by
 *     plotutils' graph, gnuplot, or similar.
 */
void record_ticks(const char *key, unsigned long tick_count);
void write_ticks(const char *key, FILE *file);
