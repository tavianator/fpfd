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

  return exitstatus;
}

void
fpfd_check_add(fpfd_rnd_t rnd)
{
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(nz); /* Negative zero */

  fpfd_declare(res); /* Result */

  fpfd_set(pz, zero);
  fpfd_set(nz, neg_zero);

  if (rnd == FPFD_RNDD) {
    fpfd_assert_ora2msf(add, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd_assert_ora2msf(add, res, pz, nz, rnd, -1, FPFD_ZERO);
    fpfd_assert_ora2msf(add, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd_assert_ora2msf(add, res, nz, nz, rnd, -1, FPFD_ZERO);
  } else {
    fpfd_assert_ora2msf(add, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd_assert_ora2msf(add, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd_assert_ora2msf(add, res, nz, pz, rnd, 1, FPFD_ZERO);
    fpfd_assert_ora2msf(add, res, nz, nz, rnd, -1, FPFD_ZERO);
  }
}

void
fpfd_check_sub(fpfd_rnd_t rnd)
{
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(nz); /* Negative zero */

  fpfd_declare(res); /* Result */

  fpfd_set(pz, zero);
  fpfd_set(nz, neg_zero);

  if (rnd == FPFD_RNDD) {
    fpfd_assert_ora2msf(sub, res, pz, pz, rnd, -1, FPFD_ZERO);
    fpfd_assert_ora2msf(sub, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd_assert_ora2msf(sub, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd_assert_ora2msf(sub, res, nz, nz, rnd, -1, FPFD_ZERO);
  } else {
    fpfd_assert_ora2msf(sub, res, pz, pz, rnd, 1, FPFD_ZERO);
    fpfd_assert_ora2msf(sub, res, pz, nz, rnd, 1, FPFD_ZERO);
    fpfd_assert_ora2msf(sub, res, nz, pz, rnd, -1, FPFD_ZERO);
    fpfd_assert_ora2msf(sub, res, nz, nz, rnd, 1, FPFD_ZERO);
  }
}

void
fpfd_check_mul(fpfd_rnd_t rnd)
{
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(po); /* Positive one  */
  fpfd_declare(nz); /* Negative zero */
  fpfd_declare(no); /* Negative one  */

  fpfd_declare(res); /* Result */

  fpfd_set(pz, zero);
  fpfd_set(po, one);
  fpfd_set(nz, neg_zero);
  fpfd_set(no, neg_one);

  fpfd_assert_ora2msf(mul, res, pz, pz, rnd, 1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, pz, nz, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, nz, pz, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, nz, nz, rnd, 1, FPFD_ZERO);

  fpfd_assert_ora2msf(mul, res, pz, po, rnd, 1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, pz, no, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, nz, po, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, nz, no, rnd, 1, FPFD_ZERO);

  fpfd_assert_ora2msf(mul, res, po, pz, rnd, 1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, po, nz, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, no, pz, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(mul, res, no, nz, rnd, 1, FPFD_ZERO);
}

void
fpfd_check_div(fpfd_rnd_t rnd)
{
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

  fpfd_assert_ora2msf(div, res, pz, po, rnd, 1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, pz, no, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, nz, po, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, nz, no, rnd, 1, FPFD_ZERO);

  fpfd_assert_ora2msf(div, res, pz, pi, rnd, 1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, pz, ni, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, nz, pi, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, nz, ni, rnd, 1, FPFD_ZERO);

  fpfd_assert_ora2msf(div, res, po, pz, rnd, 1, FPFD_INF);
  fpfd_assert_ora2msf(div, res, po, nz, rnd, -1, FPFD_INF);
  fpfd_assert_ora2msf(div, res, no, pz, rnd, -1, FPFD_INF);
  fpfd_assert_ora2msf(div, res, no, nz, rnd, 1, FPFD_INF);

  fpfd_assert_ora2msf(div, res, po, pi, rnd, 1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, po, ni, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, no, pi, rnd, -1, FPFD_ZERO);
  fpfd_assert_ora2msf(div, res, no, ni, rnd, 1, FPFD_ZERO);

  fpfd_assert_ora2msf(div, res, pi, pz, rnd, 1, FPFD_INF);
  fpfd_assert_ora2msf(div, res, pi, nz, rnd, -1, FPFD_INF);
  fpfd_assert_ora2msf(div, res, ni, pz, rnd, -1, FPFD_INF);
  fpfd_assert_ora2msf(div, res, ni, nz, rnd, 1, FPFD_INF);
}
