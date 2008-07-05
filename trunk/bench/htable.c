#include "bench.h"
#include "fpfd_impl.h" // For fpfd_panic
#include <search.h> // For hsearch
#include <stdlib.h> // For malloc

void fpfd_store_ticks(const char *fn, uint64_t ticks) {
  ENTRY e, *ep;

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
