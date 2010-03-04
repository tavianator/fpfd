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

#include "bench-x86_64.h"
#include <stdio.h>  /* For fprintf, xfopen */
#include <stdlib.h> /* For exit, EXIT_*   */
#include <search.h> /* For hcreate        */

static void x86_64_bench(sandglass_t *sandglass, unsigned int trials);
static void x86_64_bench_results();

int
main(int argc, char **argv)
{
  unsigned int trials;
  sandglass_t sandglass;

  if (argc != 2) {
    fprintf(stderr, "Wrong number of arguments: %d; should be 1.\n", argc - 1);
    return EXIT_FAILURE;
  }

  /* Read the number of trials from the command line */
  sscanf(argv[1], "%u", &trials);

  /* Initialize our timer */
  xsandglass_init(&sandglass);

  /* Create our hash table */
  xhcreate(40);

  x86_64_bench(&sandglass, trials);
  x86_64_bench_results();

  return EXIT_SUCCESS;
}

void
x86_64_bench(sandglass_t *sandglass, unsigned int trials)
{
  x86_64_bench_mul(sandglass, trials);
  x86_64_bench_div(sandglass, trials);
  x86_64_bench_uncertainty(sandglass, trials);
}

void
x86_64_bench_results()
{
  FILE *file;

  file = xfopen("x86_64-mulb.dat", "w");
  write_ticks("mulb", file);
  xfclose(file);

  file = xfopen("x86_64-mulw.dat", "w");
  write_ticks("mulw", file);
  xfclose(file);

  file = xfopen("x86_64-mull.dat", "w");
  write_ticks("mull", file);
  xfclose(file);

  file = xfopen("x86_64-mulq.dat", "w");
  write_ticks("mulq", file);
  xfclose(file);

  file = xfopen("x86_64-divb.dat", "w");
  write_ticks("divb", file);
  xfclose(file);

  file = xfopen("x86_64-divw.dat", "w");
  write_ticks("divw", file);
  xfclose(file);

  file = xfopen("x86_64-divl.dat", "w");
  write_ticks("divl", file);
  xfclose(file);

  file = xfopen("x86_64-divq.dat", "w");
  write_ticks("divq", file);
  xfclose(file);

  file = xfopen("x86_64-uncertainty.dat", "w");
  write_ticks("uncertainty", file);
  xfclose(file);
}
