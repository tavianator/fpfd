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
 * The return value of this function indicates:
 *   FPFD_RZERO   - Return zero.
 *   FPFD_RSIGN   - Return sign.
 *   FPFD_RMSIGN  - Call fpfd*_impl_inc(), and return -sign.
 *   FPFD_RMSIGNO - If fpfd*_impl_odd(), call fpfd*_impl_inc() and return -sign;
 *                  otherwise, return sign.
 */

typedef enum {
  FPFD_RZERO = 0, FPFD_RSIGN = 1, FPFD_RMSIGN = 2, FPFD_RMSIGNO = 3
} fpfd_round_action_t;

static fpfd_round_action_t fpfd_round(int sign, unsigned int rem,
                                      fpfd_rnd_t rnd, fpfd_flags_t *flags);

int
fpfd32_impl_round(fpfd32_impl_t *dest, unsigned int rem, fpfd_rnd_t rnd,
                  fpfd_flags_t *flags)
{
  int sign;
  fpfd_round_action_t action;

  sign = dest->fields.sign;
  action = fpfd_round(sign, rem, rnd, flags);

  switch (action) {
  case FPFD_RZERO:
    return 0;

  case FPFD_RSIGN:
    return sign;

  case FPFD_RMSIGN:
    fpfd32_impl_inc(dest);
    return -sign;

  case FPFD_RMSIGNO:
    if (fpfd32_impl_odd(dest)) {
      fpfd32_impl_inc(dest);
      return -sign;
    } else {
      return sign;
    }
  }
}

int
fpfd32_impl_round2(fpfd32_impl_t *dest,
                   unsigned int rem1, unsigned int rem2,
                   fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  if (((rem2 & 0xF) == 0 || (rem2 & 0xF) == 5) && (rem1 & 0xF) != 0) ++rem2;
  return fpfd32_impl_round(dest, rem2, rnd, flags);
}

static fpfd_round_action_t
fpfd_round(int sign, unsigned int rem, fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  if (flags) {
    if ((rem & 0xF) != 0 && (rem & 0xF) != 10) *flags |= FPFD_INEXACT;
    if ((rem | 0x10) && rem != (10 | 0x10)) *flags |= FPFD_UNDERFLOW;
    if (rem == 10) *flags |= FPFD_OVERFLOW;
  }

  if ((rem & 0xF) == 0) {
    return FPFD_RZERO;
  } else if (rem == 10) {
    switch (rnd) {
    case FPFD_RNDN:
    case FPFD_RNDNA:
      return FPFD_RMSIGN;

    case FPFD_RNDZ:
      return FPFD_RSIGN;

    case FPFD_RNDU:
      if (sign > 0)
        return FPFD_RMSIGN;
      else
        return FPFD_RSIGN;

    case FPFD_RNDD:
      if (sign < 0)
        return FPFD_RMSIGN;
      else
        return FPFD_RSIGN;
    }
  } else if (rem == (10 | 0x10)) {
    return FPFD_RSIGN;
  } else {
    rem &= 0xF;

    switch (rnd) {
    case FPFD_RNDN:
      if (rem < 5) {
        return FPFD_RSIGN;
      } else if (rem == 5) {
        return FPFD_RMSIGNO;
      } else {
        return FPFD_RMSIGN;
      }

    case FPFD_RNDNA:
      if (rem < 5) {
        return FPFD_RSIGN;
      } else {
        return FPFD_RMSIGN;
      }

    case FPFD_RNDZ:
      return FPFD_RSIGN;
      break;

    case FPFD_RNDU:
      if (sign > 0)
        return FPFD_RMSIGN;
      else
        return FPFD_RSIGN;

    case FPFD_RNDD:
      if (sign < 0)
        return FPFD_RMSIGN;
      else
        return FPFD_RSIGN;
    }
  }
}
