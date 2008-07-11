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

#ifndef FPFD_IMPL_H
#define FPFD_IMPL_H

#include "fpfd.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

typedef enum {
  FPFD_ZERO, FPFD_NUMBER, FPFD_SNAN, FPFD_QNAN, FPFD_INF
} fpfd_special_t;

/* These structs represent expanded versions of the coresponding fpfdX_t.
 * Each actually has room for a mantissa twice the length needed to represent a
 * fpfdX_t, so that multiplication can be done exactly.
 */

typedef struct {
  unsigned char mant[8];
  int32_t exp;
  int32_t sign;
  fpfd_special_t special;
} fpfd32_expanded_t;

/* These routines work on expanded fpfdX_t's. A void return type signifies that
 * the result is always exact. Otherwise, the functions return a remainder equal
 * to the truncated portion of the result. In general, this value is rounded
 * down, but a value of 0 or 5 means that the remainder was exactly 0 or 5, so
 * 0.01 rounds to 1, and 5.01 rounds to 6. A value of 10 signifies that an
 * infinity was returned. The fpfdX_*_ternN functions convert these values to
 * correct ternary values, and round the result correctly.
 */

void fpfd32_expand(fpfd32_expanded_t *dest, fpfd32_srcptr src);
void fpfd32_contract(fpfd32_ptr dest, const fpfd32_expanded_t *src);

void fpfd32_impl_inc(fpfd32_expanded_t *dest);

uint32_t fpfd32_impl_addsub(fpfd32_expanded_t *dest, int32_t sign,
                            const fpfd32_expanded_t *lhs,
                            const fpfd32_expanded_t *rhs);

void fpfd32_impl_mul(fpfd32_expanded_t *dest,
                     const fpfd32_expanded_t *lhs,
                     const fpfd32_expanded_t *rhs);

uint32_t fpfd32_impl_div(fpfd32_expanded_t *dest,
                         const fpfd32_expanded_t *lhs,
                         const fpfd32_expanded_t *rhs);

uint32_t fpfd32_impl_normalize(fpfd32_expanded_t *dest);

/* Help with correct rounding */

int fpfd32_impl_tern(fpfd32_expanded_t *dest, uint32_t rem, fpfd_rnd_t rnd);
int fpfd32_impl_tern2(fpfd32_expanded_t *dest, uint32_t rem1, uint32_t rem2,
                      fpfd_rnd_t rnd);

/* Bail out of bad situations. This function doesn't return. */
void fpfd_panic(const char *error);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // FPFD_IMPL_H
