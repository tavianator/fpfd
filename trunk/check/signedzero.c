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
#include <stdio.h>  /* For fprintf, stderr */
#include <stdlib.h> /* For EXIT_SUCCESS    */

void fpfd_check_add(fpfd_rnd_t rnd);
void fpfd_check_sub(fpfd_rnd_t rnd);
void fpfd_check_mul(fpfd_rnd_t rnd);
void fpfd_check_div(fpfd_rnd_t rnd);

/*
 * Check all operations which either produce a signed zero, or behave
 * differently depending on the sign of a zero operand.
 */
int
main()
{
  fpfd_check_add(FPFD_RNDN);
  fpfd_check_add(FPFD_RNDNA);
  fpfd_check_add(FPFD_RNDZ);
  fpfd_check_add(FPFD_RNDU);
  fpfd_check_add(FPFD_RNDD);

  fpfd_check_sub(FPFD_RNDN);
  fpfd_check_sub(FPFD_RNDNA);
  fpfd_check_sub(FPFD_RNDZ);
  fpfd_check_sub(FPFD_RNDU);
  fpfd_check_sub(FPFD_RNDD);

  fpfd_check_mul(FPFD_RNDN);
  fpfd_check_mul(FPFD_RNDNA);
  fpfd_check_mul(FPFD_RNDZ);
  fpfd_check_mul(FPFD_RNDU);
  fpfd_check_mul(FPFD_RNDD);

  fpfd_check_div(FPFD_RNDN);
  fpfd_check_div(FPFD_RNDNA);
  fpfd_check_div(FPFD_RNDZ);
  fpfd_check_div(FPFD_RNDU);
  fpfd_check_div(FPFD_RNDD);

  return EXIT_SUCCESS;
}

/* Rather than write this out every time... */
#define fpfd_check_op(op, res, lhs, rhs, rnd, sign, special)            \
  fpfd32_##op(res##32, lhs##32, rhs##32, rnd);                          \
  fpfd32_assert(res##32, lhs##32, rhs##32, rnd, sign, special, #op)

void
fpfd32_assert(fpfd32_srcptr res, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
              fpfd_rnd_t rnd, int sign, fpfd_special_t special,
              const char *op)
{
  if (!fpfd32_check_sign(res, sign) || !fpfd32_check_special(res, special)) {
    fpfd32_impl_t res_impl, lhs_impl, rhs_impl;
    fpfd32_impl_expand(&res_impl, res);
    fpfd32_impl_expand(&lhs_impl, lhs);
    fpfd32_impl_expand(&rhs_impl, rhs);

    fprintf(stderr, "\nfpfd32_%s(", op);
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &res_impl);
    fprintf(stderr, ", ");
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &lhs_impl);
    fprintf(stderr, ", ");
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &rhs_impl);
    fprintf(stderr, ", %s);\n", fpfd_rnd_str(rnd));
    fprintf(stderr, "\n--- ERROR: Expected sign == %d, special == %s ---\n\n",
            sign, fpfd_special_str(special));
    exit(EXIT_FAILURE);
  }
}

