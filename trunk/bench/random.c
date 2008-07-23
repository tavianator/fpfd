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
#include <stdio.h>     /* For fread              */
#include <string.h>    /* For memcpy             */
#include <arpa/inet.h> /* For ntohl, htonl, etc. */

void rngread(FILE *rng, FILE *rngsave, void *buf, size_t count) {
  uint32_t n32;
  uint16_t n16;
  uint8_t n8;

  while (count >= sizeof(uint32_t)) {
    fread(&n32, sizeof(uint32_t), 1, rng);
    n32 = ntohl(n32);
    memcpy(buf, &n32, sizeof(uint32_t));
    n32 = htonl(n32);
    fwrite(&n32, sizeof(uint32_t), 1, rngsave);
    buf = (uint8_t *)buf + sizeof(uint32_t);
    count -= sizeof(uint32_t);
  }

  if (count) {
    fread(&n16, sizeof(uint16_t), 1, rng);
    n16 = ntohs(n16);
    memcpy(buf, &n16, sizeof(uint16_t));
    n16 = htons(n16);
    fwrite(&n16, sizeof(uint16_t), 1, rngsave);
    buf = (uint8_t *)buf + sizeof(uint16_t);
    count -= sizeof(uint16_t);
  }

  if (count) {
    fread(&n8, sizeof(uint8_t), 1, rng);
    memcpy(buf, &n8, sizeof(uint8_t));
    fwrite(&n8, sizeof(uint8_t), 1, rngsave);
  }
}

void fpfd32_set_rand(fpfd32_ptr dest, FILE *rng, FILE *rngsave) {
  fpfd32_impl_t rop;

  /* Loop until we have zero or a number. */
  do {
    rngread(rng, rngsave, dest, sizeof(fpfd32_t));
    fpfd32_impl_expand(&rop, dest);
  } while (rop.fields.special != FPFD_ZERO
           && rop.fields.special != FPFD_NUMBER);
}
