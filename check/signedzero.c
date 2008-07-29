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

  fpfd32_t pzpz, pznz, nzpz, nznz; /* pzpz = pz + pz; pznz = pz + nz; etc. */

  fpfd32_set_pos_zero(pz);
  fpfd32_set_neg_zero(nz);

  fpfd32_add(pzpz, pz, pz, rnd);
  fpfd32_add(pznz, pz, nz, rnd);
  fpfd32_add(nzpz, nz, pz, rnd);
  fpfd32_add(nznz, nz, nz, rnd);

  fpfd32_assert_special(pzpz, FPFD_ZERO, "(+0) + (+0) != 0", rnd);
  fpfd32_assert_special(pznz, FPFD_ZERO, "(+0) + (-0) != 0", rnd);
  fpfd32_assert_special(nzpz, FPFD_ZERO, "(-0) + (+0) != 0", rnd);
  fpfd32_assert_special(nznz, FPFD_ZERO, "(-0) + (-0) != 0", rnd);

  if (rnd == FPFD_RNDD) {
    fpfd32_assert_sign(pzpz, 1,  "(+0) + (+0) != (+0)", rnd);
    fpfd32_assert_sign(pznz, -1, "(+0) + (-0) != (-0)", rnd);
    fpfd32_assert_sign(nzpz, -1, "(-0) + (+0) != (-0)", rnd);
    fpfd32_assert_sign(nznz, -1, "(-0) + (-0) != (-0)", rnd);
  } else {
    fpfd32_assert_sign(pzpz, 1,  "(+0) + (+0) != (+0)", rnd);
    fpfd32_assert_sign(pznz, 1,  "(+0) + (-0) != (+0)", rnd);
    fpfd32_assert_sign(nzpz, 1,  "(-0) + (+0) != (+0)", rnd);
    fpfd32_assert_sign(nznz, -1, "(-0) + (-0) != (-0)", rnd);
  }
}

void
fpfd32_check_sub(fpfd_rnd_t rnd)
{
  fpfd32_t pz; /* Positive zero */
  fpfd32_t nz; /* Negative zero */

  fpfd32_t pzpz, pznz, nzpz, nznz; /* pzpz = pz - pz; pznz = pz - nz; etc. */

  fpfd32_set_pos_zero(pz);
  fpfd32_set_neg_zero(nz);

  fpfd32_sub(pzpz, pz, pz, rnd);
  fpfd32_sub(pznz, pz, nz, rnd);
  fpfd32_sub(nzpz, nz, pz, rnd);
  fpfd32_sub(nznz, nz, nz, rnd);

  fpfd32_assert_special(pzpz, FPFD_ZERO, "(+0) - (+0) != 0", rnd);
  fpfd32_assert_special(pznz, FPFD_ZERO, "(+0) - (-0) != 0", rnd);
  fpfd32_assert_special(nzpz, FPFD_ZERO, "(-0) - (+0) != 0", rnd);
  fpfd32_assert_special(nznz, FPFD_ZERO, "(-0) - (-0) != 0", rnd);

  if (rnd == FPFD_RNDD) {
    fpfd32_assert_sign(pzpz, 1,  "(+0) - (+0) != (+0)", rnd);
    fpfd32_assert_sign(pznz, -1, "(+0) - (-0) != (-0)", rnd);
    fpfd32_assert_sign(nzpz, -1, "(-0) - (+0) != (-0)", rnd);
    fpfd32_assert_sign(nznz, -1, "(-0) - (-0) != (-0)", rnd);
  } else {
    fpfd32_assert_sign(pzpz, 1,  "(+0) - (+0) != (+0)", rnd);
    fpfd32_assert_sign(pznz, 1,  "(+0) - (-0) != (+0)", rnd);
    fpfd32_assert_sign(nzpz, -1, "(-0) - (+0) != (-0)", rnd);
    fpfd32_assert_sign(nznz, 1,  "(-0) - (-0) != (+0)", rnd);
  }
}