void
fpfd_check_add(fpfd_rnd_t rnd)
{
  fpfd32_t pz32; /* Positive zero */
  fpfd32_t nz32; /* Negative zero */

  fpfd32_t res32; /* Result */

  fpfd32_set_zero(pz32);
  fpfd32_set_neg_zero(nz32);

  if (rnd == FPFD_RNDD) {
    fpfd_check_op(add, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd_check_op(add, res, pz, nz, rnd, -1, FPFD_ZERO);
    fpfd_check_op(add, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd_check_op(add, res, nz, nz, rnd, -1, FPFD_ZERO);
  } else {
    fpfd_check_op(add, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd_check_op(add, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd_check_op(add, res, nz, pz, rnd, 1, FPFD_ZERO);
    fpfd_check_op(add, res, nz, nz, rnd, -1, FPFD_ZERO);
  }
}

void
fpfd_check_sub(fpfd_rnd_t rnd)
{
  fpfd32_t pz32; /* Positive zero */
  fpfd32_t nz32; /* Negative zero */

  fpfd32_t res32; /* Result */

  fpfd32_set_zero(pz32);
  fpfd32_set_neg_zero(nz32);

  if (rnd == FPFD_RNDD) {
    fpfd_check_op(sub, res, pz, pz, rnd, -1, FPFD_ZERO);
    fpfd_check_op(sub, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd_check_op(sub, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd_check_op(sub, res, nz, nz, rnd, -1, FPFD_ZERO);
  } else {
    fpfd_check_op(sub, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd_check_op(sub, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd_check_op(sub, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd_check_op(sub, res, nz, nz, rnd, 1, FPFD_ZERO);
  }
}

void
fpfd_check_mul(fpfd_rnd_t rnd)
{
  fpfd32_t pz32; /* Positive zero */
  fpfd32_t po32; /* Positive one  */
  fpfd32_t nz32; /* Negative zero */
  fpfd32_t no32; /* Negative one  */

  fpfd32_t res32; /* Result */

  fpfd32_set_zero(pz32);
  fpfd32_set_one(po32);
  fpfd32_set_neg_zero(nz32);
  fpfd32_set_neg_one(no32);

  fpfd_check_op(mul, res, pz, pz, rnd, 1, FPFD_ZERO);
  fpfd_check_op(mul, res, pz, nz, rnd, -1, FPFD_ZERO);
  fpfd_check_op(mul, res, nz, pz, rnd, -1, FPFD_ZERO);
  fpfd_check_op(mul, res, nz, nz, rnd, 1, FPFD_ZERO);

  fpfd_check_op(mul, res, pz, po, rnd, 1, FPFD_ZERO);
  fpfd_check_op(mul, res, pz, no, rnd, -1, FPFD_ZERO);
  fpfd_check_op(mul, res, nz, po, rnd, -1, FPFD_ZERO);
  fpfd_check_op(mul, res, nz, no, rnd, 1, FPFD_ZERO);

  fpfd_check_op(mul, res, po, pz, rnd, 1, FPFD_ZERO);
  fpfd_check_op(mul, res, po, nz, rnd, -1, FPFD_ZERO);
  fpfd_check_op(mul, res, no, pz, rnd, -1, FPFD_ZERO);
  fpfd_check_op(mul, res, no, nz, rnd, 1, FPFD_ZERO);
}

void
fpfd_check_div(fpfd_rnd_t rnd)
{
  fpfd32_t pz32; /* Positive zero     */
  fpfd32_t po32; /* Positive one      */
  fpfd32_t pi32; /* Positive infinity */
  fpfd32_t nz32; /* Negative zero     */
  fpfd32_t no32; /* Negative one      */
  fpfd32_t ni32; /* Negative infinity */

  fpfd32_t res32; /* Result */

  fpfd32_set_zero(pz32);
  fpfd32_set_one(po32);
  fpfd32_set_inf(pi32);
  fpfd32_set_neg_zero(nz32);
  fpfd32_set_neg_one(no32);
  fpfd32_set_neg_inf(ni32);

  fpfd_check_op(div, res, pz, po, rnd, 1, FPFD_ZERO);
  fpfd_check_op(div, res, pz, no, rnd, -1, FPFD_ZERO);
  fpfd_check_op(div, res, nz, po, rnd, -1, FPFD_ZERO);
  fpfd_check_op(div, res, nz, no, rnd, 1, FPFD_ZERO);

  fpfd_check_op(div, res, pz, pi, rnd, 1, FPFD_ZERO);
  fpfd_check_op(div, res, pz, ni, rnd, -1, FPFD_ZERO);
  fpfd_check_op(div, res, nz, pi, rnd, -1, FPFD_ZERO);
  fpfd_check_op(div, res, nz, ni, rnd, 1, FPFD_ZERO);

  fpfd_check_op(div, res, po, pz, rnd, 1, FPFD_INF);
  fpfd_check_op(div, res, po, nz, rnd, -1, FPFD_INF);
  fpfd_check_op(div, res, no, pz, rnd, -1, FPFD_INF);
  fpfd_check_op(div, res, no, nz, rnd, 1, FPFD_INF);

  fpfd_check_op(div, res, po, pi, rnd, 1, FPFD_ZERO);
  fpfd_check_op(div, res, po, ni, rnd, -1, FPFD_ZERO);
  fpfd_check_op(div, res, no, pi, rnd, -1, FPFD_ZERO);
  fpfd_check_op(div, res, no, ni, rnd, 1, FPFD_ZERO);

  fpfd_check_op(div, res, pi, pz, rnd, 1, FPFD_INF);
  fpfd_check_op(div, res, pi, nz, rnd, -1, FPFD_INF);
  fpfd_check_op(div, res, ni, pz, rnd, -1, FPFD_INF);
  fpfd_check_op(div, res, ni, nz, rnd, 1, FPFD_INF);
}
