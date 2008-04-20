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

  if (lhs->enc == rhs->enc) {
    if (lhs->enc == FPFD_ENCD) {
      fpfd32_to_bcd(&bcd1, lhs);
      fpfd32_to_bcd(&bcd2, rhs);

      rem1 = fpfd32_bcd_add(&bcd, &bcd1, &bcd2);
      rem2 = fpfd32_bcd_normalize(&bcd);
    } else {
    }
  } else {
  }

  return tern;
}
