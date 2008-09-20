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

  fpfd_declare(noncanon_sNaN);
  fpfd_declare(noncanon_qNaN);
  fpfd_declare(noncanon_inf);

  fpfd32_set_manually(noncanon_sNaN32, UINT32_C(0x7FF00000));
  fpfd32_set(noncanon_sNaN32, noncanon_sNaN32);
  fpfd32_assert_mask(noncanon_sNaN32,
                     UINT32_C(0x7FF00000), UINT32_C(0x7E000000));

  fpfd32_set_manually(noncanon_qNaN32, UINT32_C(0x7DF00000));
  fpfd32_set(noncanon_qNaN32, noncanon_qNaN32);
  fpfd32_assert_mask(noncanon_qNaN32,
                     UINT32_C(0x7FF00000), UINT32_C(0x7C000000));

  fpfd32_set_manually(noncanon_inf32, UINT32_C(0x7BF00000));
  fpfd32_set(noncanon_inf32, noncanon_inf32);
  fpfd32_assert_mask(noncanon_inf32,
                     UINT32_C(0x7FFFFFFF), UINT32_C(0x78000000));
}
