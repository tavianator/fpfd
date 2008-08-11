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
#include <stdlib.h>    /* For EXIT_SUCCESS, EXIT_FAILURE */
#include <stdio.h>     /* For fprintf, stderr            */
#include <inttypes.h>  /* For PRI... macros              */
#include <arpa/inet.h> /* For htonl()                    */

static const char *
fpfd_rnd_str(fpfd_rnd_t rnd)
{
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

static const char *
fpfd_special_str(fpfd_special_t special)
{
  switch (special) {
  case FPFD_ZERO:
    return "FPFD_ZERO";
  case FPFD_NUMBER:
    return "FPFD_NUMBER";
  case FPFD_SNAN:
    return "FPFD_SNAN";
  case FPFD_QNAN:
    return "FPFD_QNAN";
  case FPFD_INF:
    return "FPFD_INF";
  }
  return NULL;
}

static void
fpfd32_dump(FILE *file, fpfd32_srcptr fp)
{
  fprintf(file, "0x%.8" PRIX32, *fp);
}

static void
fpfd32_dump_impl(FILE *file, fpfd32_srcptr fp)
{
  fpfd32_impl_t impl;
  fpfd32_impl_expand(&impl, fp);

  uint32_t l, h; /* Low and high 32 bits of fp.mant */

  if (htonl(1) != 1) { /* Little-endian */
    l = *((uint32_t *)impl.mant);
    h = *(((uint32_t *)impl.mant) + 1);
  } else {             /* Big-endian    */
    l = *(((uint32_t *)impl.mant) + 1);
    h = *((uint32_t *)impl.mant);
  }

  fprintf(file,
          "{\n  mant    = 0x%.8" PRIX32 "%.8" PRIX32 "\n"
          "  exp     = %d\n"
          "  sign    = %+d\n"
          "  special = %s\n}",
          h, l, impl.fields.exp, impl.fields.sign,
          fpfd_special_str(impl.fields.special));
}

static void
fpfd32_dump_op2(FILE *file,
                fpfd32_srcptr res, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
                fpfd_rnd_t rnd, const char *op)
{
  fprintf(file, "fpfd32_%s(", op);

  fpfd32_dump(file, res);
  fprintf(file, " = ");
  fpfd32_dump_impl(file, res);
  fprintf(file, ", ");

  fpfd32_dump(file, lhs);
  fprintf(file, " = ");
  fpfd32_dump_impl(file, lhs);
  fprintf(file, ", ");

  fpfd32_dump(file, rhs);
  fprintf(file, " = ");
  fpfd32_dump_impl(file, rhs);
  fprintf(file, ", %s);\n\n", fpfd_rnd_str(rnd));
}

void
fpfd32_assert_ss2(fpfd32_srcptr res, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
                  fpfd_rnd_t rnd, int sign, fpfd_special_t special,
                  const char *op) {
  fpfd32_impl_t impl;
  fpfd32_impl_expand(&impl, res);

  if (impl.fields.sign != sign || impl.fields.special != special) {
    fpfd32_dump_op2(stderr, res, lhs, rhs, rnd, op);
    fprintf(stderr, "--- ERROR: expected sign == %d, special == %s ---\n\n",
            impl.fields.sign, fpfd_special_str(special));
    exit(EXIT_FAILURE);
  }
}
