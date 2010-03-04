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
#include <assert.h>

static fpfd_action_t fpfd_sub_action(fpfd_impl_t *rop,
                                     fpfd_impl_t *op1, fpfd_impl_t *op2,
                                     fpfd_rnd_t rnd, fpfd_flags_t *flags);

int
fpfd32_sub(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
           fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  int tern = 0;
  unsigned int rem1, rem2;
  fpfd32_impl_t rop, op1, op2;

  fpfd32_impl_expand(&op1, lhs);
  fpfd32_impl_expand(&op2, rhs);

  switch (fpfd_sub_action(&rop.fields, &op1.fields, &op2.fields, rnd, flags)) {
  case FPFD_RET:
    fpfd32_impl_compress(dest, &rop);
    break;
  case FPFD_LHS:
    fpfd32_impl_compress(dest, &op1);
    break;
  case FPFD_RHS:
    fpfd32_impl_compress(dest, &op2);
    break;
  case FPFD_OPERATE:
    rem1 = fpfd32_impl_addsub(&rop, -1, &op1, &op2);
    rem2 = fpfd32_impl_scale(&rop);
    tern = fpfd32_impl_round2(&rop, rem1, rem2, rnd, flags);
    fpfd32_impl_compress(dest, &rop);
    break;
  }

  return tern;
}

static fpfd_action_t
fpfd_sub_action(fpfd_impl_t *rop, fpfd_impl_t *op1, fpfd_impl_t *op2,
                fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  fpfd_action_t action = fpfd_impl_nanprop(op1, op2, flags);

  if (action == FPFD_OPERATE) { /* a NaN was not propagated */
    switch (op1->special) {
    case FPFD_ZERO:
      switch (op2->special) {
      case FPFD_ZERO:
        if (op1->sign != op2->sign) {
          rop->sign = op1->sign;
        } else if (rnd == FPFD_RNDD) {
          rop->sign = -1;
        } else {
          rop->sign = 1;
        }
        rop->special = FPFD_ZERO;
        action = FPFD_RET;
        break;

      case FPFD_NUMBER:
      case FPFD_INF:
        action = FPFD_RHS;
        break;

      default:
        assert(0);
        break;
      }
      break;

    case FPFD_NUMBER:
      switch (op2->special) {
      case FPFD_ZERO:
        action = FPFD_LHS;
        break;

      case FPFD_NUMBER:
        action = FPFD_OPERATE;
        break;

      case FPFD_INF:
        action = FPFD_RHS;
        break;

      default:
        assert(0);
        break;
      }
      break;

    case FPFD_INF:
      switch (op2->special) {
      case FPFD_ZERO:
      case FPFD_NUMBER:
        action = FPFD_LHS;
        break;

      case FPFD_INF:
        if (op1->sign == op2->sign) {
          rop->special = FPFD_QNAN;
          action = FPFD_RET;
          if (flags) *flags |= FPFD_INVALID;
        } else {
          action = FPFD_LHS;
        }
        break;

      default:
        assert(0);
        break;
      }
      break;

    default:
      assert(0);
      break;
    }
  }

  return action;
}
