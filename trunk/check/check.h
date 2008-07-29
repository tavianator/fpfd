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

#include "../libfpfd/fpfd.h"
#include "../libfpfd/fpfd_impl.h"

void fpfd32_set_pos_zero(fpfd32_ptr dest); /* Set to positive zero     */
void fpfd32_set_pos_one(fpfd32_ptr dest);  /*        positive one      */
void fpfd32_set_pos_inf(fpfd32_ptr dest);  /*        positive infinity */
void fpfd32_set_neg_zero(fpfd32_ptr dest); /*        negative zero     */
void fpfd32_set_neg_one(fpfd32_ptr dest);  /*        negative one      */
void fpfd32_set_neg_inf(fpfd32_ptr dest);  /*        negative infinity */

/*
 * If the special flag of res != special, print err followed by a space and the
 * rounding mode in brakets, then a newline, as in 'Error (FPFD_RNDN)\n'. Then
 * dump the hex values of the operands as 'lhs @ rhs == src\n'.
 */
void fpfd32_assert_special(fpfd32_srcptr lhs, fpfd32_srcptr rhs,
                           fpfd32_srcptr res,
                           fpfd_special_t special,
                           const char *err, fpfd_rnd_t rnd);

/* Like fpfd32_assert_special, but fail if the sign of res != sign */
void fpfd32_assert_sign(fpfd32_srcptr lhs, fpfd32_srcptr rhs,
                        fpfd32_srcptr res,
                        int sign,
                        const char *err, fpfd_rnd_t rnd);
