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
#include "../src/fpfd_impl.h" // For fpfd_panic
#include <search.h> // For hsearch
#include <stdlib.h> // For malloc

void fpfd_store_ticks(const char *fn, uint64_t ticks) {
  ENTRY e, *ep;
  uint64_t tsc1, tsc2;

  e.key = fn;
  ep = hsearch(e, FIND);

  if (!ep) {
    tickinfo *t = malloc(sizeof(tickinfo));
    t->ticks = 0;
    t->trials = 0;
    e.data = t;

    if (!e.data) {
      fpfd_panic("store_ticks(): malloc failed");
    }

    ep = hsearch(e, ENTER);

    if (!ep) {
      fpfd_panic("store_ticks(): hsearch failed");
    }
  }

  tsc1 = rdtsc();
  tsc2 = rdtsc();

  ticks -= tsc2 - tsc1;

  tickinfo *t = ep->data;
  t->ticks += ticks;
  ++t->trials;
}

double fpfd_ticks(const char *fn) {
  ENTRY e, *ep;

  e.key = fn;
  ep = hsearch(e, FIND);

  if (!ep) {
    return -1.0;
  }

  tickinfo *t = ep->data;
  return (double)t->ticks/(double)t->trials;
}
