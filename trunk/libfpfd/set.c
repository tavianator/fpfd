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
#include <string.h> /* For memmove */

/* ---   HACKS   --- */

int
fpfd32_set_ui(fpfd32_ptr dest, unsigned long src, fpfd_rnd_t rnd,
              fpfd_flags_t *flags)
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

void
fpfd64_impl_mul(fpfd64_impl_t *dest,
                const fpfd64_impl_t *lhs, const fpfd64_impl_t *rhs)
{
}

/* --- END HACKS --- */

void
fpfd32_set(fpfd32_ptr dest, fpfd32_srcptr src)
{
  memmove(dest, src, sizeof(fpfd32_struct_t));
}

void fpfd32_set_zero(fpfd32_ptr dest) {
  fpfd32_set_ui(dest, 0, FPFD_RNDNA, NULL);
}

void fpfd32_set_one(fpfd32_ptr dest) {
  fpfd32_set_ui(dest, 1, FPFD_RNDNA, NULL);
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
