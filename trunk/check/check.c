/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library Test Suite                      *
 *                                                                       *
 * The FPFD Library Test Suite is free software; you can redistribute it *
 * and/or modify it under the terms of the GNU General Public License as *
 * published by the Free Software Foundation; either version 3 of the    *
 * License, or (at your option) any later version.                       *
 *                                                                       *
 * The FPFD Library Test Suite is distributed in the hope that it will   *
 * be useful, but WITHOUT ANY WARRANTY; without even the implied         *
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See *
 * the GNU General Public License for more details.                      *
 *                                                                       *
 * You should have received a copy of the GNU General Public License     *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *************************************************************************/

#include "check.h"
#include <stdlib.h> /* For EXIT_SUCCESS, EXIT_FAILURE */
#include <stdio.h>  /* For fprintf, stderr            */

void fpfd32_set_pos_zero(fpfd32_ptr dest) {
  fpfd32_set_ui(dest, 0ul);
}

void fpfd32_set_pos_one(fpfd32_ptr dest) {
  fpfd32_set_ui(dest, 1ul);
}

void fpfd32_set_pos_inf(fpfd32_ptr dest) {
  fpfd32_impl_t rop;
  rop.fields.special = FPFD_INF;
  rop.fields.sign    = 1;
  fpfd32_impl_compress(dest, &rop);
}

void fpfd32_set_neg_zero(fpfd32_ptr dest) {
  fpfd32_set_pos_zero(dest);
  fpfd32_neg(dest, dest);
}

void fpfd32_set_neg_one(fpfd32_ptr dest) {
  fpfd32_set_pos_one(dest);
  fpfd32_neg(dest, dest);
}

void fpfd32_set_neg_inf(fpfd32_ptr dest) {
  fpfd32_set_pos_inf(dest);
  fpfd32_neg(dest, dest);
}

static void fpfd32_dump(FILE *file, fpfd32_srcptr fp) {
  fprintf(file, "0x%X", *fp);
}

static const char *fpfd_rnd_str(fpfd_rnd_t rnd) {
  switch (rnd) {
  case FPFD_RNDN:
    return "FPFD_RNDN";
  case FPFD_RNDNA:
    return "FPFD_RNDNA";
  case FPFD_RNDZ:
    return "FPFD_RNDZ";
  case FPFD_RNDU:
    return "FPFD_RNDU";
  case FPFD_RNDD:
    return "FPFD_RNDD";
  }
  return NULL;
}

void
fpfd32_assert_special(fpfd32_srcptr lhs, fpfd32_srcptr rhs, fpfd32_srcptr res,
                      fpfd_special_t special, const char *err, fpfd_rnd_t rnd)
{
  fpfd32_impl_t op;
  fpfd32_impl_expand(&op, res);

  if (op.fields.special != special) {
    fprintf(stderr, "%s (%s)\n", err, fpfd_rnd_str(rnd));
    fpfd32_dump(stderr, lhs);
    fprintf(stderr, " @ ");
    fpfd32_dump(stderr, rhs);
    fprintf(stderr, " == ");
    fpfd32_dump(stderr, res);
    fprintf(stderr, "\n");
    exit(EXIT_FAILURE);
  }
}

void
fpfd32_assert_sign(fpfd32_srcptr lhs, fpfd32_srcptr rhs, fpfd32_srcptr res,
                   int sign, const char *err, fpfd_rnd_t rnd)
{
  fpfd32_impl_t op;
  fpfd32_impl_expand(&op, res);

  if (op.fields.sign != sign) {
    fprintf(stderr, "%s (%s)\n", err, fpfd_rnd_str(rnd));
    fpfd32_dump(stderr, lhs);
    fprintf(stderr, " @ ");
    fpfd32_dump(stderr, rhs);
    fprintf(stderr, " == ");
    fpfd32_dump(stderr, res);
    fprintf(stderr, "\n");
    exit(EXIT_FAILURE);
  }
}
