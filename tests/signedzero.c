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

#include "test.h"
#include <stdio.h>  /* For fprintf, stderr */
#include <stdlib.h> /* For EXIT_SUCCESS    */

void signedzero_check_add(fpfd_rnd_t rnd);
void signedzero_check_sub(fpfd_rnd_t rnd);
void signedzero_check_mul(fpfd_rnd_t rnd);
void signedzero_check_div(fpfd_rnd_t rnd);

/*
 * Check all operations which either produce a signed zero, or behave
 * differently depending on the sign of a zero operand.
 */
int
main()
{
  signedzero_check_add(FPFD_RNDN);
  signedzero_check_add(FPFD_RNDNA);
  signedzero_check_add(FPFD_RNDZ);
  signedzero_check_add(FPFD_RNDU);
  signedzero_check_add(FPFD_RNDD);

  signedzero_check_sub(FPFD_RNDN);
  signedzero_check_sub(FPFD_RNDNA);
  signedzero_check_sub(FPFD_RNDZ);
  signedzero_check_sub(FPFD_RNDU);
  signedzero_check_sub(FPFD_RNDD);

  signedzero_check_mul(FPFD_RNDN);
  signedzero_check_mul(FPFD_RNDNA);
  signedzero_check_mul(FPFD_RNDZ);
  signedzero_check_mul(FPFD_RNDU);
  signedzero_check_mul(FPFD_RNDD);

  signedzero_check_div(FPFD_RNDN);
  signedzero_check_div(FPFD_RNDNA);
  signedzero_check_div(FPFD_RNDZ);
  signedzero_check_div(FPFD_RNDU);
  signedzero_check_div(FPFD_RNDD);

  return exitstatus;
}

void
signedzero_check_add(fpfd_rnd_t rnd)
{
  fpfd_flags_t flags;
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(nz); /* Negative zero */
  fpfd_declare(po); /* Positive one */
  fpfd_declare(no); /* Negative one */

  fpfd_declare(res); /* Result */

  fpfd_set(pz, zero);
  fpfd_set(nz, neg_zero);
  fpfd_set(po, one);
  fpfd_set(no, neg_one);

  if (rnd == FPFD_RNDD) {
    fpfd_assert_ora2msfx(add, res, pz, pz, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, pz, nz, rnd, -1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, nz, pz, rnd, -1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, nz, nz, rnd, -1, FPFD_ZERO, FPFD_NONE);

    fpfd_assert_ora2msfx(add, res, po, no, rnd, -1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, no, po, rnd, -1, FPFD_ZERO, FPFD_NONE);
  } else {
    fpfd_assert_ora2msfx(add, res, pz, pz, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, pz, nz, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, nz, pz, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, nz, nz, rnd, -1, FPFD_ZERO, FPFD_NONE);

    fpfd_assert_ora2msfx(add, res, po, no, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(add, res, no, po, rnd, 1, FPFD_ZERO, FPFD_NONE);
  }
}

void
signedzero_check_sub(fpfd_rnd_t rnd)
{
  fpfd_flags_t flags;
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(nz); /* Negative zero */
  fpfd_declare(po); /* Positive one */
  fpfd_declare(no); /* Negative one */

  fpfd_declare(res); /* Result */

  fpfd_set(pz, zero);
  fpfd_set(nz, neg_zero);
  fpfd_set(po, one);
  fpfd_set(no, neg_one);

  if (rnd == FPFD_RNDD) {
    fpfd_assert_ora2msfx(sub, res, pz, pz, rnd, -1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, pz, nz, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, nz, pz, rnd, -1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, nz, nz, rnd, -1, FPFD_ZERO, FPFD_NONE);

    fpfd_assert_ora2msfx(sub, res, po, po, rnd, -1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, no, no, rnd, -1, FPFD_ZERO, FPFD_NONE);
  } else {
    fpfd_assert_ora2msfx(sub, res, pz, pz, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, pz, nz, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, nz, pz, rnd, -1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, nz, nz, rnd, 1, FPFD_ZERO, FPFD_NONE);

    fpfd_assert_ora2msfx(sub, res, po, po, rnd, 1, FPFD_ZERO, FPFD_NONE);
    fpfd_assert_ora2msfx(sub, res, no, no, rnd, 1, FPFD_ZERO, FPFD_NONE);
  }
}

void
signedzero_check_mul(fpfd_rnd_t rnd)
{
  fpfd_flags_t flags;
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(po); /* Positive one  */
  fpfd_declare(nz); /* Negative zero */
  fpfd_declare(no); /* Negative one  */

  fpfd_declare(res); /* Result */

  fpfd_set(pz, zero);
  fpfd_set(po, one);
  fpfd_set(nz, neg_zero);
  fpfd_set(no, neg_one);

  fpfd_assert_ora2msfx(mul, res, pz, pz, rnd, 1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, pz, nz, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, nz, pz, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, nz, nz, rnd, 1, FPFD_ZERO, FPFD_NONE);

  fpfd_assert_ora2msfx(mul, res, pz, po, rnd, 1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, pz, no, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, nz, po, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, nz, no, rnd, 1, FPFD_ZERO, FPFD_NONE);

  fpfd_assert_ora2msfx(mul, res, po, pz, rnd, 1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, po, nz, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, no, pz, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(mul, res, no, nz, rnd, 1, FPFD_ZERO, FPFD_NONE);
}

void
signedzero_check_div(fpfd_rnd_t rnd)
{
  fpfd_flags_t flags;
  fpfd_declare(pz); /* Positive zero     */
  fpfd_declare(po); /* Positive one      */
  fpfd_declare(pi); /* Positive infinity */
  fpfd_declare(nz); /* Negative zero     */
  fpfd_declare(no); /* Negative one      */
  fpfd_declare(ni); /* Negative infinity */

  fpfd_declare(res); /* Result */

  fpfd_set(pz, zero);
  fpfd_set(po, one);
  fpfd_set(pi, inf);
  fpfd_set(nz, neg_zero);
  fpfd_set(no, neg_one);
  fpfd_set(ni, neg_inf);

  fpfd_assert_ora2msfx(div, res, pz, po, rnd, 1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, pz, no, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, nz, po, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, nz, no, rnd, 1, FPFD_ZERO, FPFD_NONE);

  fpfd_assert_ora2msfx(div, res, pz, pi, rnd, 1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, pz, ni, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, nz, pi, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, nz, ni, rnd, 1, FPFD_ZERO, FPFD_NONE);

  fpfd_assert_ora2msfx(div, res, po, pz, rnd, 1, FPFD_INF, FPFD_DIVBYZERO);
  fpfd_assert_ora2msfx(div, res, po, nz, rnd, -1, FPFD_INF, FPFD_DIVBYZERO);
  fpfd_assert_ora2msfx(div, res, no, pz, rnd, -1, FPFD_INF, FPFD_DIVBYZERO);
  fpfd_assert_ora2msfx(div, res, no, nz, rnd, 1, FPFD_INF, FPFD_DIVBYZERO);

  fpfd_assert_ora2msfx(div, res, po, pi, rnd, 1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, po, ni, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, no, pi, rnd, -1, FPFD_ZERO, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, no, ni, rnd, 1, FPFD_ZERO, FPFD_NONE);

  fpfd_assert_ora2msfx(div, res, pi, pz, rnd, 1, FPFD_INF, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, pi, nz, rnd, -1, FPFD_INF, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, ni, pz, rnd, -1, FPFD_INF, FPFD_NONE);
  fpfd_assert_ora2msfx(div, res, ni, nz, rnd, 1, FPFD_INF, FPFD_NONE);
}
