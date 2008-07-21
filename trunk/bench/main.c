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
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <search.h>

int main(int argc, char **argv) {
  if (argc < 3) {
    fprintf(stderr, "main(): Wrong arguments\n");
    return EXIT_FAILURE;
  }

  FILE *rng = fopen(argv[1], "r");
  FILE *rngsave = fopen(argv[2], "w");

  if (rng == NULL || rngsave == NULL) {
    perror("open");
    return EXIT_FAILURE;
  }

  if (!hcreate(40)) {
    perror("hcreate");
    return EXIT_FAILURE;
  }

  /* Should be enough to get consistent tick counts every time */
  const unsigned int trials = 100;

  fpfd32_bench(trials, rng, rngsave);

  fclose(rngsave);
  fclose(rng);
  return EXIT_SUCCESS;
}
