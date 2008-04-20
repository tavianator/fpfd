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
// extern "C" {
#endif // __cplusplus

/* These structs represent expanded versions of the coresponding fpfdX_t.
 * Each actually has room for a mantissa twice the length needed to represent a
 * fpfdX_t, so that multiplication can be done exactly. fpfdX_bcd_t stores a
 * binary-coded-decimal significand, while fpfdX_bin_t stores a binary
 * significand.
 */

typedef struct {
  unsigned char mant[8];
  int32_t exp;
  int32_t sign;
} fpfd32_bcd_t;

typedef struct {
  unsigned char mant[8];
  int32_t exp;
  int32_t sign;
} fpfd32_bin_t;

typedef struct {
  unsigned char mant[16];
  int32_t exp;
  int32_t sign;
} fpfd64_bcd_t;

typedef struct {
  unsigned char mant[16];
  int32_t exp;
  int32_t sign;
} fpfd64_bin_t;

typedef struct {
  unsigned char mant[32];
  int32_t exp;
  int32_t sign;
} fpfd128_bcd_t;

typedef struct {
  unsigned char mant[32];
  int32_t exp;
  int32_t sign;
} fpfd128_bin_t;

/* These routines work on expanded fpfdX_t's. A void return type signifies that
 * the result is always exact. Otherwise, the functions return a remainder equal
 * to the truncated portion of the result. In general, this value is rounded
 * down, but a value of 0 or 5 means that the remainder was exactly 0 or 5, so
 * 0.01 rounds to 1, and 5.01 rounds to 6. This value, called R, should be
 * treated thusly (where S is the resultant sign and T is the returned ternary
 * value):
 *
 *   R == 0:     T = 0
 *
 * rnd == FPFD_RNDN || rnd == FPFD_RNDNA:
 *   0 < R < 5:  T = -1
 *   R == 5:     (rnd == FPFD_RNDN) ? T = -1 : T = 1, increment significand
 *   5 < R <= 9: T = 1, increment significand
 *
 * (S == +1 && rnd == FPFD_RNDU) || (S == -1 && rnd == FPFD_RNDD):
 *   R > 0:      T = 1, increment significand
 *
 * (S == +1 && rnd == FPFD_RNDD) || (S == -1 && rnd == FPFD_RNDU):
 *   R > 0:      T = -1
 */

/* Simple routines */

void fpfd32_to_bcd(fpfd32_bcd_t *dest, fpfd32_srcptr src);
void fpfd32_to_bin(fpfd32_bin_t *dest, fpfd32_srcptr src);

void fpfd32_from_bcd(fpfd32_ptr dest, const fpfd32_bcd_t *src);
void fpfd32_from_bin(fpfd32_ptr dest, const fpfd32_bin_t *src);

void fpfd32_bcd_inc(fpfd32_bcd_t *dest);
void fpfd32_bin_inc(fpfd32_bin_t *dest);

uint32_t fpfd32_bcd_add(fpfd32_bcd_t *dest,
                        const fpfd32_bcd_t *lhs, const fpfd32_bcd_t *rhs);
uint32_t fpfd32_bcd_sub(fpfd32_bcd_t *dest,
                        const fpfd32_bcd_t *lhs, const fpfd32_bcd_t *rhs);

void fpfd32_bin_mul(fpfd32_bin_t *dest,
                    const fpfd32_bin_t *lhs, const fpfd32_bin_t *rhs);
uint32_t fpfd32_bin_div(fpfd32_bin_t *dest,
                        const fpfd32_bin_t *lhs, const fpfd32_bin_t *rhs);

uint32_t fpfd32_bcd_normalize(fpfd32_bcd_t *dest);

/* Expensive routines */

void fpfd32_bcd_to_bin(fpfd32_bin_t *dest, const fpfd32_bcd_t *src);
uint32_t fpfd32_bin_to_bcd(fpfd32_bcd_t *dest, const fpfd32_bin_t *src);

uint32_t fpfd32_bin_add(fpfd32_bin_t *dest,
                        const fpfd32_bin_t *lhs, const fpfd32_bin_t *rhs);
uint32_t fpfd32_bin_sub(fpfd32_bin_t *dest,
                        const fpfd32_bin_t *lhs, const fpfd32_bin_t *rhs);

void fpfd32_bcd_mul(fpfd32_bcd_t *dest,
                    const fpfd32_bcd_t *lhs, const fpfd32_bcd_t *rhs);
uint32_t fpfd32_bcd_div(fpfd32_bcd_t *dest,
                        const fpfd32_bcd_t *lhs, const fpfd32_bcd_t *rhs);

uint32_t fpfd32_bin_normalize(fpfd32_bin_t *dest);

/* Help with correct rounding */

int fpfd32_bcd_tern(fpfd32_bcd_t *dest, uint32_t rem, fpfd_rnd_t rnd);
int fpfd32_bcd_tern2(fpfd32_bcd_t *dest, uint32_t rem1, uint32_t rem2,
                     fpfd_rnd_t rnd);
int fpfd32_bcd_tern2(fpfd32_bcd_t *dest, uint32_t rem1, uint32_t rem2,
                     uint32_t rem3, fpfd_rnd_t rnd);

int fpfd32_bin_tern(fpfd32_bcd_t *dest, uint32_t rem, fpfd_rnd_t rnd);
int fpfd32_bin_tern2(fpfd32_bcd_t *dest, uint32_t rem1, uint32_t rem2,
                     fpfd_rnd_t rnd);
int fpfd32_bin_tern2(fpfd32_bin_t *dest, uint32_t rem1, uint32_t rem2,
                     uint32_t rem3, fpfd_rnd_t rnd);

#ifdef __cplusplus
// }
#endif // __cplusplus

#endif // FPFD_IMPL_H
