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

#include "../libfpfd/fpfd.h"
#include "../libfpfd/fpfd_impl.h"
#include <stdio.h>  /* For FILE     */
#include <stdint.h> /* For uint32_t */

/* Rather than write these out for every operand width */

#define fpfd_declare(var)                        \
  fpfd32_t var##32
  /*
   * fpfd64_t var##64
   * fpfd128_t var##128
   */

#define fpfd_impl_declare(var)                   \
  fpfd32_impl_t var##32
  /*
   * fpfd64_impl_t var##64
   * fpfd128_impl_t var##128
   */

#define fpfd_set(dest, op)                      \
  fpfd32_set_##op(dest##32)
  /*
   * fpfd64_set_##op(dest##64)
   * fpfd128_set_##op(dest##64)
   */

/*
 * These macros assert things about an fpfd*_t. On assertion failure, they print
 * a diagnostic, and set exitstatus to EXIT_FAILURE.
 *
 * They are of the form fpfd_assert_*. The * is composed of the following tokens
 * which, along with their order, indicate the rest of the macro's parameters as
 * described.
 *
 *   o  - The next argument is the name of the fpfd function, without the fpfd*_
 *        prefix, which produced the result. This function is called before the
 *        assertion, with the resultant operand, and possibly the a1 or a2 and m
 *        operands. It is also written in the diagnostic.
 *   r  - The name of the resultant operand, as passed to fpfd_declare. These
 *        variables are checked against the assertion made by the macro.
 *   a1 - The next argument is the name of the second, source operand in the
 *        unary function which produced the result.
 *   a2 - The next two arguments are the name of the two source operands in the
 *        binary function which produced the result.
 *   m  - The next argument is the rounding mode used in the operation which
 *        produced the result.
 *   e  - The next argument is an int, and the exponent of the result is
 *        asserted to be equal to it.
 *   s  - The next argument is an int, and the sign of the result is asserted
 *        to be equal to it.
 *   f  - The next argument is an fpfd_special_t, and the special flag of the
 *        result is asserted to be equal to it.
 *
 * To save space here, only those macros used by tests are defined.
 */

#define fpfd_assert_ora2msf(op, res, arg1, arg2, rnd, sign, special)    \
  fpfd32_##op(res##32, arg1##32, arg2##32, rnd);                        \
  fpfd32_assert_ora2msf(#op, res##32, arg1##32, arg2##32, rnd, sign, special)
  /*
   * fpfd64_##op(res##64, arg1##64, arg2##64, rnd);
   * fpfd64_assert_ora2msf(#op, res##64, arg1##64, arg2##64, rnd,
   *                       sign, special);
   * fpfd128_##op(res##128, arg1##128, arg2##128, rnd);
   * fpfd128_assert_ora2msf(#op, res##128, arg1##128, arg2##128, rnd,
   *                        sign, special);
   */

/* main() should return this */
extern int exitstatus;

/*
 * Assertion functions, called by assertion macros. Don't call these directly.
 */

void fpfd32_assert_ora2msf(const char *op, fpfd32_srcptr res, fpfd32_srcptr op1,
                           fpfd32_srcptr op2, fpfd_rnd_t rnd, int sign,
                           fpfd_special_t special);

/*
 * For more manual checking. Call these directly.
 */

/* Conversion to/from uint32_t's. Obviously, this is encoding dependant. */

void fpfd32_set_manually(fpfd32_ptr dest, uint32_t src);
void fpfd32_get_manually(uint32_t *dest, fpfd32_srcptr src);

void fpfd32_impl_set_manually(fpfd32_impl_t *dest, uint32_t h, uint32_t l);
void fpfd32_impl_get_manually(uint32_t *h, uint32_t *l,
                              const fpfd32_impl_t *src);

int fpfd32_impl_check_mant(const fpfd32_impl_t *impl, uint32_t h, uint32_t l);
int fpfd32_check_mant(fpfd32_srcptr src, uint32_t mant);
int fpfd32_check_exp(fpfd32_srcptr src, int exp);
int fpfd32_check_sign(fpfd32_srcptr src, int sign);
int fpfd32_check_special(fpfd32_srcptr src, fpfd_special_t special);
int fpfd32_check_manually(fpfd32_srcptr src, uint32_t mask, uint32_t cmp);

/*
 * Functions to write fpfd-related things to a stream.
 */
const char *fpfd_rnd_str(fpfd_rnd_t rnd);
const char *fpfd_special_str(fpfd_special_t special);
void fpfd32_dump(FILE *file, fpfd32_srcptr fp);
void fpfd32_impl_dump(FILE *file, const fpfd32_impl_t *fp);
