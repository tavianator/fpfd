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

void fpfd32_bench(unsigned int trials, FILE *rng, FILE *rngsave) {
  unsigned int i;
  unsigned long tsc1, tsc2;
  fpfd32_t fp, fp1, fp2;
  fpfd32_impl_t rop, op1, op2;
  int rem1, rem2;
  fpfd_rnd_t rnd = FPFD_RNDN;

  for (i = 0; i < trials; ++i) {
    /* Micro ops */

    fpfd32_set_rand(fp1, rng, rngsave);
    fpfd32_set_rand(fp2, rng, rngsave);

    tsc1 = rdtsc();
    fpfd32_impl_expand(&op1, fp1);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_expand", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_impl_expand(&op2, fp2);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_expand", tsc2 - tsc1);

    tsc1 = rdtsc();
    rem1 = fpfd32_impl_addsub(&rop, 1, &op1, &op2);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_addsub(1)", tsc2 - tsc1);

    tsc1 = rdtsc();
    rem2 = fpfd32_impl_scale(&rop);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_scale(addsub(1))", tsc2 - tsc1);

    tsc1 = rdtsc();
    rem1 = fpfd32_impl_addsub(&rop, -1, &op1, &op2);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_addsub(-1)", tsc2 - tsc1);

    tsc1 = rdtsc();
    rem2 = fpfd32_impl_scale(&rop);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_scale(addsub(-1))", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_impl_mul(&rop, &op1, &op2);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_mul", tsc2 - tsc1);

    tsc1 = rdtsc();
    rem2 = fpfd32_impl_scale(&rop);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_scale(mul)", tsc2 - tsc1);

    tsc1 = rdtsc();
    rem1 = fpfd32_impl_div(&rop, &op1, &op2);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_div", tsc2 - tsc1);

    tsc1 = rdtsc();
    rem2 = fpfd32_impl_scale(&rop);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_scale(div)", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_impl_tern(&rop, rem2, rnd);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_tern", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_impl_tern2(&rop, rem1, rem2, rnd);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_tern2", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_impl_compress(fp, &rop);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_impl_compress", tsc2 - tsc1);

    /* Macro ops */

    tsc1 = rdtsc();
    fpfd32_add(fp, fp1, fp2, rnd);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_add(FPFD_ENCD)", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_sub(fp, fp1, fp2, rnd);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_sub(FPFD_ENCD)", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_mul(fp, fp1, fp2, rnd);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_mul(FPFD_ENCD)", tsc2 - tsc1);

    tsc1 = rdtsc();
    fpfd32_div(fp, fp1, fp2, rnd);
    tsc2 = rdtsc();
    fpfd_store_ticks("fpfd32_div(FPFD_ENCD)", tsc2 - tsc1);
  }
}
