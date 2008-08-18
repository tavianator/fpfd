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

void
fpfd32_set(fpfd32_ptr dest, fpfd32_srcptr src)
{
  /* Don't just memcpy, because we should canonicalize non-canonical inputs */
  fpfd32_impl_t rop;
  fpfd32_impl_expand(&rop, src);
  fpfd32_impl_compress(dest, &rop);
}

void fpfd32_set_zero(fpfd32_ptr dest) {
  fpfd32_set_ui(dest, 0, FPFD_RNDNA);
}

void fpfd32_set_one(fpfd32_ptr dest) {
  fpfd32_set_ui(dest, 1, FPFD_RNDNA);
}

void fpfd32_set_inf(fpfd32_ptr dest) {
  fpfd32_impl_t impl;
  impl.fields.sign = 1;
  impl.fields.special = FPFD_INF;
  fpfd32_impl_compress(dest, &impl);
}

void fpfd32_set_neg_zero(fpfd32_ptr dest) {
  fpfd32_set_zero(dest);
  fpfd32_neg(dest, dest);
}

void fpfd32_set_neg_one(fpfd32_ptr dest) {
  fpfd32_set_one(dest);
  fpfd32_neg(dest, dest);
}

void fpfd32_set_neg_inf(fpfd32_ptr dest) {
  fpfd32_set_inf(dest);
  fpfd32_neg(dest, dest);
}
