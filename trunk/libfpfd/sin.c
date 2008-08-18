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

#include "fpfd_impl.h"

/*
 * Use the Kahan summation algorithm on successive Taylor series terms. This
 * algorithm minimizes the floating-point error in adding a sequence of numbers,
 * by storing the lost low-order digits at each step, and adding them back on
 * the next step. It looks like this:
 *
 *   sum = input[0];
 *   c = 0;
 *   for (i = 1; i < size; ++i) {
 *     y = input[i] - c;
 *     t = sum + y;
 *     c = (t - sum) - y;
 *     sum = t;
 *   }
 *
 * The Taylor series for sin(x) is x - ((x ** 3) / 3!) + ((x ** 5) / 5!) - ...
 */
int fpfd32_sin(fpfd32_ptr dest, fpfd32_srcptr theta, fpfd_rnd_t rnd) {
  int tern;

  /* Kahan algorithm */
  fpfd32_t sum, c, y, t;

  /* Taylor series */
  fpfd32_t term, num, den, n, one;
  int negate;

  /* Initialize Kahan variables */
  fpfd32_set_zero(sum);
  fpfd32_set_zero(c);

  /* Initialize Taylor variables */
  fpfd32_set(term, theta);
  fpfd32_set(num, theta);
  fpfd32_set_one(den);
  fpfd32_set_one(n);
  fpfd32_set_one(one);
  negate = 0; /* Don't negate the first term */

  do {
    /*
     * Do the Kahan addition
     */
    fpfd32_sub(y, term, c, rnd);
    tern = fpfd32_add(t, sum, y, rnd);
    fpfd32_sub(c, t, sum, rnd);
    fpfd32_sub(c, c, y, rnd);
    fpfd32_set(sum, t);

    /*
     * Calculate the next term
     */

    /* Multiply num by x ** 2 */
    fpfd32_mul(num, num, theta, rnd);
    fpfd32_mul(num, num, theta, rnd);

    /* Multiply den by (n + 1) * (n + 2), add 2 to n */
    fpfd32_add(n, n, one, rnd);
    fpfd32_mul(den, den, n, rnd);
    fpfd32_add(n, n, one, rnd);
    fpfd32_mul(den, den, n, rnd);

    /* Set term to num / den */
    fpfd32_div(term, num, den, rnd);

    /* Alternate between addition and subtraction */
    if (negate) fpfd32_neg(term, term);
    negate = !negate;
  } while (!fpfd32_zero_p(term));

  return tern;
}
