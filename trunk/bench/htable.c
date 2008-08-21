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

typedef struct {
  unsigned int trials;
  unsigned long *list;
  size_t size, capacity;
} ticklist_t;

static void fpfd_save_ticks(const char *key, unsigned long ticks);
static double fpfd_raw_mean_ticks(const char *key);

void
fpfd_record_ticks(const char *key, unsigned long ticks)
{
  unsigned long tsc1, tsc2;

  tsc1 = fpfd_rdtsc();
  tsc2 = fpfd_rdtsc();

  fpfd_save_ticks(key, ticks);
  fpfd_save_ticks("fpfd_rdtsc", tsc2 - tsc1);
}

double
fpfd_mean_ticks(const char *key)
{
  return fpfd_raw_mean_ticks(key) - fpfd_raw_mean_ticks("fpfd_rdtsc");
}

double
fpfd_stddev_ticks(const char *key)
{
  ENTRY e, *ep;
  ticklist_t *tl;
  double ticks, ticks_sq = 0.0, mean;
  size_t i;

  e.key = (char *)key;
  ep = hsearch(e, FIND);

  if (!ep) {
    return -1.0;
  }

  tl = ep->data;

  for (i = 0; i < tl->size; ++i) {
    ticks = tl->list[i];
    ticks *= ticks;
    ticks_sq += ticks;
  }
  mean = fpfd_raw_mean_ticks(key);

  return sqrt((ticks_sq / tl->trials) - mean * mean);
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

    ep = hsearch(e, ENTER);

    if (!ep) {
      perror("hsearch");
      exit(EXIT_FAILURE);
    }
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
fpfd_raw_mean_ticks(const char *key)
{
  ENTRY e, *ep;
  ticklist_t *tl;
  double ticks = 0.0;
  size_t i;

  e.key = (char *)key;
  ep = hsearch(e, FIND);

  if (!ep) {
    return -1.0;
  }

  tl = ep->data;

  for (i = 0; i < tl->size; ++i) {
    ticks += tl->list[i];
  }

  return ticks / tl->trials;
}
