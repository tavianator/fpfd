/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is free software; you can redistribute it and/or modify it  *
 * under the terms of the GNU General Public License as published by the *
 * Free Software Foundation; either version 3 of the License, or (at     *
 * your option) any later version.                                       *
 *                                                                       *
 * This file is distributed in the hope that it will be useful, but      *
 * WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 * General Public License for more details.                              *
 *                                                                       *
 * You should have received a copy of the GNU General Public License     *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *************************************************************************/

#include <stdio.h>
#include <stdint.h>

typedef uint8_t bool;

void unpack10(bool dest[10], uint32_t src) {
  for (int i = 0; i < 10; ++i) {
    dest[i] = src >> 9;
    src -= ((src >> 9) << 9);
    src <<= 1;
  }
}

void bcd2dpd(bool dest[10], bool src[12]) {
  dest[0] = src[1] | (src[0] & src[9]) | (src[0] & src[5] & src[8]);
  dest[1] = src[2] | (src[0] & src[10]) | (src[0] & src[6] & src[8]);
  dest[2] = src[3];
  dest[3] = (src[5] & (~src[0] | ~src[8])) | (~src[0] & src[4] & src[9]) |
    (src[4] & src[8]);
  dest[4] = src[6] | (~src[0] & src[4] & src[10]) | (src[0] & src[8]);
  dest[5] = src[7];
  dest[6] = src[0] | src[4] | src[8];
  dest[7] = src[0] | (src[4] & src[8]) | (~src[4] & src[9]);
  dest[8] = src[4] | (src[0] & src[8]) | (~src[0] & src[10]);
  dest[9] = src[11];
}

void unpack12(bool dest[12], uint32_t src) {
  for (int i = 0; i < 12; ++i) {
    dest[i] = src >> 11;
    src -= ((src >> 11) << 11);
    src <<= 1;
  }
}

void dpd2bcd(bool dest[12], bool src[10]) {
  dest[0] = (src[6] & src[7]) & (~src[3] | src[4] | ~src[8]);
  dest[1] = src[0] & (~src[6] | ~src[7] | (src[3] & ~src[4] & src[8]));
  dest[2] = src[1] & (~src[6] | ~src[7] | (src[3] & ~src[4] & src[8]));
  dest[3] = src[2];
  dest[4] = src[6] &
    ((~src[7] & src[8]) | (~src[4] & src[8]) | (src[3] & src[8]));
  dest[5] = (src[3] & (~src[6] | ~src[8])) |
    (src[0] & ~src[3] & src[4] & src[6] & src[7] & src[8]);
  dest[6] = (src[4] & (~src[6] | ~src[8])) |
    (src[0] & ~src[3] & src[4] & src[7]);
  dest[7] = src[5];
  dest[8] = src[6] &
    ((~src[7] & ~src[8]) | (src[7] & src[8] & (src[3] | src[4])));
  dest[9] = (~src[6] & src[7]) |
    (src[3] & src[6] & ~src[7] & src[8]) |
    (src[0] & src[7] & (~src[8] | (~src[3] & ~src[4])));
  dest[10] = (~src[6] & src[8]) | 
    (src[4] & ~src[7] & src[8]) |
    (src[1] & src[6] & src[7] & (~src[8] | (~src[3] & ~src[4])));
  dest[11] = src[9];
}

int main() {
  bool bcd[12], dpd[10];

  printf(".globl fpfd_dpd2bcd\nfpfd_dpd2bcd:\n");

  for (uint32_t i = 0; i < (1 << 10); ++i) {
    unpack10(dpd, i);
    dpd2bcd(bcd, dpd);
    printf("        .long 0b0000");
    for (int j = 0; j < 12; ++j) {
      printf("%hhu", bcd[j]);
    }
    printf("\n");
  }

  printf("\n.globl fpfd_bcd2dpd\nfpfd_bcd2dpd:\n");

  for (uint32_t i = 0; i < (1 << 12); ++i) {
    unpack12(bcd, i);
    bcd2dpd(dpd, bcd);
    printf("        .long 0b000000");
    for (int j = 0; j < 10; ++j) {
      printf("%hhu", dpd[j]);
    }
    printf("\n");
  }

  return 0;
}
