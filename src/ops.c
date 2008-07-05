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
  int tern = 0;
  uint32_t rem1, rem2;
  fpfd32_bcd_t bcd, bcd1, bcd2;
  fpfd32_bin_t bin, bin1, bin2;

  fpfd32_expand2(lhs, rhs, &bcd1, &bcd2, &bin1, &bin2, enc);

  switch (enc) {
  case FPFD_ENCD:
    if (fpfd32_bcd_nanprop(&bcd, &bcd1, &bcd2) == 0) {
      if (bcd1.special == bcd2.special) {
        switch (bcd1.special) {
        case FPFD_NUMBER:
          rem1 = fpfd32_bcd_addsub(&bcd, 1, &bcd1, &bcd2);
          rem2 = fpfd32_bcd_normalize(&bcd);
          tern = fpfd32_bcd_tern2(&bcd, rem1, rem2, rnd);
          break;
        case FPFD_INF:
          if (bcd1.sign == bcd2.sign) {
            bcd.sign = bcd1.sign;
            bcd.special = FPFD_INF;
          } else {
            bcd.special = FPFD_QNAN;
          }
          break;
        default:
          fpfd_panic("fpfd32_add(): Wrong bcd*.special value");
        }
      } else {
        if (bcd1.special == FPFD_INF) {
          bcd.sign = bcd1.sign;
          bcd.special = FPFD_INF;
        } else if (bcd2.special == FPFD_INF) {
          bcd.sign = bcd2.sign;
          bcd.special = FPFD_INF;
        } else {
          fpfd_panic("fpfd32_add(): One of bcd1.special or bcd2.special "
                     "should be FPFD_INF");
        }
      }
    }

    fpfd32_from_bcd(dest, &bcd);
    break;
  case FPFD_ENCB:
    if (fpfd32_bin_nanprop(&bin, &bin1, &bin2) == 0) {
      if (bin1.special == bin2.special) {
        switch (bin1.special) {
        case FPFD_NUMBER:
          rem1 = fpfd32_bin_addsub(&bin, 1, &bin1, &bin2);
          rem2 = fpfd32_bin_normalize(&bin);
          tern = fpfd32_bin_tern2(&bin, rem1, rem2, rnd);
          break;
        case FPFD_INF:
          if (bin1.sign == bin2.sign) {
            bin.sign = bin1.sign;
            bin.special = FPFD_INF;
          } else {
            bin.special = FPFD_QNAN;
          }
          break;
        default:
          fpfd_panic("fpfd32_add(): Wrong bin*.special value");
        }
      } else {
        if (bin1.special == FPFD_INF) {
          bin.sign = bin1.sign;
          bin.special = FPFD_INF;
        } else if (bin2.special == FPFD_INF) {
          bin.sign = bin2.sign;
          bin.special = FPFD_INF;
        } else {
          fpfd_panic("fpfd32_add(): One of bin1.special or bin2.special "
                     "should be FPFD_INF");
        }
      }
    }

    fpfd32_from_bin(dest, &bin);
    break;
  default:
    fpfd_panic("fpfd32_add(): Wrong enc value");
  }

  return tern;
}

int fpfd32_sub(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd, fpfd_enc_t enc) {
  int tern = 0;
  uint32_t rem1, rem2;
  fpfd32_bcd_t bcd, bcd1, bcd2;
  fpfd32_bin_t bin, bin1, bin2;

  fpfd32_expand2(lhs, rhs, &bcd1, &bcd2, &bin1, &bin2, enc);

  switch (enc) {
  case FPFD_ENCD:
    if (fpfd32_bcd_nanprop(&bcd, &bcd1, &bcd2) == 0) {
      if (bcd1.special == bcd2.special) {
        switch (bcd1.special) {
        case FPFD_NUMBER:
          rem1 = fpfd32_bcd_addsub(&bcd, -1, &bcd1, &bcd2);
          rem2 = fpfd32_bcd_normalize(&bcd);
          tern = fpfd32_bcd_tern2(&bcd, rem1, rem2, rnd);
          break;
        case FPFD_INF:
          if (bcd1.sign != bcd2.sign) {
            bcd.sign = bcd1.sign;
            bcd.special = FPFD_INF;
          } else {
            bcd.special = FPFD_QNAN;
          }
          break;
        default:
          fpfd_panic("fpfd32_sub(): Wrong bcd*.special value");
        }
      } else {
        if (bcd1.special == FPFD_INF) {
          bcd.sign = bcd1.sign;
          bcd.special = FPFD_INF;
        } else if (bcd2.special == FPFD_INF) {
          bcd.sign = -bcd2.sign;
          bcd.special = FPFD_INF;
        } else {
          fpfd_panic("fpfd32_sub(): One of bcd1.special or bcd2.special "
                     "should be FPFD_INF");
        }
      }
    }

    fpfd32_from_bcd(dest, &bcd);
    break;
  case FPFD_ENCB:
    if (fpfd32_bin_nanprop(&bin, &bin1, &bin2)) {
      if (bin1.special == bin2.special) {
        switch (bin1.special) {
        case FPFD_NUMBER:
          rem1 = fpfd32_bin_addsub(&bin, -1, &bin1, &bin2);
          rem2 = fpfd32_bin_normalize(&bin);
          tern = fpfd32_bin_tern2(&bin, rem1, rem2, rnd);
          break;
        case FPFD_INF:
          if (bin1.sign != bin2.sign) {
            bin.sign = bin1.sign;
            bin.special = FPFD_INF;
          } else {
            bin.special = FPFD_QNAN;
          }
          break;
        default:
          fpfd_panic("fpfd32_sub(): Wrong bin*.special value");
        }
      } else {
        if (bin1.special == FPFD_INF) {
          bin.sign = bin1.sign;
          bin.special = FPFD_INF;
        } else if (bin2.special == FPFD_INF) {
          bin.sign = -bin2.sign;
          bin.special = FPFD_INF;
        } else {
          fpfd_panic("fpfd32_sub(): One of bin1.special or bin2.special "
                     "should be FPFD_INF");
        }
      }
    }

    fpfd32_from_bin(dest, &bin);
    break;
  default:
    fpfd_panic("fpfd32_sub(): Wrong enc value");
  }

  return tern;
}
