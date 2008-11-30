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
#include <stdio.h>  /* For fprintf, stderr            */
#include <stdlib.h> /* For EXIT_SUCCESS, EXIT_FAILURE */

/*
 * Check that fpfd*_impl_compress is behaving correctly.
 */
int
main()
{
  fpfd_declare(zero);
  fpfd_declare(one);
  fpfd_declare(ones);
  fpfd_declare(nines);
  fpfd_declare(inf);
  fpfd_declare(sNaN);
  fpfd_declare(qNaN);

  fpfd_impl_declare(zero_impl);
  fpfd_impl_declare(one_impl);
  fpfd_impl_declare(ones_impl);
  fpfd_impl_declare(nines_impl);
  fpfd_impl_declare(inf_impl);
  fpfd_impl_declare(sNaN_impl);
  fpfd_impl_declare(qNaN_impl);

  /*
   * Test that fpfd*_impl_compress works for 0, 1, 1111111, 9999999, +inf, sNan,
   * and qNaN.
   */

  fpfd_impl_set_esf(&zero_impl, 0, 1, FPFD_ZERO);
  fpfd32_impl_set_manually(&zero_impl32,
                           UINT32_C(0xFFFFFFFF), UINT32_C(0xFFFFFFFF));
  fpfd_op2(impl_compress, zero, &zero_impl);
  fpfd_assert_rsf(zero, +1, FPFD_ZERO);
  fpfd32_assert_mask(zero32, UINT32_C(0x1C0FFFFF), UINT32_C(0x00000000));

  fpfd_impl_set_esf(&one_impl, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&zero_impl32,
                           UINT32_C(0xFFFFFFFF), UINT32_C(0xFFFFFFFF));
  fpfd_op2(impl_compress, zero, &zero_impl);
  fpfd_assert_rsf(zero, +1, FPFD_ZERO);
  fpfd32_assert_mask(zero32, UINT32_C(0x1C0FFFFF), UINT32_C(0x00000000));

  return exitstatus;
}
