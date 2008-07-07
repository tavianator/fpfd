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
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <search.h>

int main(int argc, char **argv) {
  if (argc < 3) {
    fpfd_panic("main(): Wrong arguments");
    return EXIT_FAILURE;
  }

  int rngfd = open(argv[1], O_RDONLY);
  int rngsave = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC,
                     S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

  if (rngfd == -1 || rngsave == -1) {
    fpfd_panic("main(): open() failed");
  }

  if (!hcreate(40)) {
    fpfd_panic("main(): hcreate() failed");
  }

  /* Should be enough to get consistent tick counts every time
   */
  const unsigned int trials = 100;

  fpfd32_bench_add(trials, rngfd, rngsave);
  fpfd32_bench_sub(trials, rngfd, rngsave);
  fpfd32_bench_mul(trials, rngfd, rngsave);
  fpfd32_bench_div(trials, rngfd, rngsave);

  close(rngsave);
  close(rngfd);
  return EXIT_SUCCESS;
}
