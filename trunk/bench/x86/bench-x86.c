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

#include "bench-x86.h"
#include <stdio.h>  /* For fprintf, fopen */
#include <stdlib.h> /* For exit, EXIT_*   */
#include <search.h> /* For hcreate        */

static void x86_bench(unsigned int trials);
static void x86_bench_results();

int
main(int argc, char **argv)
{
  /* Should be enough to get consistent tick counts every time */
  unsigned int trials;

  if (argc != 2) {
    fprintf(stderr, "Wrong number of arguments: %d, should be 1.\n", argc - 1);
    exit(EXIT_FAILURE);
  }

  sscanf(argv[1], "%u", &trials);

  /* The number of table enteries. */
  if (!hcreate(40)) {
    perror("hcreate");
    exit(EXIT_FAILURE);
  }

  x86_bench(trials);
  x86_bench_results();

  return EXIT_SUCCESS;
}

void
x86_bench(unsigned int trials)
{
  x86_bench_mul(trials);
}

void
x86_bench_results()
{
  FILE *file;

  file = fopen("x86_64-mulb.dat", "w");
  fpfd_write_ticks("mulb", file);
  fclose(file);

  file = fopen("x86_64-mulw.dat", "w");
  fpfd_write_ticks("mulw", file);
  fclose(file);

  file = fopen("x86_64-mull.dat", "w");
  fpfd_write_ticks("mull", file);
  fclose(file);
}