void
fpfd32_check_mul(fpfd_rnd_t rnd)
{
  fpfd32_t pz; /* Positive zero */
  fpfd32_t po; /* Positive one  */
  fpfd32_t nz; /* Negative zero */
  fpfd32_t no; /* Negative one  */

  fpfd32_t pzpz, pznz, nzpz, nznz; /* pzpz = pz * pz; pznz = pz * nz; etc. */
  fpfd32_t pzpo, pzno, nzpo, nzno; /* pzpo = pz * po; pzno = pz * no; etc. */
  fpfd32_t popz, ponz, nopz, nonz; /* popz = po * pz; pznz = po * nz; etc. */

  fpfd32_set_pos_zero(pz);
  fpfd32_set_pos_one(po);
  fpfd32_set_neg_zero(nz);
  fpfd32_set_neg_one(no);

  fpfd32_mul(pzpz, pz, pz, rnd);
  fpfd32_mul(pznz, pz, nz, rnd);
  fpfd32_mul(nzpz, nz, pz, rnd);
  fpfd32_mul(nznz, nz, nz, rnd);

  fpfd32_mul(pzpo, pz, po, rnd);
  fpfd32_mul(pzno, pz, no, rnd);
  fpfd32_mul(nzpo, nz, po, rnd);
  fpfd32_mul(nzno, nz, no, rnd);

  fpfd32_mul(popz, po, pz, rnd);
  fpfd32_mul(ponz, po, nz, rnd);
  fpfd32_mul(nopz, no, pz, rnd);
  fpfd32_mul(nonz, no, nz, rnd);

  fpfd32_assert_special(pzpz, FPFD_ZERO, "(+0) * (+0) != 0", rnd);
  fpfd32_assert_special(pznz, FPFD_ZERO, "(+0) * (-0) != 0", rnd);
  fpfd32_assert_special(nzpz, FPFD_ZERO, "(-0) * (+0) != 0", rnd);
  fpfd32_assert_special(nznz, FPFD_ZERO, "(-0) * (-0) != 0", rnd);

  fpfd32_assert_special(pzpo, FPFD_ZERO, "(+0) * (+1) != 0", rnd);
  fpfd32_assert_special(pzno, FPFD_ZERO, "(+0) * (-1) != 0", rnd);
  fpfd32_assert_special(nzpo, FPFD_ZERO, "(-0) * (+1) != 0", rnd);
  fpfd32_assert_special(nzno, FPFD_ZERO, "(-0) * (-1) != 0", rnd);

  fpfd32_assert_special(popz, FPFD_ZERO, "(+1) * (+0) != 0", rnd);
  fpfd32_assert_special(ponz, FPFD_ZERO, "(+1) * (-0) != 0", rnd);
  fpfd32_assert_special(nopz, FPFD_ZERO, "(-1) * (+0) != 0", rnd);
  fpfd32_assert_special(nonz, FPFD_ZERO, "(-1) * (-0) != 0", rnd);

  fpfd32_assert_sign(pzpz, 1,  "(+0) * (+0) != (+0)", rnd);
  fpfd32_assert_sign(pznz, -1, "(+0) * (-0) != (-0)", rnd);
  fpfd32_assert_sign(nzpz, -1, "(-0) * (+0) != (-0)", rnd);
  fpfd32_assert_sign(nznz, 1,  "(-0) * (-0) != (+0)", rnd);

  fpfd32_assert_sign(pzpo, 1,  "(+0) * (+1) != (+0)", rnd);
  fpfd32_assert_sign(pzno, -1, "(+0) * (-1) != (-0)", rnd);
  fpfd32_assert_sign(nzpo, -1, "(-0) * (+1) != (-0)", rnd);
  fpfd32_assert_sign(nzno, 1,  "(-0) * (-1) != (+0)", rnd);

  fpfd32_assert_sign(popz, 1,  "(+1) * (+0) != (+0)", rnd);
  fpfd32_assert_sign(ponz, -1, "(+1) * (-0) != (-0)", rnd);
  fpfd32_assert_sign(nopz, -1, "(-1) * (+0) != (-0)", rnd);
  fpfd32_assert_sign(nonz, 1,  "(-1) * (-0) != (+0)", rnd);
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

  fpfd32_t pzpo, pzno, nzpo, nzno; /* pzpo = pz / po; pzno = pz / no; etc. */
  fpfd32_t pzpi, pzni, nzpi, nzni; /* pzpi = pz / pi; pzni = pz / ni; etc. */
  fpfd32_t popz, ponz, nopz, nonz; /* popz = po / pz; ponz = po / nz; etc. */
  fpfd32_t popi, poni, nopi, noni; /* popi = po / pi; poni = po / ni; etc. */
  fpfd32_t pipz, pinz, nipz, ninz; /* pipz = pi / pz; pinz = pi / nz; etc. */

  fpfd32_set_pos_zero(pz);
  fpfd32_set_pos_one(po);
  fpfd32_set_pos_inf(pi);
  fpfd32_set_neg_zero(nz);
  fpfd32_set_neg_one(no);
  fpfd32_set_neg_inf(ni);

  fpfd32_div(pzpo, pz, po, rnd);
  fpfd32_div(pzno, pz, no, rnd);
  fpfd32_div(nzpo, nz, po, rnd);
  fpfd32_div(nzno, nz, no, rnd);

  fpfd32_div(pzpi, pz, pi, rnd);
  fpfd32_div(pzni, pz, ni, rnd);
  fpfd32_div(nzpi, nz, pi, rnd);
  fpfd32_div(nzni, nz, no, rnd);

  fpfd32_div(popz, po, pz, rnd);
  fpfd32_div(ponz, po, nz, rnd);
  fpfd32_div(nopz, no, pz, rnd);
  fpfd32_div(nonz, no, nz, rnd);

  fpfd32_div(popi, po, pi, rnd);
  fpfd32_div(poni, po, ni, rnd);
  fpfd32_div(nopi, no, pi, rnd);
  fpfd32_div(noni, no, ni, rnd);

  fpfd32_div(pipz, pi, pz, rnd);
  fpfd32_div(pinz, pi, nz, rnd);
  fpfd32_div(nipz, ni, pz, rnd);
  fpfd32_div(ninz, ni, nz, rnd);

  fpfd32_assert_special(pzpo, FPFD_ZERO, "(+0) / (+1) != 0", rnd);
  fpfd32_assert_special(pzno, FPFD_ZERO, "(+0) / (-1) != 0", rnd);
  fpfd32_assert_special(nzpo, FPFD_ZERO, "(-0) / (+1) != 0", rnd);
  fpfd32_assert_special(nzno, FPFD_ZERO, "(-0) / (-1) != 0", rnd);

  fpfd32_assert_special(pzpi, FPFD_ZERO, "(+0) / (+inf) != 0", rnd);
  fpfd32_assert_special(pzni, FPFD_ZERO, "(+0) / (-inf) != 0", rnd);
  fpfd32_assert_special(nzpi, FPFD_ZERO, "(-0) / (+inf) != 0", rnd);
  fpfd32_assert_special(nzni, FPFD_ZERO, "(-0) / (-inf) != 0", rnd);

  fpfd32_assert_special(popz, FPFD_INF, "(+1) / (+0) != inf", rnd);
  fpfd32_assert_special(ponz, FPFD_INF, "(+1) / (-0) != inf", rnd);
  fpfd32_assert_special(nopz, FPFD_INF, "(-1) / (+0) != inf", rnd);
  fpfd32_assert_special(nonz, FPFD_INF, "(-1) / (-0) != inf", rnd);

  fpfd32_assert_special(popi, FPFD_ZERO, "(+1) / (+inf) != 0", rnd);
  fpfd32_assert_special(poni, FPFD_ZERO, "(+1) / (-inf) != 0", rnd);
  fpfd32_assert_special(nopi, FPFD_ZERO, "(-1) / (+inf) != 0", rnd);
  fpfd32_assert_special(noni, FPFD_ZERO, "(-1) / (-inf) != 0", rnd);

  fpfd32_assert_special(pipz, FPFD_INF, "(+inf) / (+0) != inf", rnd);
  fpfd32_assert_special(pinz, FPFD_INF, "(+inf) / (-0) != inf", rnd);
  fpfd32_assert_special(nipz, FPFD_INF, "(-inf) / (+0) != inf", rnd);
  fpfd32_assert_special(ninz, FPFD_INF, "(-inf) / (-0) != inf", rnd);

  fpfd32_assert_sign(pzpo, 1,  "(+0) / (+1) != (+0)", rnd);
  fpfd32_assert_sign(pzno, -1, "(+0) / (-1) != (-0)", rnd);
  fpfd32_assert_sign(nzpo, -1, "(-0) / (+1) != (-0)", rnd);
  fpfd32_assert_sign(nzno, 1,  "(-0) / (-1) != (+0)", rnd);

  fpfd32_assert_sign(pzpi, 1,  "(+0) / (+inf) != (+0)", rnd);
  fpfd32_assert_sign(pzni, -1, "(+0) / (-inf) != (-0)", rnd);
  fpfd32_assert_sign(nzpi, -1, "(-0) / (+inf) != (-0)", rnd);
  fpfd32_assert_sign(nzni, 1,  "(-0) / (-inf) != (+0)", rnd);

  fpfd32_assert_sign(popz, 1,  "(+1) / (+0) != (+inf)", rnd);
  fpfd32_assert_sign(ponz, -1, "(+1) / (-0) != (-inf)", rnd);
  fpfd32_assert_sign(nopz, -1, "(-1) / (+0) != (-inf)", rnd);
  fpfd32_assert_sign(nonz, 1,  "(-1) / (-0) != (+inf)", rnd);

  fpfd32_assert_sign(popi, 1,  "(+1) / (+inf) != (+0)", rnd);
  fpfd32_assert_sign(poni, -1, "(+1) / (-inf) != (-0)", rnd);
  fpfd32_assert_sign(nopi, -1, "(-1) / (+inf) != (-0)", rnd);
  fpfd32_assert_sign(noni, 1,  "(-1) / (-inf) != (+0)", rnd);

  fpfd32_assert_sign(pipz, 1,  "(+inf) / (+0) != (+inf)", rnd);
  fpfd32_assert_sign(pinz, -1, "(+inf) / (-0) != (-inf)", rnd);
  fpfd32_assert_sign(nipz, -1, "(-inf) / (+0) != (-inf)", rnd);
  fpfd32_assert_sign(ninz, 1,  "(-inf) / (-0) != (+inf)", rnd);
}
