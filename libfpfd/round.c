/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library.                                *
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

/*
 * Returns the ternary value + 1, with the 0x10 bit set if an increment call is
 * needed.
 */
static int fpfd_round(int sign, unsigned int rem, fpfd_rnd_t rnd,
                      fpfd_flags_t *flags);

int
fpfd32_impl_round(fpfd32_impl_t *dest, unsigned int rem, fpfd_rnd_t rnd,
                  fpfd_flags_t *flags)
{
  int tern = fpfd_round(dest->fields.sign, rem, rnd, flags);
  if (tern & 0x10) fpfd32_impl_inc(dest);
  return (tern & 0xF) - 1;
}

int
fpfd32_impl_round2(fpfd32_impl_t *dest,
                   unsigned int rem1, unsigned int rem2,
                   fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  if (((rem2 & 0xF) == 0 || (rem2 & 0xF) == 5) && (rem1 & 0xF) != 0) ++rem2;
  return fpfd32_impl_round(dest, rem2, rnd, flags);
}

static int
fpfd_round(int sign, unsigned int rem, fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  int tern;

  if (flags) {
    if ((rem & 0xF) != 0 && (rem & 0xF) != 10) *flags |= FPFD_INEXACT;
    if ((rem | 0x10) && (rem & 0xF) != 10) *flags |= FPFD_UNDERFLOW;
    if (rem == 10) *flags |= FPFD_OVERFLOW;
  }

  rem &= 0xF;

  if (rem == 0) {
    tern = 0x1;
  } else if (rem == 10) {
    tern = 1 - sign;

    switch (rnd) {
    case FPFD_RNDN:
    case FPFD_RNDNA:
      tern |= 0x10;
      break;

    case FPFD_RNDZ:
      break;

    case FPFD_RNDU:
      if (sign > 0) tern |= 0x10;
      break;

    case FPFD_RNDD:
      if (sign < 0) tern |= 0x10;
      break;
    }
  } else {
    switch (rnd) {
    case FPFD_RNDN:
      if (rem <= 5) {
        tern = 1 + sign;
      } else {
        tern = (1 - sign) | 0x10;
      }
      break;

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
      if (sign < 0) tern |= 0x10;
      break;
    }
  }

  return tern;
}
