/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library Benchmark Suite                 *
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
#include <search.h> /* For hsearch      */
#include <stdlib.h> /* For malloc, exit */
#include <stdio.h>  /* For perror       */
#include <math.h>   /* For sqrt         */

static void fpfd_save_ticks(const char *key, unsigned long ticks);
static double fpfd_mean_ticks(const char *key);
static double fpfd_stddev_ticks(const char *key);

void
fpfd_record_ticks(const char *key, unsigned long ticks)
{
  unsigned long tsc1, tsc2;

  tsc1 = fpfd_rdtsc();
  tsc2 = fpfd_rdtsc();

  fpfd_save_ticks(key, ticks);
  fpfd_save_ticks("fpfd_rdtsc", tsc2 - tsc1);
}

void
fpfd_write_ticks(const char *key, FILE *file)
{
  ENTRY e, *ep;
  ticklist_t *tl;
  double rdtsc;
  size_t i;

  rdtsc = fpfd_mean_ticks("fpfd_rdtsc");

  e.key = (char *)key;
  ep = xhsearch(e, FIND);

  tl = ep->data;

  for (i = 0; i < tl->size; ++i) {
    fprintf(file, "%lu\t%g\n", (unsigned long)i, tl->list[i] - rdtsc);
  }
}

void
fpfd_write_tick_summary(const char *key, FILE *file, int *i)
{
  double mean, stddev, rdtsc;

  mean = fpfd_mean_ticks(key);
  stddev = fpfd_stddev_ticks(key);
  rdtsc = fpfd_mean_ticks("fpfd_rdtsc");

  fprintf(file, "%d\t%g\t%g\n", *i, mean - rdtsc, stddev);
  ++*i;
}

static void
fpfd_save_ticks(const char *key, unsigned long ticks)
{
  ENTRY e, *ep;
  ticklist_t *tl;

  e.key = (char *)key;
  ep = hsearch(e, FIND);

  if (!ep) {
    tl = xmalloc(sizeof(ticklist_t));

    tl->trials = 0;
    tl->list = xmalloc(sizeof(unsigned long));
    tl->size = 0;
    tl->capacity = 1;

    e.data = tl;

    ep = xhsearch(e, ENTER);
  }

  tl = ep->data;

  ++tl->trials;

  if (tl->size == tl->capacity) {
    tl->capacity *= 2;
    tl->list = xrealloc(tl->list, tl->capacity * sizeof(unsigned long));
  }

  tl->list[tl->size] = ticks;
  ++tl->size;
}

static double
fpfd_mean_ticks(const char *key)
{
  ENTRY e, *ep;
  ticklist_t *tl;
  double ticks = 0.0;
  size_t i;

  e.key = (char *)key;
  ep = xhsearch(e, FIND);

  tl = ep->data;

  for (i = 0; i < tl->size; ++i) {
    ticks += tl->list[i];
  }

  return ticks / tl->trials;
}

static double
fpfd_stddev_ticks(const char *key)
{
  ENTRY e, *ep;
  ticklist_t *tl;
  double ticks, ticks_sq, mean;
  size_t i;

  e.key = (char *)key;
  ep = xhsearch(e, FIND);

  tl = ep->data;

  for (i = 0; i < tl->size; ++i) {
    ticks = tl->list[i];
    ticks *= ticks;
    ticks_sq += ticks;
  }

  mean = fpfd_mean_ticks(key);

  return sqrt((ticks_sq / tl->trials) - mean * mean);
}
