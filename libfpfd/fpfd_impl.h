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

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Flag to designate special cases of a floating-point number.
 *   FPFD_ZERO   - The number is exactly zero. It is useful to have a separate
 *                 flag for this case, to make it easy for the multiplication
 *                 and division functions to handle cases like 0 * inf or
 *                 0 / 0.
 *   FPFD_NUMBER - The number is a nonzero real number.
 *   FPFD_SNAN   - The number is a signaling NaN.
 *   FPFD_QNAN   - The number is a quiet NaN.
 *   FPFD_INF    - The number is an infinity.
 */
typedef enum {
  FPFD_ZERO, FPFD_NUMBER, FPFD_SNAN, FPFD_QNAN, FPFD_INF
} fpfd_special_t;

/*
 * A type returned by helper functions used by arithmetic operations.
 *   FPFD_RET     - Just compress the return value and return 0.
 *   FPFD_LHS     - Compress lhs to the return value and return 0.
 *   FPFD_RHS     - Compress rhs to the return value and return 0.
 *   FPFD_OPERATE - Perform the arithmetic operation.
 */
typedef enum {
  FPFD_RET, FPFD_LHS, FPFD_RHS, FPFD_OPERATE
} fpfd_action_t;

/*
 * Factor out elements common to all fpfd*_impl_t's. This enables a single
 * helper function to handle each permutation of flags for each operation; one
 * such function for fpfd*_add, another for fpfd*_mul, etc.
 */
typedef struct {
  int exp;
  int sign;
  fpfd_special_t special;
} fpfd_impl_t;  

/*
 * These structs represent expanded versions of the coresponding fpfdX_t.
 * Each actually has room for a mantissa twice the length needed to represent a
 * fpfdX_t, so that multiplication can be done exactly.
 */

typedef struct {
  unsigned char mant[8];
  fpfd_impl_t fields;
} fpfd32_impl_t;

/*
 * These routines work on expanded fpfdX_t's. A void return type signifies that
 * the result is always exact. Otherwise, the functions return a remainder equal
 * to the truncated portion of the result. In general, this value is rounded
 * down, but a value of 0 or 5 means that the remainder was exactly 0 or 5, so
 * 0.01 rounds to 1, and 5.01 rounds to 6. A value of 10 signifies that an
 * infinity was returned. The fpfdX_*_ternN functions convert these values to
 * correct ternary values, and round the result correctly.
 *
 * These functions are implemented in assembly by the implementation library
 * for each encoding.
 */

void fpfd32_impl_expand(fpfd32_impl_t *dest, fpfd32_srcptr src);
void fpfd32_impl_compress(fpfd32_ptr dest, const fpfd32_impl_t *src);

void fpfd32_impl_inc(fpfd32_impl_t *dest);

int  fpfd32_impl_addsub(fpfd32_impl_t *dest, int sign,
                        const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs);
void fpfd32_impl_mul(fpfd32_impl_t *dest,
                     const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs);
int  fpfd32_impl_div(fpfd32_impl_t *dest,
                     const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs);

int fpfd32_impl_scale(fpfd32_impl_t *dest);

/* Help with correct rounding */

int fpfd32_impl_tern(fpfd32_impl_t *dest, int rem, fpfd_rnd_t rnd);
int fpfd32_impl_tern2(fpfd32_impl_t *dest, int rem1, int rem2,
                      fpfd_rnd_t rnd);

/* 
 * Propogate NaNs correctly.
 *
 * Returns FPFD_OPERATE if neither lhs nor rhs is NaN. If lhs is NaN, set
 * lhs->special to FPFD_QNAN, and return FPFD_LHS. Otherwise, if rhs is NaN,
 * behave analogously for rhs, returning FPFD_RHS.
 */
fpfd_action_t fpfd_impl_nanprop(fpfd_impl_t *lhs, fpfd_impl_t *rhs);

#ifdef __cplusplus
}
#endif

#endif /* FPFD_IMPL_H */
