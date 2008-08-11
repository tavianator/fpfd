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
#include <stdlib.h> /* For EXIT_SUCCESS */

#define fpfd32_check_op(op, res, lhs, rhs, rnd, sign, special)  \
  fpfd32_##op(res, lhs, rhs, rnd);                              \
  fpfd32_assert_ss2(res, lhs, rhs, rnd, sign, special, #op)

void fpfd32_check_add(fpfd_rnd_t rnd);
void fpfd32_check_sub(fpfd_rnd_t rnd);
void fpfd32_check_mul(fpfd_rnd_t rnd);
void fpfd32_check_div(fpfd_rnd_t rnd);

/*
 * Check all operations which either produce a signed zero, or behave
 * differently depending on the sign of a zero operand.
 */
int
main()
{
  fpfd32_check_add(FPFD_RNDN);
  fpfd32_check_add(FPFD_RNDNA);
  fpfd32_check_add(FPFD_RNDZ);
  fpfd32_check_add(FPFD_RNDU);
  fpfd32_check_add(FPFD_RNDD);

  fpfd32_check_sub(FPFD_RNDN);
  fpfd32_check_sub(FPFD_RNDNA);
  fpfd32_check_sub(FPFD_RNDZ);
  fpfd32_check_sub(FPFD_RNDU);
  fpfd32_check_sub(FPFD_RNDD);

  fpfd32_check_mul(FPFD_RNDN);
  fpfd32_check_mul(FPFD_RNDNA);
  fpfd32_check_mul(FPFD_RNDZ);
  fpfd32_check_mul(FPFD_RNDU);
  fpfd32_check_mul(FPFD_RNDD);

  fpfd32_check_div(FPFD_RNDN);
  fpfd32_check_div(FPFD_RNDNA);
  fpfd32_check_div(FPFD_RNDZ);
  fpfd32_check_div(FPFD_RNDU);
  fpfd32_check_div(FPFD_RNDD);

  return EXIT_SUCCESS;
}

void
fpfd32_check_add(fpfd_rnd_t rnd)
{
  fpfd32_t pz; /* Positive zero */
  fpfd32_t nz; /* Negative zero */

  fpfd32_t res; /* Result */

  fpfd32_set_zero(pz);
  fpfd32_set_neg_zero(nz);

  if (rnd == FPFD_RNDD) {
    fpfd32_check_op(add, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd32_check_op(add, res, pz, nz, rnd, -1, FPFD_ZERO);
    fpfd32_check_op(add, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd32_check_op(add, res, nz, nz, rnd, -1, FPFD_ZERO);
  } else {
    fpfd32_check_op(add, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd32_check_op(add, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd32_check_op(add, res, nz, pz, rnd, 1, FPFD_ZERO);
    fpfd32_check_op(add, res, nz, nz, rnd, -1, FPFD_ZERO);
  }
}

void
fpfd32_check_sub(fpfd_rnd_t rnd)
{
  fpfd32_t pz; /* Positive zero */
  fpfd32_t nz; /* Negative zero */

  fpfd32_t res; /* Result */

  fpfd32_set_zero(pz);
  fpfd32_set_neg_zero(nz);

  if (rnd == FPFD_RNDD) {
    fpfd32_check_op(sub, res, pz, pz, rnd, -1, FPFD_ZERO);
    fpfd32_check_op(sub, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd32_check_op(sub, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd32_check_op(sub, res, nz, nz, rnd, -1, FPFD_ZERO);
  } else {
    fpfd32_check_op(sub, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd32_check_op(sub, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd32_check_op(sub, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd32_check_op(sub, res, nz, nz, rnd, 1, FPFD_ZERO);
  }
}

void
fpfd32_check_mul(fpfd_rnd_t rnd)
{
  fpfd32_t pz; /* Positive zero */
  fpfd32_t po; /* Positive one  */
  fpfd32_t nz; /* Negative zero */
  fpfd32_t no; /* Negative one  */

  fpfd32_t res; /* Result */

  fpfd32_set_zero(pz);
  fpfd32_set_one(po);
  fpfd32_set_neg_zero(nz);
  fpfd32_set_neg_one(no);

  fpfd32_check_op(mul, res, pz, pz, rnd, 1, FPFD_ZERO);
  fpfd32_check_op(mul, res, pz, nz, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(mul, res, nz, pz, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(mul, res, nz, nz, rnd, 1, FPFD_ZERO);

  fpfd32_check_op(mul, res, pz, po, rnd, 1, FPFD_ZERO);
  fpfd32_check_op(mul, res, pz, no, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(mul, res, nz, po, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(mul, res, nz, no, rnd, 1, FPFD_ZERO);

  fpfd32_check_op(mul, res, po, pz, rnd, 1, FPFD_ZERO);
  fpfd32_check_op(mul, res, po, nz, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(mul, res, no, pz, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(mul, res, no, nz, rnd, 1, FPFD_ZERO);
}

void
fpfd32_check_div(fpfd_rnd_t rnd)
{
  fpfd32_t pz; /* Positive zero     */
  fpfd32_t po; /* Positive one      */
  fpfd32_t pi; /* Positive infinity */
  fpfd32_t nz; /* Negative zero     */
  fpfd32_t no; /* Negative one      */
  fpfd32_t ni; /* Negative infinity */

  fpfd32_t res; /* Result */

  fpfd32_set_zero(pz);
  fpfd32_set_one(po);
  fpfd32_set_inf(pi);
  fpfd32_set_neg_zero(nz);
  fpfd32_set_neg_one(no);
  fpfd32_set_neg_inf(ni);

  fpfd32_check_op(div, res, pz, po, rnd, 1, FPFD_ZERO);
  fpfd32_check_op(div, res, pz, no, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(div, res, nz, po, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(div, res, nz, no, rnd, 1, FPFD_ZERO);

  fpfd32_check_op(div, res, pz, pi, rnd, 1, FPFD_ZERO);
  fpfd32_check_op(div, res, pz, ni, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(div, res, nz, pi, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(div, res, nz, ni, rnd, 1, FPFD_ZERO);

  fpfd32_check_op(div, res, po, pz, rnd, 1, FPFD_INF);
  fpfd32_check_op(div, res, po, nz, rnd, -1, FPFD_INF);
  fpfd32_check_op(div, res, no, pz, rnd, -1, FPFD_INF);
  fpfd32_check_op(div, res, no, nz, rnd, 1, FPFD_INF);

  fpfd32_check_op(div, res, po, pi, rnd, 1, FPFD_ZERO);
  fpfd32_check_op(div, res, po, ni, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(div, res, no, pi, rnd, -1, FPFD_ZERO);
  fpfd32_check_op(div, res, no, ni, rnd, 1, FPFD_ZERO);

  fpfd32_check_op(div, res, pi, pz, rnd, 1, FPFD_INF);
  fpfd32_check_op(div, res, pi, nz, rnd, -1, FPFD_INF);
  fpfd32_check_op(div, res, ni, pz, rnd, -1, FPFD_INF);
  fpfd32_check_op(div, res, ni, nz, rnd, 1, FPFD_INF);
}
