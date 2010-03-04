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
#include <stdlib.h> /* For malloc, exit */
#include <stdio.h>  /* For perror       */

static void xdie();

void *
xmalloc(size_t size)
{
  void *ptr = malloc(size);

  if (!ptr) {
    perror("malloc");
    xdie();
  }

  return ptr;
}

void *
xrealloc(void *ptr, size_t size)
{
  ptr = realloc(ptr, size);

  if (!ptr) {
    perror("realloc");
    xdie();
  }

  return ptr;
}

FILE *
xfopen(const char *path, const char *mode)
{
  FILE *ptr = fopen(path, mode);

  if (!ptr) {
    perror("fopen");
    xdie();
  }

  return ptr;
}

void
xfclose(FILE *fp)
{
  if (fclose(fp)) {
    perror("fclose");
    xdie();
  }
}

void
xhcreate(size_t size)
{
  if (hcreate(size) == 0) {
    perror("hcreate");
    exit(EXIT_FAILURE);
  }
}

ENTRY *
xhsearch(ENTRY item, ACTION action)
{
  ENTRY *ptr = hsearch(item, action);

  if (!ptr) {
    perror("hsearch");
    xdie();
  }

  return ptr;
}

void
xsandglass_init(sandglass_t *sandglass)
{
  if (sandglass_init_monotonic(sandglass, SANDGLASS_CPUTIME) != 0) {
    perror("sandglass_init_monotonic");
    xdie();
  }
}

static void
xdie()
{
  exit(EXIT_FAILURE);
}
