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

int
fpfd32_fma(fpfd32_ptr dest, fpfd32_srcptr a, fpfd32_srcptr b, fpfd32_srcptr c,
           fpfd_rnd_t rnd, fpfd_flags_t *flags)
{
  int tern;
  unsigned int rem1, rem2;
  fpfd32_t temp;
  fpfd32_impl_t rop, op1, op2, op3;

  fpfd32_impl_expand(&op1, a);
  fpfd32_impl_expand(&op2, b);
  fpfd32_impl_expand(&op3, c);

  if (op1.fields.special == FPFD_NUMBER && op2.fields.special == FPFD_NUMBER
      && op3.fields.special == FPFD_NUMBER) {
    fpfd32_impl_mul(&rop, &op1, &op2);
    rem1 = fpfd32_impl_addsub(&rop, 1, &rop, &op3);
    rem2 = fpfd32_impl_scale(&rop);
    tern = fpfd32_impl_round2(&rop, rem1, rem2, rnd, flags);
    fpfd32_impl_compress(dest, &rop);
  } else {
    fpfd32_mul(temp, a, b, FPFD_RNDZ, flags);
    tern = fpfd32_add(dest, temp, c, rnd, flags);
  }

  return tern;
}
