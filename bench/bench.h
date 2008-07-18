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

#include "../libfpfd/fpfd_impl.h"
#include <search.h> /* For hsearch, etc. */
#include <stddef.h> /* For size_t */
#include <stdint.h> /* For uint64_t */
#include <stdio.h> /* For FILE */

typedef struct {
  uint64_t ticks;
  unsigned int trials;
} tickinfo;

/* Reads count bytes from rng in an endian-independant way, and writes them
 * back into rngsave for reproducability
 */
void rngread(FILE *rng, FILE *rngsave, void *buf, size_t count);

/* Set dest to a random number, read from rng (usually /dev/urandom), and
 * saves the read bytes back in rngsave
 */
void fpfd32_set_rand(fpfd32_ptr dest, FILE *rng, FILE *rngsave);

/* Gets the number of clock ticks since some time
 */
uint64_t rdtsc();

/* Functions which deal with the hash table.
 */
void fpfd_store_ticks(const char *fn, uint64_t ticks);
double fpfd_ticks(const char *fn);

/* Benchmark the arithmetic operations, and separately their micro-ops. trials
 * is the number of times to run the benchmark for each operation.
 */
void fpfd32_bench(unsigned int trials, FILE *rng, FILE *rngsave);

