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

#include "bench.h"
#include <stdio.h>  /* For fprintf, FILE */
#include <stdlib.h> /* For exit, EXIT_*  */
#include <search.h> /* For hcreate       */

void fpfd_bench(unsigned int trials);
void fpfd_bench_results(FILE *file);

int
main(int argc, char **argv)
{
  /* Should be enough to get consistent tick counts every time */
  const unsigned int trials = 100;

  /* The number of table enteries. */
  if (!hcreate(40)) {
    perror("hcreate");
    exit(EXIT_FAILURE);
  }

  fpfd_bench(trials);
  fpfd_bench_results(stdout);

  return EXIT_SUCCESS;
}

void
fpfd_bench(unsigned int trials)
{
  fpfd32_bench_impl_expand(trials);
  /*
  fpfd32_bench_impl_compress(trials);
  fpfd32_bench_impl_scale(trials);
  fpfd32_bench_impl_inc(trials);
  fpfd32_bench_impl_addsub(trials);
  fpfd32_bench_impl_mul(trials);
  fpfd32_bench_impl_div(trials);

  fpfd32_bench_addsub(trials);
  fpfd32_bench_mul(trials);
  fpfd32_bench_div(trials);
  */
}

void
fpfd_bench_results(FILE *file)
{
  fprintf(file,
          "\n--- fpfd32_impl_expand ---\n"
          "");
}
