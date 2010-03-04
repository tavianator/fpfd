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

static void gcc_bench(sandglass_t *sandglass, unsigned int trials);
static void gcc_bench_results();

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

  gcc_bench(&sandglass, trials);
  gcc_bench_results();

  return EXIT_SUCCESS;
}

void
gcc_bench(sandglass_t *sandglass, unsigned int trials)
{
  gcc32_bench_add(sandglass, trials);
  gcc64_bench_add(sandglass, trials);
  gcc128_bench_add(sandglass, trials);

  gcc32_bench_sub(sandglass, trials);
  gcc64_bench_sub(sandglass, trials);
  gcc128_bench_sub(sandglass, trials);

  gcc32_bench_mul(sandglass, trials);
  gcc64_bench_mul(sandglass, trials);
  gcc128_bench_mul(sandglass, trials);

  gcc32_bench_div(sandglass, trials);
  gcc64_bench_div(sandglass, trials);
  gcc128_bench_div(sandglass, trials);
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

    file = fopen("__dpd_adddd3.dat", "w");
    write_ticks("__dpd_adddd3", file);
    fclose(file);

    file = fopen("__dpd_addtd3.dat", "w");
    write_ticks("__dpd_addtd3", file);
    fclose(file);

    file = fopen("__dpd_subsd3.dat", "w");
    write_ticks("__dpd_subsd3", file);
    fclose(file);

    file = fopen("__dpd_subdd3.dat", "w");
    write_ticks("__dpd_subdd3", file);
    fclose(file);

    file = fopen("__dpd_subtd3.dat", "w");
    write_ticks("__dpd_subtd3", file);
    fclose(file);

    file = fopen("__dpd_mulsd3.dat", "w");
    write_ticks("__dpd_mulsd3", file);
    fclose(file);

    file = fopen("__dpd_muldd3.dat", "w");
    write_ticks("__dpd_muldd3", file);
    fclose(file);

    file = fopen("__dpd_multd3.dat", "w");
    write_ticks("__dpd_multd3", file);
    fclose(file);

    file = fopen("__dpd_divsd3.dat", "w");
    write_ticks("__dpd_divsd3", file);
    fclose(file);

    file = fopen("__dpd_divdd3.dat", "w");
    write_ticks("__dpd_divdd3", file);
    fclose(file);

    file = fopen("__dpd_divtd3.dat", "w");
    write_ticks("__dpd_divtd3", file);
    fclose(file);
  } else if (GCC_BID) {
    file = fopen("__bid_addsd3.dat", "w");
    write_ticks("__bid_addsd3", file);
    fclose(file);

    file = fopen("__bid_adddd3.dat", "w");
    write_ticks("__bid_adddd3", file);
    fclose(file);

    file = fopen("__bid_addtd3.dat", "w");
    write_ticks("__bid_addtd3", file);
    fclose(file);

    file = fopen("__bid_subsd3.dat", "w");
    write_ticks("__bid_subsd3", file);
    fclose(file);

    file = fopen("__bid_subdd3.dat", "w");
    write_ticks("__bid_subdd3", file);
    fclose(file);

    file = fopen("__bid_subtd3.dat", "w");
    write_ticks("__bid_subtd3", file);
    fclose(file);

    file = fopen("__bid_mulsd3.dat", "w");
    write_ticks("__bid_mulsd3", file);
    fclose(file);

    file = fopen("__bid_muldd3.dat", "w");
    write_ticks("__bid_muldd3", file);
    fclose(file);

    file = fopen("__bid_multd3.dat", "w");
    write_ticks("__bid_multd3", file);
    fclose(file);

    file = fopen("__bid_divsd3.dat", "w");
    write_ticks("__bid_divsd3", file);
    fclose(file);

    file = fopen("__bid_divdd3.dat", "w");
    write_ticks("__bid_divdd3", file);
    fclose(file);

    file = fopen("__bid_divtd3.dat", "w");
    write_ticks("__bid_divtd3", file);
    fclose(file);
  }
}
