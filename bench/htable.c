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
#include <search.h> /* For hsearch        */
#include <stdlib.h> /* For malloc, exit   */
#include <stdio.h>  /* For perror         */
#include <string.h> /* For strlen, strcpy */
#include <math.h>   /* For sqrt           */

static void save_ticks(const char *key, long tick_count, unsigned int loops);
static double mean_ticks(const char *key);
static double stddev_ticks(const char *key);

void
record_ticks(const char *key, long tick_count, unsigned int loops)
{
  long ticks1, ticks2;
  unsigned int i;
  char overhead_key[16];

  if (tick_count > 1) {
    ticks1 = ticks();
    for (i = 0; i < loops; ++i) {
      NO_UNROLL();
    }
    ticks2 = ticks();
  } else {
    ticks1 = ticks();
    ticks2 = ticks();
  }

  snprintf(overhead_key, sizeof(overhead_key), "overhead%u", loops);

  save_ticks(key, tick_count, loops);
  save_ticks(overhead_key, ticks2 - ticks1, loops);
}

void
write_ticks(const char *key, FILE *file)
{
  ENTRY e, *ep;
  ticklist_t *tl;
  double overhead, mean, stddev;
  size_t i;
  char overhead_key[16];

  e.key = (char *)key;
  ep = xhsearch(e, FIND);
  tl = ep->data;

  snprintf(overhead_key, sizeof(overhead_key), "overhead%u", tl->loops);

  overhead = mean_ticks(overhead_key);
  mean = mean_ticks(key) - overhead;
  stddev = stddev_ticks(key);

  /* Each trial */
  for (i = 0; i < tl->size; ++i) {
    fprintf(file, "%ld\t%g\n", (long)i,
            ((double)tl->list[i] / tl->loops) - overhead);
  }

  /* Mean */
  fprintf(file, "\n\n0\t%g\n%ld\t%g\n",
          mean, (long)tl->size - 1, mean);

  /* One standard deviation above and below the mean */
  fprintf(file, "\n\n0\t%g\n%ld\t%g\n",
          mean + stddev, (long)tl->size - 1, mean + stddev);
  fprintf(file, "\n\n0\t%g\n%ld\t%g\n",
          mean - stddev, (long)tl->size - 1, mean - stddev);
}

static void
save_ticks(const char *key, long tick_count, unsigned int loops)
{
  ENTRY e, *ep;
  ticklist_t *tl;

  e.key = (char *)key;
  ep = hsearch(e, FIND);

  if (!ep) {
    tl = xmalloc(sizeof(ticklist_t));

    tl->trials = 0;
    tl->list = xmalloc(sizeof(long));
    tl->size = 0;
    tl->capacity = 1;

    e.key = xmalloc(strlen(key));
    strcpy(e.key, key);
    e.data = tl;

    ep = xhsearch(e, ENTER);
  }

  tl = ep->data;

  ++tl->trials;

  if (tl->size == tl->capacity) {
    tl->capacity *= 2;
    tl->list = xrealloc(tl->list, tl->capacity * sizeof(long));
  }

  tl->list[tl->size] = tick_count;
  tl->loops = loops;
  ++tl->size;
}

static double
mean_ticks(const char *key)
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

  return (ticks / tl->trials) / tl->loops;
}

static double
stddev_ticks(const char *key)
{
  ENTRY e, *ep;
  ticklist_t *tl;
  double ticks, ticks_sq = 0.0, mean;
  size_t i;

  e.key = (char *)key;
  ep = xhsearch(e, FIND);
  tl = ep->data;

  for (i = 0; i < tl->size; ++i) {
    ticks = tl->list[i];
    ticks /= tl->loops;
    ticks *= ticks;
    ticks_sq += ticks;
  }

  mean = mean_ticks(key);

  return sqrt((ticks_sq / tl->trials) - mean * mean);
}
