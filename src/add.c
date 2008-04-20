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

int fpfd32_add(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd, fpfd_enc_t enc) {
  int tern;
  uint32_t rem1, rem2;
  fpfd32_bcd_t bcd, bcd1, bcd2;
  fpfd32_bin_t bin, bin1, bin2;
  fpfd_enc_t enc_used;

  enc_used = fpfd_try_expand2(lhs, rhs, &bcd1, &bcd2, &bin1, &bin2, enc);

  if (enc_used == FPFD_ENCD) {
    rem1 = fpfd32_bcd_add(&bcd, &bcd1, &bcd2);
    rem2 = fpfd32_bcd_normalize(&bcd);
    tern = fpfd32_bcd_tern2(&bcd, rem1, rem2, rnd);
  } else {
    rem1 = fpfd32_bin_add(&bin, &bin1, &bin2);
    rem2 = fpfd32_bin_normalize(&bin);
    tern = fpfd32_bin_tern2(&bin, rem1, rem2, rnd);
  }

  if (enc == FPFD_ENCD) {
    if (enc_used == FPFD_ENCB)
      fpfd32_bin_to_bcd(&bcd, &bin);
    fpfd32_from_bcd(dest, &bcd);
  } else {
    if (enc_used == FPFD_ENCD)
      fpfd32_bcd_to_bin(&bin, &bcd);
    fpfd32_from_bcd(dest, &bin);
  }

  return tern;
}
