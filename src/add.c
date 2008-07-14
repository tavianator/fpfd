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
               fpfd_rnd_t rnd) {
  int tern = 0;
  int rem1, rem2;
  fpfd32_expanded_t rop, op1, op2;

  fpfd32_impl_expand(&op1, lhs);
  fpfd32_impl_expand(&op2, rhs);

  if (op1.fields.special == FPFD_NUMBER && op2.fields.special == FPFD_NUMBER) {
    rem1 = fpfd32_impl_addsub(&rop, 1, &op1, &op2);
    rem2 = fpfd32_impl_normalize(&rop);
    tern = fpfd32_impl_tern2(&rop, rem1, rem2, rnd);
  } else {
    if (fpfd32_impl_nanprop(&rop, &op1, &op2) == 0) {
      fpfd_add_zeros(&rop.fields, &op1.fields, &op2.fields);
      fpfd_
    }
  }

  fpfd32_impl_contract(dest, &rop);

  return tern;
}
