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
#include <stdint.h> /* For uint8_t */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

typedef enum {
  FPFD_ZERO, FPFD_NUMBER, FPFD_SNAN, FPFD_QNAN, FPFD_INF
} fpfd_special_t;

/* These structs represent expanded versions of the coresponding fpfdX_t.
 * Each actually has room for a mantissa twice the length needed to represent a
 * fpfdX_t, so that multiplication can be done exactly.
 */

typedef struct {
  uint8_t mant[8];
  int exp;
  int sign;
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

void fpfd32_impl_expand(fpfd32_expanded_t *dest, fpfd32_srcptr src);
void fpfd32_impl_contract(fpfd32_ptr dest, const fpfd32_expanded_t *src);

void fpfd32_impl_inc(fpfd32_expanded_t *dest);

int fpfd32_impl_addsub(fpfd32_expanded_t *dest, int sign,
                       const fpfd32_expanded_t *lhs,
                       const fpfd32_expanded_t *rhs);

void fpfd32_impl_mul(fpfd32_expanded_t *dest,
                     const fpfd32_expanded_t *lhs,
                     const fpfd32_expanded_t *rhs);

int fpfd32_impl_div(fpfd32_expanded_t *dest,
                    const fpfd32_expanded_t *lhs,
                    const fpfd32_expanded_t *rhs);

int fpfd32_impl_normalize(fpfd32_expanded_t *dest);

/* Help with correct rounding */

int fpfd32_impl_tern(fpfd32_expanded_t *dest, int rem, fpfd_rnd_t rnd);
int fpfd32_impl_tern2(fpfd32_expanded_t *dest, int rem1, int rem2,
                      fpfd_rnd_t rnd);

/* Propogate NaNs correctly.
 * Returns 0 if neither lhs nor rhs is NaN (either sNaN or qNaN), 1 if lhs is
 * NaN, or 2 if rhs is NaN. If a NaN is detected, it is propogated to dest.
 */
int fpfd32_impl_nanprop(fpfd32_expanded_t *dest,
                        const fpfd32_expanded_t *lhs,
                        const fpfd32_expanded_t *rhs);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* FPFD_IMPL_H */
