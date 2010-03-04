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

static fpfd_action_t fpfd_div_action(fpfd_impl_t *rop,
                                     fpfd_impl_t *op1, fpfd_impl_t *op2,
                                     fpfd_flags_t *flags);

int
fpfd32_div(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
           fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  int tern = 0;
  unsigned int rem1, rem2;
  fpfd32_impl_t rop, op1, op2;

  fpfd32_impl_expand(&op1, lhs);
  fpfd32_impl_expand(&op2, rhs);

  switch (fpfd_div_action(&rop.fields, &op1.fields, &op2.fields, flags)) {
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
    rem1 = fpfd32_impl_div(&rop, &op1, &op2);
    rem2 = fpfd32_impl_scale(&rop);
    tern = fpfd32_impl_round2(&rop, rem1, rem2, rnd, flags);
    fpfd32_impl_compress(dest, &rop);
    break;
  }

  return tern;
}

static int
fpfd_div_sign(fpfd_impl_t *op1, fpfd_impl_t *op2) {
  if (op1->sign == op2->sign) {
    return 1;
  } else {
    return -1;
  }
  /* return op1->sign ^ op2->sign ^ 1; */
}

static fpfd_action_t
fpfd_div_action(fpfd_impl_t *rop, fpfd_impl_t *op1, fpfd_impl_t *op2,
                fpfd_flags_t *flags)
{
  fpfd_action_t action = fpfd_impl_nanprop(op1, op2, flags);

  if (action == FPFD_OPERATE) { /* a NaN was not propagated */
    switch (op1->special) {
    case FPFD_ZERO:
      switch (op2->special) {
      case FPFD_ZERO:
        rop->special = FPFD_QNAN;
        action = FPFD_RET;
        if (flags) *flags |= FPFD_INVALID;
        break;

      case FPFD_NUMBER:
      case FPFD_INF:
        rop->sign = fpfd_div_sign(op1, op2);
        rop->special = FPFD_ZERO;
        action = FPFD_RET;
        break;

      default:
        assert(0);
        break;
      }
      break;

    case FPFD_NUMBER:
      switch (op2->special) {
      case FPFD_ZERO:
        rop->sign = fpfd_div_sign(op1, op2);
        rop->special = FPFD_INF;
        action = FPFD_RET;
        if (flags) *flags |= FPFD_DIVBYZERO;
        break;

      case FPFD_NUMBER:
        action = FPFD_OPERATE;
        break;
      case FPFD_INF:
        rop->sign = fpfd_div_sign(op1, op2);
        rop->special = FPFD_ZERO;
        action = FPFD_RET;
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
        rop->sign = fpfd_div_sign(op1, op2);
        rop->special = FPFD_INF;
        action = FPFD_RET;
        break;

      case FPFD_INF:
        rop->special = FPFD_QNAN;
        action = FPFD_RET;
        if (flags) *flags |= FPFD_INVALID;
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
