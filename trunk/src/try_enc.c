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

fpfd_enc_t fpfd32_try_expand2(fpfd32_srcptr arg1, fpfd32_srcptr arg2,
                              fpfd32_bcd_t *bcd1, fpfd32_bcd_t *bcd2,
                              fpfd32_bin_t *bin1, fpfd32_bin_t *bin2,
                              fpfd_enc_t enc) {
  fpfd_enc_t enc_used;

  if (arg1->enc == arg2->enc) {
    enc_used = arg1->enc;

    if (arg1->enc == FPFD_ENCD) {
      fpfd32_to_bcd(bcd1, arg1);
      fpfd32_to_bcd(bcd2, arg2);
    } else {
      fpfd32_to_bin(bin1, arg1);
      fpfd32_to_bin(bin2, arg2);
    }
  } else {
    enc_used = enc;

    if (arg1->enc == FPFD_ENCD) {
      fpfd32_to_bcd(bcd1, arg1);
      fpfd32_to_bin(bin2, arg2);

      if (enc_used == FPFD_ENCB)
        fpfd32_bcd_to_bin(bin1, bcd1);
      else
        fpfd32_bin_to_bcd(bcd2, bin2);
    } else {
      fpfd32_to_bin(bin1, arg1);
      fpfd32_to_bcd(bcd2, arg2);

      if (enc_used == FPFD_ENCD)
        fpfd32_bin_to_bcd(bcd1, bin1);
      else
        fpfd32_bcd_to_bin(bin2, bcd2);
    }
  }

  return enc_used;
}
