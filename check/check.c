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
#include <string.h>    /* For memcpy                     */
#include <inttypes.h>  /* For PRI... macros              */
#include <arpa/inet.h> /* For htonl()                    */

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

/* Checks */

int
fpfd32_impl_check_mant(const fpfd32_impl_t *impl, uint32_t h, uint32_t l)
{
  if (htonl(1) == 1) { /* Big-endian    */
    return memcmp(impl->mant, &h, 4) == 0
      && memcmp(impl->mant + 4, &l, 4) == 0;
  } else {             /* Little-endian */
    return memcmp(impl->mant, &l, 4) == 0
      && memcmp(impl->mant + 4, &h, 4) == 0;
  }
}

int
fpfd32_check_mant(fpfd32_srcptr src, uint32_t mant)
{
  uint32_t zero = 0x0;
  fpfd32_impl_t impl;
  fpfd32_impl_expand(&impl, src);

  if (htonl(1) == 1) { /* Big-endian    */
    return memcmp(impl.mant, &zero, 4) == 0
      && memcmp(impl.mant + 4, &mant, 4) == 0;
  } else {             /* Little-endian */
    return memcmp(impl.mant, &mant, 4) == 0
      && memcmp(impl.mant + 4, &zero, 4) == 0;
  }
}

int
fpfd32_check_exp(fpfd32_srcptr src, int exp)
{
  fpfd32_impl_t impl;
  fpfd32_impl_expand(&impl, src);
  return impl.fields.exp == exp;
}

int
fpfd32_check_sign(fpfd32_srcptr src, int sign)
{
  fpfd32_impl_t impl;
  fpfd32_impl_expand(&impl, src);
  return impl.fields.sign == sign;
}

int
fpfd32_check_special(fpfd32_srcptr src, fpfd_special_t special)
{
  fpfd32_impl_t impl;
  fpfd32_impl_expand(&impl, src);
  return impl.fields.special == special;
}

int
fpfd32_check_manually(fpfd32_srcptr src, uint32_t mask, uint32_t cmp)
{
  uint32_t test;
  fpfd32_get_manually(&test, src);
  return (test & mask) == cmp;
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
          "  exp     = %d\n"
          "  sign    = %+d\n"
          "  special = %s\n}",
          h, l, impl->fields.exp, impl->fields.sign,
          fpfd_special_str(impl->fields.special));
}
