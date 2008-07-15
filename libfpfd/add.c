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

static int fpfd_add_zeros(int lhs, int rhs, fpfd_rnd_t rnd) {
  int sign;

  switch (rnd) {
  case FPFD_RNDN:
    break;
  case FPFD_RNDNA:
    break;
  case FPFD_RNDZ:
    break;
  case FPFD_RNDU:
    break;
  case FPFD_RNDD:
    break;
  }

  return sign;
}

int fpfd32_add(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd) {
  int tern = 0;
  fpfd32_expanded_t rop, op1, op2;

  fpfd32_impl_expand(&op1, lhs);
  fpfd32_impl_expand(&op2, rhs);

  if (fpfd32_impl_nanprop(&rop, &op1, &op2) == 0) {
    switch (op1.special) {
    case FPFD_ZERO:
      switch (op2.special) {
      case FPFD_ZERO:
        rop.sign = fpfd_add_zeros(op1.sign, op2.sign, rnd);
        rop.special = FPFD_ZERO;
        break;
      case FPFD_NUMBER:
      case FPFD_INF:
        memcpy(&rop, &op2, sizeof(fpfd32_expanded_t));
        break;
      }
      break;

    case FPFD_NUMBER:
      switch (op2.special) {
      case FPFD_ZERO:
        memcpy(&rop, &op2, sizeof(fpfd32_expanded_t));
        break;
      case FPFD_NUMBER:
        int rem1 = fpfd32_impl_addsub(&rop, 1, &op1, &op2);
        int rem2 = fpfd32_impl_normalize(&rop);
        tern = fpfd32_impl_tern2(&rop, rem1, rem2, rnd);
      case FPFD_INF:
        memcpy(&rop, &op2, sizeof(fpfd32_expanded_t));
        break;
      }
      break;

    case FPFD_INF:
      memcpy(&rop, &op21, sizeof(fpfd32_expanded_t));
      break;
    }
  }

  fpfd32_impl_contract(dest, &rop);
  return tern;
}
