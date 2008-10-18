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

  /*
   * Make sure we handle a zero significand correctly.
   */
  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orfv(impl_scale, &impl, FPFD_ZERO, 10 | 0x10);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0));

  /*
   * These values are less than the scaled coefficient range, and are unlikely
   * to be passed to fpfd*_impl_scale during normal operation.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x1));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, -6, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x999999));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, -1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999990));

  /*
   * These values are within the scaled coefficient range, and thus should not
   * be altered by a call to fpfd*_impl_scale.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x1000000));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 0, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x9999999));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 0, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  /*
   * These values require scaling down, but have the high 32 bits of their
   * coefficient set to zero. They are treated specially on 32-bit hardware.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000000));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000001));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 1, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x99999995));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 1, FPFD_NUMBER, 5);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x99999999));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 1, FPFD_NUMBER, 9);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  /*
   * These values use 64 bits of the unscaled mantissa.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x1), UINT32_C(0x00000000));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 2, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x1), UINT32_C(0x00000001));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 2, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x9), UINT32_C(0x99999950));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 2, FPFD_NUMBER, 5);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x9), UINT32_C(0x99999999));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 2, FPFD_NUMBER, 9);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x10000000), UINT32_C(0x00000000));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 9, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x10000000), UINT32_C(0x00000001));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 9, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x1000000));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x99999995), UINT32_C(0x00000000));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 9, FPFD_NUMBER, 5);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x99999999), UINT32_C(0x99999999));
  fpfd_impl_set_ef(&impl, 0, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 9, FPFD_NUMBER, 9);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  /*
   * These values need to be subnormalized.
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000000));
  fpfd_impl_set_ef(&impl, -109, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, -101, FPFD_NUMBER, 1 | 0x10);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000001));
  fpfd_impl_set_ef(&impl, -107, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, -101, FPFD_NUMBER, 1 | 0x10);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x10));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x99995000), UINT32_C(0x00000000));
  fpfd_impl_set_ef(&impl, -113, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, -101, FPFD_NUMBER, 5 | 0x10);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x99999999), UINT32_C(0x99999999));
  fpfd_impl_set_ef(&impl, -111, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, -101, FPFD_NUMBER, 9 | 0x10);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x999999));

  /*
   * These values should underflow
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000000));
  fpfd_impl_set_ef(&impl, -110, FPFD_NUMBER);
  fpfd_impl_assert_orfv(impl_scale, &impl, FPFD_ZERO, 10 | 0x10);

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x99999999), UINT32_C(0x99999999));
  fpfd_impl_set_ef(&impl, -118, FPFD_NUMBER);
  fpfd_impl_assert_orfv(impl_scale, &impl, FPFD_ZERO, 10 | 0x10);

  /*
   * These values should overflow
   */

  fpfd32_impl_set_manually(&impl32, UINT32_C(0), UINT32_C(0x10000000));
  fpfd_impl_set_ef(&impl, 90, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 90, FPFD_NUMBER, 10);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  fpfd32_impl_set_manually(&impl32, UINT32_C(0x99999999), UINT32_C(0x99999999));
  fpfd_impl_set_ef(&impl, 82, FPFD_NUMBER);
  fpfd_impl_assert_orefv(impl_scale, &impl, 90, FPFD_NUMBER, 10);
  fpfd32_impl_assert_mant(&impl32, UINT32_C(0), UINT32_C(0x9999999));

  return exitstatus;
}
