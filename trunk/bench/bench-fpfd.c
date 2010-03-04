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

#include "bench-fpfd.h"
#include <stdio.h>  /* For fprintf, fopen */
#include <stdlib.h> /* For exit, EXIT_*   */
#include <search.h> /* For hcreate        */

static void fpfd_bench(sandglass_t *sandglass, unsigned int trials);
static void fpfd_bench_results();

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

  fpfd_bench(&sandglass, trials);
  fpfd_bench_results();

  return EXIT_SUCCESS;
}

void
fpfd_bench(sandglass_t *sandglass, unsigned int trials)
{
  /* Implementation functions */

  fpfd32_bench_impl_expand(sandglass, trials);
  fpfd64_bench_impl_expand(sandglass, trials);
  fpfd128_bench_impl_expand(sandglass, trials);

  fpfd32_bench_impl_addsub(sandglass, trials);

  fpfd32_bench_impl_mul(sandglass, trials);
  fpfd64_bench_impl_mul(sandglass, trials);

  fpfd32_bench_impl_div(sandglass, trials);
  fpfd32_bench_impl_inc(sandglass, trials);
  fpfd32_bench_impl_scale(sandglass, trials);

  fpfd32_bench_impl_compress(sandglass, trials);
  fpfd64_bench_impl_compress(sandglass, trials);
  fpfd128_bench_impl_compress(sandglass, trials);

  /* Public functions */
  fpfd32_bench_add(sandglass, trials);
  fpfd32_bench_sub(sandglass, trials);
  fpfd32_bench_mul(sandglass, trials);
  fpfd32_bench_div(sandglass, trials);
  fpfd32_bench_fma(sandglass, trials);
}

void
fpfd_bench_results()
{
  FILE *file;

  /* Implementation functions */

  file = fopen("fpfd32_impl_expand.dat", "w");
  write_ticks("fpfd32_impl_expand", file);
  fclose(file);

  file = fopen("fpfd64_impl_expand.dat", "w");
  write_ticks("fpfd64_impl_expand", file);
  fclose(file);

  file = fopen("fpfd128_impl_expand.dat", "w");
  write_ticks("fpfd128_impl_expand", file);
  fclose(file);

  file = fopen("fpfd32_impl_add.dat", "w");
  write_ticks("fpfd32_impl_add", file);
  fclose(file);

  file = fopen("fpfd32_impl_sub.dat", "w");
  write_ticks("fpfd32_impl_sub", file);
  fclose(file);

  file = fopen("fpfd32_impl_mul.dat", "w");
  write_ticks("fpfd32_impl_mul", file);
  fclose(file);

  file = fopen("fpfd64_impl_mul.dat", "w");
  write_ticks("fpfd64_impl_mul", file);
  fclose(file);

  file = fopen("fpfd32_impl_div.dat", "w");
  write_ticks("fpfd32_impl_div", file);
  fclose(file);

  file = fopen("fpfd32_impl_scale.dat", "w");
  write_ticks("fpfd32_impl_scale", file);
  fclose(file);

  file = fopen("fpfd32_impl_inc.dat", "w");
  write_ticks("fpfd32_impl_inc", file);
  fclose(file);

  file = fopen("fpfd32_impl_compress.dat", "w");
  write_ticks("fpfd32_impl_compress", file);
  fclose(file);

  file = fopen("fpfd64_impl_compress.dat", "w");
  write_ticks("fpfd64_impl_compress", file);
  fclose(file);

  file = fopen("fpfd128_impl_compress.dat", "w");
  write_ticks("fpfd128_impl_compress", file);
  fclose(file);

  /* Public functions */

  file = fopen("fpfd32_add.dat", "w");
  write_ticks("fpfd32_add", file);
  fclose(file);

  file = fopen("fpfd32_sub.dat", "w");
  write_ticks("fpfd32_sub", file);
  fclose(file);

  file = fopen("fpfd32_mul.dat", "w");
  write_ticks("fpfd32_mul", file);
  fclose(file);

  file = fopen("fpfd32_div.dat", "w");
  write_ticks("fpfd32_div", file);
  fclose(file);

  file = fopen("fpfd32_fma.dat", "w");
  write_ticks("fpfd32_fma", file);
  fclose(file);
}
