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

/*
 * These routines override libgcc's decimal arithmetic routines with FPFD
 * library routines. Thus, programmers can use FPFD via the extension types
 * _Decimal32, _Decimal64, _Decimal128.
 */

#include "../libfpfd/fpfd.h"
#include <stdlib.h>          /* For NULL */

typedef union {
  fpfd32_t fpfd;
  _Decimal32 dec;
} fpfd32_union_t;

_Decimal32
__bid_addsd3(_Decimal32 lhs, _Decimal32 rhs)
{
  fpfd32_union_t ret_cast, lhs_cast, rhs_cast;
  lhs_cast.dec = lhs;
  rhs_cast.dec = rhs;

  fpfd32_add(ret_cast.fpfd, lhs_cast.fpfd, rhs_cast.fpfd, FPFD_RNDN, NULL);
  return ret_cast.dec;
}

_Decimal32
__bid_subsd3(_Decimal32 lhs, _Decimal32 rhs)
{
  fpfd32_union_t ret_cast, lhs_cast, rhs_cast;
  lhs_cast.dec = lhs;
  rhs_cast.dec = rhs;

  fpfd32_sub(ret_cast.fpfd, lhs_cast.fpfd, rhs_cast.fpfd, FPFD_RNDN, NULL);
  return ret_cast.dec;
}

_Decimal32
__bid_mulsd3(_Decimal32 lhs, _Decimal32 rhs)
{
  fpfd32_union_t ret_cast, lhs_cast, rhs_cast;
  lhs_cast.dec = lhs;
  rhs_cast.dec = rhs;

  fpfd32_mul(ret_cast.fpfd, lhs_cast.fpfd, rhs_cast.fpfd, FPFD_RNDN, NULL);
  return ret_cast.dec;
}

_Decimal32
__bid_divsd3(_Decimal32 lhs, _Decimal32 rhs)
{
  fpfd32_union_t ret_cast, lhs_cast, rhs_cast;
  lhs_cast.dec = lhs;
  rhs_cast.dec = rhs;

  fpfd32_div(ret_cast.fpfd, lhs_cast.fpfd, rhs_cast.fpfd, FPFD_RNDN, NULL);
  return ret_cast.dec;
}

_Decimal32
__bid_negsd2(_Decimal32 src)
{
  fpfd32_union_t cast;
  cast.dec = src;

  fpfd32_neg(cast.fpfd, cast.fpfd);
  return cast.dec;
}
