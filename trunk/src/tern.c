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

/* Returns the ternary value + 1, with the 0x10 bit set if an increment call is
 * needed.
 */
static int fpfd_tern(int32_t sign, uint32_t rem, fpfd_rnd_t rnd) {
  int tern;

  if (rem == 0) {
    tern = 0x1;
  } else {
    switch (rnd) {
    case FPFD_RNDNA:
      if (rem < 5) {
        tern = 1 + sign;
      } else {
        tern = (1 - sign) | 0x10;
      }
      break;
    case FPFD_RNDZ:
      tern = 1 + sign;
      break;
    case FPFD_RNDU:
      tern = 1 - sign;
      if (sign > 0) tern |= 0x10;
      break;
    case FPFD_RNDD:
      tern = 1 + sign;
      if (sign > 0) tern |= 0x10;
      break;
    case FPFD_RNDN:
    default:
      if (rem <= 5) {
        tern = 1 + sign;
      } else {
        tern = (1 - sign) | 0x10;
      }
      break;
    }
  }

  return tern;
}

int fpfd32_bcd_tern(fpfd32_bcd_t *dest, uint32_t rem, fpfd_rnd_t rnd) {
  int tern = fpfd_tern(dest->sign, rem, rnd);
  if (tern & 0x10) fpfd32_bcd_inc(dest);
  return (tern & 0xF) - 1;
}

int fpfd32_bcd_tern2(fpfd32_bcd_t *dest, uint32_t rem1, uint32_t rem2,
                     fpfd_rnd_t rnd) {
  if ((rem2 == 0 || rem2 == 5) && rem1 != 0) ++rem2;
  return fpfd32_bcd_tern(dest, rem2, rnd);
}

int fpfd32_bin_tern(fpfd32_bin_t *dest, uint32_t rem, fpfd_rnd_t rnd) {
  int tern = fpfd_tern(dest->sign, rem, rnd);
  if (tern & 0x10) fpfd32_bin_inc(dest);
  return (tern & 0xF) - 1;
}

int fpfd32_bin_tern2(fpfd32_bin_t *dest, uint32_t rem1, uint32_t rem2,
                     fpfd_rnd_t rnd) {
  if ((rem2 == 0 || rem2 == 5) && rem1 != 0) ++rem2;
  return fpfd32_bin_tern(dest, rem2, rnd);
}
