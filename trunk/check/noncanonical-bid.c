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
#include <stdio.h>  /* For fprintf, stderr            */
#include <stdlib.h> /* For EXIT_SUCCESS, EXIT_FAILURE */

/*
 * Check cases where a non-canonical value should be handled specially.
 */
int
main()
{
  fpfd_declare(big_mant_num);
  fpfd_declare(big_mant_sNaN);
  fpfd_declare(big_mant_qNaN);

  fpfd32_check_independent();

  /*
   * Encoding-dependant tests
   *
   * Mantissas with numerical value greater than the maximum representable by
   * the DPD encoding are non-canonical and evaluate to zero, even for NaN
   * payloads.
   */
  fpfd32_set_manually(big_mant_num32, UINT32_C(0x77FFFFFF));
  fpfd_assert_rf(big_mant_num, FPFD_ZERO);

  fpfd32_set_manually(big_mant_sNaN32, UINT32_C(0x7E0FFFFF));
  fpfd32_assert_mant(big_mant_sNaN32, UINT32_C(0x0));
  fpfd_assert_rf(big_mant_sNaN, FPFD_SNAN);

  fpfd32_set_manually(big_mant_qNaN32, UINT32_C(0x7C0FFFFF));
  fpfd32_assert_mant(big_mant_qNaN32, UINT32_C(0x0));
  fpfd_assert_rf(big_mant_qNaN, FPFD_QNAN);

  return exitstatus;
}
