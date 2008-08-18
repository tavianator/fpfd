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

void
fpfd_store_ticks(const char *key, unsigned long ticks)
{
  ENTRY e, *ep;
  unsigned long tsc1, tsc2;

  e.key = key;
  ep = hsearch(e, FIND);

  if (!ep) {
    tickinfo *t = malloc(sizeof(tickinfo));
    t->ticks    = 0;
    t->ticks_sq = 0;
    t->trials   = 0;
    e.data      = t;

    if (!e.data) {
      perror("malloc");
      exit(EXIT_FAILURE);
    }

    ep = hsearch(e, ENTER);

    if (!ep) {
      perror("hsearch");
      exit(EXIT_FAILURE);
    }
  }

  tsc1 = fpfd_rdtsc();
  tsc2 = fpfd_rdtsc();

  ticks -= tsc2 - tsc1;

  tickinfo *t = ep->data;
  t->ticks += ticks;
  t->ticks_sq += ticks * ticks;
  ++t->trials;
}

double
fpfd_mean_ticks(const char *key)
{
  ENTRY e, *ep;

  e.key = key;
  ep = hsearch(e, FIND);

  if (!ep) {
    return -1.0;
  }

  tickinfo *t = ep->data;
  double ticks = t->ticks;
  double trials = t->trials;
  return ticks / trials;
}

double
fpfd_stddev_ticks(const char *key)
{
  ENTRY e, *ep;

  e.key = key;
  ep = hsearch(e, FIND);

  if (!ep) {
    return -1.0;
  }

  tickinfo *t = ep->data;
  double ticks = ticks;
  double ticks_sq = ticks_sq;
  double trials = trials;
  return sqrt((ticks_sq - (ticks * ticks / trials)) / trials);
}
