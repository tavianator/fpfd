#include "bench.h"
#include "fpfd_impl.h" // For fpfd_panic
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
