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

#include "bench-gcc.h"
#include <stdio.h>  /* For fprintf, fopen */
#include <stdlib.h> /* For exit, EXIT_*   */
#include <search.h> /* For hcreate        */

static void gcc_bench(unsigned int trials);
static void gcc_bench_results();

int
main(int argc, char **argv)
{
  unsigned int trials;

  if (argc != 2) {
    fprintf(stderr, "Wrong number of arguments: %d; should be 1.\n", argc - 1);
    exit(EXIT_FAILURE);
  }

  sscanf(argv[1], "%u", &trials);

  /* The number of table enteries. */
  if (!hcreate(40)) {
    perror("hcreate");
    exit(EXIT_FAILURE);
  }

  gcc_bench(trials);
  gcc_bench_results();

  return EXIT_SUCCESS;
}

void
gcc_bench(unsigned int trials)
{
  gcc32_bench_add(trials);
  gcc32_bench_sub(trials);
  gcc32_bench_mul(trials);
  gcc32_bench_div(trials);
}

void
gcc_bench_results()
{
  FILE *file;

  /* Check all code paths by using if instead of #if */
  if (GCC_DPD) {
    file = fopen("__dpd_addsd3.dat", "w");
    write_ticks("__dpd_addsd3", file);
    fclose(file);

    file = fopen("__dpd_subsd3.dat", "w");
    write_ticks("__dpd_subsd3", file);
    fclose(file);

    file = fopen("__dpd_mulsd3.dat", "w");
    write_ticks("__dpd_mulsd3", file);
    fclose(file);

    file = fopen("__dpd_divsd3.dat", "w");
    write_ticks("__dpd_divsd3", file);
    fclose(file);
  } else if (GCC_BID) {
    file = fopen("__bid_addsd3.dat", "w");
    write_ticks("__bid_addsd3", file);
    fclose(file);

    file = fopen("__bid_subsd3.dat", "w");
    write_ticks("__bid_subsd3", file);
    fclose(file);

    file = fopen("__bid_mulsd3.dat", "w");
    write_ticks("__bid_mulsd3", file);
    fclose(file);

    file = fopen("__bid_divsd3.dat", "w");
    write_ticks("__bid_divsd3", file);
    fclose(file);
  }
}
