#include "fpfd_impl.h"
#include <fpfd.h>
#include <search.h> // For hsearch, etc.
#include <stddef.h> // For size_t
#include <stdint.h> // For uint32_t, uint64_t, etc.

typedef struct {
  uint64_t ticks;
  unsigned int trials;
} tickinfo;

/* Gets the time-stamp counter of the cpu with the rdtsc instruction
 */
uint64_t rdtsc();

/* Reads count bytes from rngfd in an endian-independant way, and writes them
 * back into rngsave for reproducability
 */
void rngread(int rngfd, int rngsave, void *buf, size_t count);

/* Set dest to a random number, read from rngfd (usually /dev/urandom), and
 * saves the read bytes back in rngsave
 */
void fpfd32_set_rand(fpfd32_ptr dest, fpfd_enc_t enc, int rngfd, int rngsave);

/* Functions which deal with the hash table.
 */
void fpfd_store_ticks(const char *fn, uint64_t ticks);
double fpfd_ticks(const char *fn);

/* Benchmark the arithmetic operations, and separately their micro-ops. trials
 * is the number of times to run the benchmark for a particular operation.
 */
void fpfd32_bench_add(unsigned int trials, int rngfd, int rngsave);
void fpfd32_bench_sub(unsigned int trials, int rngfd, int rngsave);
void fpfd32_bench_mul(unsigned int trials, int rngfd, int rngsave);
void fpfd32_bench_div(unsigned int trials, int rngfd, int rngsave);
