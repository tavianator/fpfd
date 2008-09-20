/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library Test Suite.                     *
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
#include <string.h>    /* For memcpy                     */
#include <inttypes.h>  /* For PRI... macros              */
#include <arpa/inet.h> /* For htonl()                    */

int exitstatus = EXIT_SUCCESS;

/* Assertions */

void
fpfd32_assert_ora2msf(const char *op, fpfd32_srcptr res, fpfd32_srcptr op1,
                      fpfd32_srcptr op2, fpfd_rnd_t rnd, int sign,
                      fpfd_special_t special)
{
  fpfd32_impl_t res_impl, op1_impl, op2_impl;

  fpfd32_impl_expand(&res_impl, res);

  if (res_impl.fields.sign != sign || res_impl.fields.special != special) {
    fpfd32_impl_expand(&op1_impl, op1);
    fpfd32_impl_expand(&op2_impl, op2);

    fprintf(stderr, "\nfpfd32_%s(", op);
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &res_impl);
    fprintf(stderr, ", ");
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &op1_impl);
    fprintf(stderr, ", ");
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &op2_impl);
    fprintf(stderr, ", %s);\n", fpfd_rnd_str(rnd));
    fprintf(stderr, "\n--- ERROR: Expected sign == %d, special == %s ---\n\n",
            sign, fpfd_special_str(special));
    exitstatus = EXIT_FAILURE;
  }
}

void
fpfd32_assert_rf(fpfd32_srcptr res, fpfd_special_t special)
{
  fpfd32_impl_t res_impl;

  fpfd32_impl_expand(&res_impl, res);

  if (res_impl.fields.special != special) {
    fprintf(stderr, "\n");
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &res_impl);
    fprintf(stderr, "\n\n--- ERROR: Expected special == %s ---\n\n",
            fpfd_special_str(special));
    exitstatus = EXIT_FAILURE;
  }
}

void
fpfd32_impl_assert_ore(const char *op, const fpfd32_impl_t *res, int exp)
{
  if (res->fields.exp != exp) {
    fprintf(stderr, "\nfpfd32_%s(", op);
    fpfd32_impl_dump(stderr, res);
    fprintf(stderr, ");\n\n--- ERROR: Expected exp == %d ---\n\n", exp);
    exitstatus = EXIT_FAILURE;
  }
}

/* Get/set manually */

void
fpfd32_set_manually(fpfd32_ptr dest, uint32_t src)
{
  memcpy(dest, &src, 4);
}

void
fpfd32_get_manually(uint32_t *dest, fpfd32_srcptr src)
{
  memcpy(dest, src, 4);
}

void
fpfd32_impl_set_manually(fpfd32_impl_t *dest, uint32_t h, uint32_t l)
{
  if (htonl(1) == 1) { /* Big-endian    */
    memcpy(dest->mant, &h, 4);
    memcpy(dest->mant + 4, &l, 4);
  } else {             /* Little-endian */
    memcpy(dest->mant, &l, 4);
    memcpy(dest->mant + 4, &h, 4);
  }
}

void
fpfd32_impl_get_manually(uint32_t *h, uint32_t *l, const fpfd32_impl_t *src)
{
  if (htonl(1) == 1) { /* Big-endian    */
    memcpy(h, src->mant, 4);
    memcpy(l, src->mant + 4, 4);
  } else {             /* Little-endian */
    memcpy(l, src->mant, 4);
    memcpy(h, src->mant + 4, 4);
  }
}

/* Manual assertions */

void
fpfd32_assert_mant(fpfd32_srcptr res, uint32_t src)
{
  fpfd32_impl_t res_impl;
  uint32_t h, l;

  fpfd32_impl_expand(&res_impl, res);
  fpfd32_impl_get_manually(&h, &l, &res_impl);

  if (h != UINT32_C(0) || l != src) {
    fprintf(stderr, "\n");
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &res_impl);
    fprintf(stderr, "\n\n--- ERROR: Expected mant == 0x%.16" PRIX32 " ---\n\n",
            src);
    exitstatus = EXIT_FAILURE;
  }
}

void
fpfd32_assert_manually(fpfd32_srcptr res, uint32_t src)
{
  uint32_t test;

  fpfd32_get_manually(&test, res);

  if (test != src) {
    fprintf(stderr, "\n");
    fpfd32_dump(stderr, res);
    fprintf(stderr, "\n\n--- ERROR: Expected op == 0x%.8" PRIX32 " ---\n\n",
            src);
    exitstatus = EXIT_FAILURE;
  }
}

void
fpfd32_assert_mask(fpfd32_srcptr res, uint32_t mask, uint32_t cmp)
{
  uint32_t test;

  fpfd32_get_manually(&test, res);

  if ((test & mask) != cmp) {
    fprintf(stderr, "\n");
    fpfd32_dump(stderr, res);
    fprintf(stderr, "\n\n--- ERROR: Expected (op & 0x%.8" PRIX32 ") "
                    "== 0x%.8" PRIX32 " ---\n\n",
            mask, cmp);
    exitstatus = EXIT_FAILURE;
  }
}

void fpfd32_impl_assert_mant(const fpfd32_impl_t *res, uint32_t h, uint32_t l)
{
  uint32_t impl_h, impl_l;

  fpfd32_impl_get_manually(&impl_h, &impl_l, res);

  if (impl_h != h || impl_l != l) {
    fprintf(stderr, "\n");
    fpfd32_impl_dump(stderr, res);
    fprintf(stderr, "\n\n--- ERROR: Expected mant == 0x%.8" PRIX32 "%.8" PRIX32
                    " ---\n\n",
            h, l);
    exitstatus = EXIT_FAILURE;
  }
}

/* Display */

const char *
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

const char *
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

void
fpfd32_dump(FILE *file, fpfd32_srcptr fp)
{
  fprintf(file, "0x%.8" PRIX32, *fp);
}

void
fpfd32_impl_dump(FILE *file, const fpfd32_impl_t *impl)
{
  uint32_t l, h; /* Low and high 32 bits of fp.mant */

  if (htonl(1) != 1) { /* Little-endian */
    l = *((uint32_t *)impl->mant);
    h = *(((uint32_t *)impl->mant) + 1);
  } else {             /* Big-endian    */
    l = *(((uint32_t *)impl->mant) + 1);
    h = *((uint32_t *)impl->mant);
  }

  fprintf(file, "{\n"
          "  mant    = 0x%.8" PRIX32 "%.8" PRIX32 "\n"
          "  exp     = %+d\n"
          "  sign    = %+d\n"
          "  special = %s\n}",
          h, l, impl->fields.exp, impl->fields.sign,
          fpfd_special_str(impl->fields.special));
}
