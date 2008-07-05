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

void fpfd32_expand2(fpfd32_srcptr fp1, fpfd32_srcptr fp2,
                    fpfd32_bcd_t *bcd1, fpfd32_bcd_t *bcd2,
                    fpfd32_bin_t *bin1, fpfd32_bin_t *bin2,
                    fpfd_enc_t enc) {
  switch (enc) {
  case FPFD_ENCD:
    switch (fp1->enc) {
    case FPFD_ENCD:
      fpfd32_to_bcd(bcd1, fp1);
      break;
    case FPFD_ENCB:
      fpfd32_to_bin(bin1, fp1);
      fpfd32_bin_to_bcd(bcd1, bin1);
      break;
    default:
      fpfd_panic("fpfd32_expand2(): fp1->enc has unacceptable value");
      break;
    }

    switch (fp2->enc) {
    case FPFD_ENCD:
      fpfd32_to_bcd(bcd2, fp2);
      break;
    case FPFD_ENCB:
      fpfd32_to_bin(bin2, fp2);
      fpfd32_bin_to_bcd(bcd2, bin2);
      break;
    default:
      fpfd_panic("fpfd32_expand2(): fp2->enc has unacceptable value");
      break;
    }

    break;
  case FPFD_ENCB:
    switch (fp1->enc) {
    case FPFD_ENCD:
      fpfd32_to_bcd(bcd1, fp1);
      fpfd32_bcd_to_bin(bin1, bcd1);
      break;
    case FPFD_ENCB:
      fpfd32_to_bin(bin1, fp1);
      break;
    default:
      fpfd_panic("fpfd32_expand2(): fp1->enc has unacceptable value");
      break;
    }

    switch (fp2->enc) {
    case FPFD_ENCD:
      fpfd32_to_bcd(bcd2, fp2);
      fpfd32_bcd_to_bin(bin2, bcd2);
      break;
    case FPFD_ENCB:
      fpfd32_to_bin(bin2, fp2);
      break;
    default:
      fpfd_panic("fpfd32_expand2(): fp2->enc has unacceptable value");
      break;
    }

    break;
  default:
    fpfd_panic("fpfd32_expand2(): enc has unacceptable value");
    break;
  }
}
