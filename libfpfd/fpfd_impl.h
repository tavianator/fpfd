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
 * helper function to handle each permutation of special flags for each
 * operation; one such function for fpfd*_add, another for fpfd*_mul, etc.
 */
typedef struct {
  int exp;
  int sign;
  fpfd_special_t special;
} fpfd_impl_t;  

/*
 * These structs represent expanded versions of the coresponding fpfd*_t.
 * Each actually has room for a mantissa twice the length needed to represent a
 * fpfd*_t, so that multiplication can be done exactly.
 */

typedef struct {
  unsigned char mant[8];
  fpfd_impl_t fields;
} fpfd32_impl_t;

typedef struct {
  unsigned char mant[16];
  fpfd_impl_t fields;
} fpfd64_impl_t;

typedef struct {
  unsigned char mant[36];
  fpfd_impl_t fields;
} fpfd128_impl_t;

/*
 * These routines work on expanded fpfd*_t's. A void return type signifies that
 * the result is always exact. Functions which return an unsigned int return a
 * special kind of "remainder" from the operation:
 *
 * 0      - Computation was exact.
 * [1, 4] - The exact result is closer to the this one than to the next
 *          representable value.
 * 5      - The exact result is exactly in between the current value and the
 *          next representable one 
 * [6, 9] - The exact result is closer to the next representable value than it
 *          is to this one.
 * 10     - Total overflow.
 *
 * If the 0x10 bit is set, then the value has been subnormalized. 10 | 0x10
 * indicates total underflow to zero. The fpfd*_impl_roundN functions convert
 * these values to correct status flags and ternary values, and round the result
 * correctly.
 *
 * If the 0x20 bit is set, the value has not been changed, and the last
 * remainder should be used.
 *
 * These functions are implemented in assembly by the implementation library
 * for each encoding.
 */

void fpfd32_impl_expand(fpfd32_impl_t *dest, fpfd32_srcptr src);
void fpfd64_impl_expand(fpfd64_impl_t *dest, fpfd64_srcptr src);
void fpfd128_impl_expand(fpfd128_impl_t *dest, fpfd128_srcptr src);

void fpfd32_impl_compress(fpfd32_ptr dest, const fpfd32_impl_t *src);
void fpfd64_impl_compress(fpfd64_ptr dest, const fpfd64_impl_t *src);
void fpfd128_impl_compress(fpfd128_ptr dest, const fpfd128_impl_t *src);

unsigned int fpfd32_impl_addsub(fpfd32_impl_t *dest, int sign,
                                const fpfd32_impl_t *lhs,
                                const fpfd32_impl_t *rhs);
void fpfd32_impl_mul(fpfd32_impl_t *dest,
                     const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs);
void fpfd64_impl_mul(fpfd64_impl_t *dest,
                     const fpfd64_impl_t *lhs, const fpfd64_impl_t *rhs);

unsigned int fpfd32_impl_div(fpfd32_impl_t *dest, const fpfd32_impl_t *lhs,
                             const fpfd32_impl_t *rhs);

void fpfd32_impl_inc(fpfd32_impl_t *dest);
unsigned int fpfd32_impl_scale(fpfd32_impl_t *dest);

/* Help with correct rounding */

/* Round dest according to rem and rnd, and set *flags correctly */
int fpfd32_impl_round(fpfd32_impl_t *dest, unsigned int rem, fpfd_rnd_t rnd,
                      fpfd_flags_t *flags);
int fpfd32_impl_round2(fpfd32_impl_t *dest,
                       unsigned int rem1, unsigned int rem2,
                       fpfd_rnd_t rnd, fpfd_flags_t *flags);

/* Return nonzero if the mantissa is odd */
int fpfd32_impl_odd(const fpfd32_impl_t *src);

/* 
 * Propogate NaNs correctly.
 *
 * Returns FPFD_OPERATE if neither lhs nor rhs is NaN. If lhs is NaN, set
 * lhs->special to FPFD_QNAN, and return FPFD_LHS. Otherwise, if rhs is NaN,
 * behave analogously for rhs, returning FPFD_RHS.
 */
fpfd_action_t fpfd_impl_nanprop(fpfd_impl_t *lhs, fpfd_impl_t *rhs,
                                fpfd_flags_t *flags);

#ifdef __cplusplus
}
#endif

#endif /* FPFD_IMPL_H */
