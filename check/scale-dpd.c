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
#include <stdio.h>  /* For fprintf, stderr            */
#include <stdlib.h> /* For EXIT_SUCCESS, EXIT_FAILURE */

/*
 * Check that fpfd*_impl_scale is behaving correctly.
 */
int
main()
{
  fpfd_impl_declare(impl);
  fpfd_declare(res);

  /*
   * Make sure we handle a zero significand correctly.
   */
  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0));
  fpfd_op1(impl_scale, &impl);
  fpfd_op2(impl_compress, res, &impl);
  fpfd_assert_rf(res, FPFD_ZERO);

  /*
   * These values are less than the scaled coefficient range, and are unlikely
   * to be passed to fpfd*_impl_scale during normal operation.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x1));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, -6, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x999999));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, -1, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999990));

  /*
   * These values are within the scaled coefficient range, and thus should not
   * be altered by a call to fpfd*_impl_scale.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x1000000));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, 0, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x9999999));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, 0, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  /*
   * These values require scaling down, but have the high 32 bits of their
   * coefficient set to zero. They are treated specially on 32-bit hardware.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000000));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, 1, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000001));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, 1, 1);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x99999995));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, 1, 5);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x99999999));
  impl32.fields.exp = 0;
  fpfd_impl_assert_orev(impl_scale, &impl, 1, 9);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  return exitstatus;
}
