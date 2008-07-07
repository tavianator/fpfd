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

static void fpfd32_bcd_bench_pre(fpfd32_bcd_t *bcd1, fpfd32_bcd_t *bcd2,
				 fpfd32_ptr fp1, fpfd32_ptr fp2) {
  clock_t tsc1, tsc2;

  tsc1 = uticks();
  fpfd32_to_bcd(bcd1, fp1);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_to_bcd", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_to_bcd(bcd2, fp2);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_to_bcd", tsc2 - tsc1);
}

static void fpfd32_bcd_bench_post(fpfd32_ptr fp, fpfd32_bcd_t *bcd,
                                  fpfd_rnd_t rnd) {
  clock_t tsc1, tsc2;
  uint32_t rem;

  tsc1 = uticks();
  rem = fpfd32_bcd_normalize(bcd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bcd_normalize", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_bcd_tern(bcd, rem, rnd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bcd_tern", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_from_bcd(fp, bcd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_from_bcd", tsc2 - tsc1);
}


static void fpfd32_bcd_bench_post2(fpfd32_ptr fp, fpfd32_bcd_t *bcd,
                                  uint32_t rem1, fpfd_rnd_t rnd) {
  clock_t tsc1, tsc2;
  uint32_t rem2;

  tsc1 = uticks();
  rem2 = fpfd32_bcd_normalize(bcd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bcd_normalize", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_bcd_tern2(bcd, rem1, rem2, rnd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bcd_tern2", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_from_bcd(fp, bcd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_from_bcd", tsc2 - tsc1);
}

static void fpfd32_bin_bench_pre(fpfd32_bin_t *bin1, fpfd32_bin_t *bin2,
				 fpfd32_ptr fp1, fpfd32_ptr fp2) {
  clock_t tsc1, tsc2;

  tsc1 = uticks();
  fpfd32_to_bin(bin1, fp1);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_to_bin", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_to_bin(bin2, fp2);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_to_bin", tsc2 - tsc1);
}

static void fpfd32_bin_bench_post(fpfd32_ptr fp, fpfd32_bin_t *bin,
                                  fpfd_rnd_t rnd) {
  clock_t tsc1, tsc2;
  uint32_t rem;

  tsc1 = uticks();
  rem = fpfd32_bin_normalize(bin);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bin_normalize", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_bin_tern(bin, rem, rnd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bin_tern", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_from_bin(fp, bin);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_from_bin", tsc2 - tsc1);
}

static void fpfd32_bin_bench_post2(fpfd32_ptr fp, fpfd32_bin_t *bin,
                                   uint32_t rem1, fpfd_rnd_t rnd) {
  clock_t tsc1, tsc2;
  uint32_t rem2;

  tsc1 = uticks();
  rem2 = fpfd32_bin_normalize(bin);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bin_normalize", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_bin_tern2(bin, rem1, rem2, rnd);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_bin_tern2", tsc2 - tsc1);

  tsc1 = uticks();
  fpfd32_from_bin(fp, bin);
  tsc2 = uticks();
  fpfd_store_ticks("fpfd32_from_bin", tsc2 - tsc1);
}

void fpfd32_bench_add(unsigned int trials, int rngfd, int rngsave) {
  clock_t tsc1, tsc2;
  fpfd32_t fp, fp1, fp2;
  fpfd32_bcd_t bcd, bcd1, bcd2;
  fpfd32_bin_t bin, bin1, bin2;
  uint32_t rem1;

  for (unsigned int i = 0; i < trials; ++i) {
    /********************
     * Decimal encoding *
     ********************/
    fpfd32_set_rand(fp1, FPFD_ENCD, rngfd, rngsave);
    fpfd32_set_rand(fp2, FPFD_ENCD, rngfd, rngsave);

    fpfd32_bcd_bench_pre(&bcd1, &bcd2, fp1, fp2);

    tsc1 = uticks();
    rem1 = fpfd32_bcd_addsub(&bcd, 1, &bcd1, &bcd2);
    tsc2 = uticks();
    fpfd_store_ticks("fpfd32_bcd_addsub", tsc2 - tsc1);

    fpfd32_bcd_bench_post2(fp, &bcd, rem1, FPFD_RNDN);

    tsc1 = uticks();
    fpfd32_add(fp, fp1, fp2, FPFD_RNDN, FPFD_ENCD);
    tsc2 = uticks();
    fpfd_store_ticks("fpfd32_add(FPFD_ENCD)", tsc2 - tsc1);

    /*******************
     * Binary encoding *
     *******************/
    fpfd32_set_rand(fp1, FPFD_ENCB, rngfd, rngsave);
    fpfd32_set_rand(fp2, FPFD_ENCB, rngfd, rngsave);

    fpfd32_bin_bench_pre(&bin1, &bin2, fp1, fp2);

    tsc1 = uticks();
    rem1 = fpfd32_bin_addsub(&bin, 1, &bin1, &bin2);
    tsc2 = uticks();
    fpfd_store_ticks("fpfd32_bin_addsub", tsc2 - tsc1);

    fpfd32_bin_bench_post2(fp, &bin, rem1, FPFD_RNDN);

    tsc1 = uticks();
    fpfd32_add(fp, fp1, fp2, FPFD_RNDN, FPFD_ENCB);
    tsc2 = uticks();
    fpfd_store_ticks("fpfd32_add(FPFD_ENCB)", tsc2 - tsc1);
  }
}

void fpfd32_bench_sub(unsigned int trials, int rngfd, int rngsave) {
}

void fpfd32_bench_mul(unsigned int trials, int rngfd, int rngsave) {
}

void fpfd32_bench_div(unsigned int trials, int rngfd, int rngsave) {
}
