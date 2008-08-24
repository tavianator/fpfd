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

#include "noncanonical.h"
#include <inttypes.h> /* For uint32_t, PRIX32   */
#include <stdlib.h>   /* For exit, EXIT_FAILURE */

void
fpfd32_check_independent()
{
  /*
   * NaNs should have G_6 through G_{w+4} set to zero, infinities should have
   * G_5 through G_{w+4} and T set to zero.
   */

  fpfd32_t noncanon_sNaN, noncanon_qNaN, noncanon_inf;

  fpfd32_set_manually(noncanon_sNaN, 0x7FF00000);
  fpfd32_set(noncanon_sNaN, noncanon_sNaN);
  fpfd32_assert_manually(noncanon_sNaN, 0x7FF00000, 0x7E000000);

  fpfd32_set_manually(noncanon_qNaN, 0x7DF00000);
  fpfd32_set(noncanon_qNaN, noncanon_qNaN);
  fpfd32_assert_manually(noncanon_qNaN, 0x7FF00000, 0x7C000000);

  fpfd32_set_manually(noncanon_inf, 0x7BF00000);
  fpfd32_set(noncanon_inf, noncanon_inf);
  fpfd32_assert_manually(noncanon_inf, 0x7FFFFFFF, 0x78000000);
}

void
fpfd32_assert(fpfd32_srcptr res, uint32_t mant, fpfd_special_t special)
{
  if (!fpfd32_check_mant(res, mant) || !fpfd32_check_special(res, special)) {
    fpfd32_impl_t res_impl;
    fpfd32_impl_expand(&res_impl, res);

    fprintf(stderr, "\n");
    fpfd32_dump(stderr, res);
    fprintf(stderr, " = ");
    fpfd32_impl_dump(stderr, &res_impl);
    fprintf(stderr, "\n\n--- ERROR: Expected mant == 0x%.16" PRIX32 
                    ", special == %s ---\n\n",
            mant, fpfd_special_str(special));
    exit(EXIT_FAILURE);
  }
}

void
fpfd32_assert_manually(fpfd32_srcptr res, uint32_t mask, uint32_t cmp)
{
  if (!fpfd32_check_manually(res, mask, cmp)) {
    fpfd32_impl_t res_impl;
    fpfd32_impl_expand(&res_impl, res);

    fprintf(stderr, "\n");
    fpfd32_dump(stderr, res);
    fprintf(stderr, "\n\n--- ERROR: Expected (op & %.8" PRIX32 ") "
                    "== %.8" PRIX32 " ---\n\n",
            mask, cmp);
    exit(EXIT_FAILURE);
  }
}
