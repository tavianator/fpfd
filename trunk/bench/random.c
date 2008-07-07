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
#include "../src/fpfd_impl.h" // For fpfd32_from_bin
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

void rngread(int rngfd, int rngsave, void *buf, size_t count) {
  uint32_t n32;
  uint16_t n16;
  uint8_t n8;

  while (count >= 4) {
    read(rngfd, &n32, 4);
    n32 = ntohl(n32);
    memcpy(buf, &n32, 4);
    n32 = htonl(n32);
    write(rngsave, &n32, 4);
    buf = (uint8_t *)buf + 4;
    count -= 4;
  }

  if (count) {
    read(rngfd, &n16, 2);
    n16 = ntohs(n16);
    memcpy(buf, &n16, 2);
    n16 = htons(n16);
    write(rngsave, &n16, 2);
    buf = (uint8_t *)buf + 2;
    count -= 2;
  }

  if (count) {
    read(rngfd, &n8, 1);
    memcpy(buf, &n8, 1);
    write(rngsave, &n8, 1);
  }
}

void fpfd32_set_rand(fpfd32_ptr dest, fpfd_enc_t enc, int rngfd, int rngsave) {
  uint32_t exp, sign;
  fpfd32_bin_t bin; /* HACK! fpfd32_from_bin keeps the mantissa intact, even
                       if it's really meant to be a decimal-encoded number */

  memset(bin.mant, 0, 8);

  rngread(rngfd, rngsave, bin.mant, 4);
  rngread(rngfd, rngsave, &exp, 4);
  rngread(rngfd, rngsave, &sign, 4);

  uint32_t *mant = (uint32_t *)(&bin.mant[0]);
  *mant &= 0x000FFFFF;

  exp %= 192;
  sign %= 2;
  sign <<= 1;

  bin.exp = exp - 101;
  bin.sign = sign - 1;
  bin.special = FPFD_NUMBER;

  fpfd32_from_bin(dest, &bin);
  dest->enc = enc;
}

void fpfd32_bcd_rand(fpfd32_bcd_t *dest, int rngfd, int rngsave) {
  uint32_t rand, exp, sign;
  uint32_t *mant;

  mant = (uint32_t *)(&dest->mant[0]);
  rngread(rngfd, rngsave, &rand, 4);

  for (int i = 0; i < 8; ++i) {
    *mant <<= 4;
    *mant += rand % 10;
    rand /= 10;
  }
  
  mant = (uint32_t *)(&dest->mant[4]);
  rngread(rngfd, rngsave, &rand, 4);

  for (int i = 0; i < 8; ++i) {
    *mant <<= 4;
    *mant += rand % 10;
    rand >>= 4;
  }
  
  rngread(rngfd, rngsave, &exp, 4);
  rngread(rngfd, rngsave, &sign, 4);

  exp %= 192;
  sign %= 2;
  sign <<= 1;

  dest->exp = exp - 101;
  dest->sign = sign - 1;
  dest->special = FPFD_NUMBER;
}

void fpfd32_bin_rand(fpfd32_bin_t *dest, int rngfd, int rngsave) {
  uint32_t exp, sign;

  rngread(rngfd, rngsave, dest->mant, 8);
  rngread(rngfd, rngsave, &exp, 4);
  rngread(rngfd, rngsave, &sign, 4);

  exp %= 192;
  sign %= 2;
  sign <<= 1;

  dest->exp = exp - 101;
  dest->sign = sign - 1;
  dest->special = FPFD_NUMBER;
}
