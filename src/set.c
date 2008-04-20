/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library                                 *
 *                                                                       *
 * The FPFD Library is free software; you can redistribute it and/or     *
 * modify it under the terms of the GNU Lesser General Public License as *
 * published by the Free Software Foundation; either version 3 of the    *
 * License, or (at your option) any later version.                       *
 *                                                                       *
 * The FPFD Library is distributed in the hope that it will be useful,   *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 * Lesser General Public License for more details.                       *
 *                                                                       *
 * You should have received a copy of the GNU Lesser General Public      *
 * License along with this program.  If not, see                         *
 * <http://www.gnu.org/licenses/>.                                       *
 *************************************************************************/

#include "fpfd_impl.h"
#include <string.h>

int fpfd32_set32(fpfd32_ptr dest, fpfd32_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc) {
  int tern;
  fpfd32_bcd_t bcd;
  fpfd32_bin_t bin;

  if (src->enc == enc) {
    memcpy(dest, src, sizeof(fpfd32_struct_t));
    tern = 0;
  } else if (src->enc == FPFD_ENCD) {
    fpfd32_to_bcd(&bcd, src);
    fpfd32_bcd_to_bin(&bin, &bcd);
    fpfd32_from_bin(dest, &bin);
    tern = 0;
  } else {
    fpfd32_to_bin(&bin, src);
    tern = fpfd32_bcd_tern(&bcd, fpfd32_bin_to_bcd(&bcd, &bin), rnd);
    fpfd32_from_bcd(dest, &bcd);
  }

  return tern;
}

int fpfd32_set64(fpfd32_ptr dest, fpfd64_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd32_set128(fpfd32_ptr dest, fpfd128_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);

int fpfd64_set32(fpfd64_ptr dest, fpfd32_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd64_set64(fpfd64_ptr dest, fpfd64_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd64_set128(fpfd64_ptr dest, fpfd128_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);

int fpfd128_set32(fpfd128_ptr dest, fpfd32_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd128_set64(fpfd128_ptr dest, fpfd64_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd128_set128(fpfd128_ptr dest, fpfd128_srcptr src,
                   fpfd_rnd_t rnd, fpfd_enc_t enc);
