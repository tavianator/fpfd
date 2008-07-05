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
#include <string.h> // For memcpy

int fpfd32_bcd_nanprop(fpfd32_bcd_t *bcd,
                       fpfd32_bcd_t *bcd1, fpfd32_bcd_t *bcd2) {
  if (bcd1->special == FPFD_SNAN || bcd1->special == FPFD_QNAN) {
    memcpy(bcd->mant, bcd1->mant, 8);
    bcd->sign = bcd1->sign;
    bcd->special = FPFD_QNAN;
    return 1;
  }

  if (bcd2->special == FPFD_SNAN || bcd2->special == FPFD_QNAN) {
    memcpy(bcd->mant, bcd2->mant, 8);
    bcd->sign = bcd2->sign;
    bcd->special = FPFD_QNAN;
    return 2;
  }

  return 0;
}

int fpfd32_bin_nanprop(fpfd32_bin_t *bin,
                       fpfd32_bin_t *bin1, fpfd32_bin_t *bin2) {
  if (bin1->special == FPFD_SNAN || bin1->special == FPFD_QNAN) {
    memcpy(bin->mant, bin1->mant, 8);
    bin->sign = bin1->sign;
    bin->special = FPFD_QNAN;
    return 1;
  }

  if (bin2->special == FPFD_SNAN || bin2->special == FPFD_QNAN) {
    memcpy(bin->mant, bin2->mant, 8);
    bin->sign = bin2->sign;
    bin->special = FPFD_QNAN;
    return 2;
  }

  return 0;
}
