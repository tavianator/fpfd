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

/* ---   HACKS   --- */

#include <string.h> /* For memset */

int
fpfd32_set_ui(fpfd32_ptr dest, unsigned long src, fpfd_rnd_t rnd)
{
  fpfd32_impl_t impl;

  memset(impl.mant, 0, 8);
  if (src == 0) {
    impl.fields.exp = 0;
    impl.fields.sign = 1;
    impl.fields.special = FPFD_ZERO;
  } else {
    memset(impl.mant, 1, 1); /* Only works on little-endian */
    impl.fields.exp = 0;
    impl.fields.sign = 1;
    impl.fields.special = FPFD_NUMBER;
  }
  fpfd32_impl_compress(dest, &impl);

  return 0;
}

int
fpfd32_impl_addsub(fpfd32_impl_t *dest, int sign,
                   const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs)
{
  return 0;
}

void
fpfd32_impl_mul(fpfd32_impl_t *dest,
                const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs)
{
}

int
fpfd32_impl_div(fpfd32_impl_t *dest,
                const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs)
{
  return 0;
}

/* --- END HACKS --- */

void
fpfd32_set(fpfd32_ptr dest, fpfd32_srcptr src)
{
  /* Don't just memmove, because we should canonicalize non-canonical inputs */
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
