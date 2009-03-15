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
  FPFD_RZERO, FPFD_RSIGN, FPFD_RMSIGN, FPFD_RMSIGNO
} fpfd_round_action_t;

static fpfd_round_action_t fpfd_round(fpfd_impl_t *fields, unsigned int rem,
                                      fpfd_rnd_t rnd, fpfd_flags_t *flags);

int
fpfd32_impl_round(fpfd32_impl_t *dest, unsigned int rem, fpfd_rnd_t rnd,
                  fpfd_flags_t *flags)
{
  int tern;
  fpfd_round_action_t action;

  action = fpfd_round(&dest->fields, rem, rnd, flags);

  switch (action) {
  case FPFD_RZERO:
    tern = 0;
    break;

  case FPFD_RSIGN:
    tern = dest->fields.sign;
    break;

  case FPFD_RMSIGN:
    fpfd32_impl_inc(dest);
    tern = -dest->fields.sign;
    break;

  case FPFD_RMSIGNO:
    if (fpfd32_impl_odd(dest)) {
      fpfd32_impl_inc(dest);
      tern = -dest->fields.sign;
    } else {
      tern = dest->fields.sign;
    }
    break;
  }

  return tern;
}

int
fpfd32_impl_round2(fpfd32_impl_t *dest,
                   unsigned int rem1, unsigned int rem2,
                   fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  if (rem2 & 0x20) {
    rem2 = rem1;
  } else if (((rem2 & 0xF) == 0 || (rem2 & 0xF) == 5) && (rem1 & 0xF) != 0) {
    ++rem2;
  }
  return fpfd32_impl_round(dest, rem2, rnd, flags);
}

static fpfd_round_action_t
fpfd_round(fpfd_impl_t *fields, unsigned int rem, fpfd_rnd_t rnd,
           fpfd_flags_t *flags)
{
  fpfd_round_action_t action = FPFD_RZERO;

  if (fields->special == FPFD_ZERO) {
    if (rnd == FPFD_RNDD) fields->sign = -1;
    else fields->sign = 1;
  } else if (fields->special == FPFD_NUMBER) {
    if (flags) {
      if ((rem & 0xF) != 0 && (rem & 0xF) != 10) *flags |= FPFD_INEXACT;
      if ((rem | 0x10) && rem != (10 | 0x10)) *flags |= FPFD_UNDERFLOW;
      if (rem == 10) *flags |= FPFD_OVERFLOW;
    }

    if ((rem & 0xF) == 0) {
      action = FPFD_RZERO;
    } else if (rem == 10) {
      switch (rnd) {
      case FPFD_RNDN:
      case FPFD_RNDNA:
        action = FPFD_RMSIGN;
        break;

      case FPFD_RNDZ:
        action = FPFD_RSIGN;
        break;

      case FPFD_RNDU:
        if (fields->sign > 0) {
          action = FPFD_RMSIGN;
        } else {
          action = FPFD_RSIGN;
        }
        break;

      case FPFD_RNDD:
        if (fields->sign < 0) {
          action = FPFD_RMSIGN;
        } else {
          action = FPFD_RSIGN;
        }
        break;
      }
    } else if (rem == (10 | 0x10)) {
      action = FPFD_RSIGN;
    } else {
      rem &= 0xF;

      switch (rnd) {
      case FPFD_RNDN:
        if (rem < 5) {
          action = FPFD_RSIGN;
        } else if (rem == 5) {
          action = FPFD_RMSIGNO;
        } else {
          action = FPFD_RMSIGN;
        }
        break;

      case FPFD_RNDNA:
        if (rem < 5) {
          action = FPFD_RSIGN;
        } else {
          action = FPFD_RMSIGN;
        }

      case FPFD_RNDZ:
        action = FPFD_RSIGN;
        break;

      case FPFD_RNDU:
        if (fields->sign > 0) {
          action = FPFD_RMSIGN;
        } else {
          action = FPFD_RSIGN;
        }
        break;

      case FPFD_RNDD:
        if (fields->sign < 0) {
          action = FPFD_RMSIGN;
        } else {
          action = FPFD_RSIGN;
        }
        break;
      }
    }
  }

  return action;
}
