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
   * Test that fpfd*_impl_compress works for -0, 1, -1111111, 9999999, -inf,
   * sNaN, and qNaN.
   */

  fpfd_impl_set_esf(&zero_impl, 0, -1, FPFD_ZERO);
  fpfd32_impl_set_manually(&zero_impl32,
                           UINT32_C(0xFFFFFFFF), UINT32_C(0xFFFFFFFF));
  fpfd_op2(impl_compress, zero, &zero_impl);
  fpfd_assert_rsf(zero, -1, FPFD_ZERO);
  fpfd32_assert_mask(zero32, UINT32_C(0x807FFFFF), UINT32_C(0x80000000));

  fpfd_impl_set_esf(&one_impl, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&one_impl32, UINT32_C(0), UINT32_C(1));
  fpfd_op2(impl_compress, one, &one_impl);
  fpfd_assert_rsf(one, 1, FPFD_NUMBER);
  fpfd32_assert_manually(one32, UINT32_C(0x32800001));

  fpfd_impl_set_esf(&ones_impl, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&ones_impl32, UINT32_C(0), UINT32_C(1111111));
  fpfd_op2(impl_compress, ones, &ones_impl);
  fpfd_assert_rsf(ones, -1, FPFD_NUMBER);
  fpfd32_assert_manually(ones32, UINT32_C(0xB290F447));

  fpfd_impl_set_esf(&nines_impl, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&nines_impl32, UINT32_C(0), UINT32_C(9999999));
  fpfd_op2(impl_compress, nines, &nines_impl);
  fpfd_assert_rsf(nines, 1, FPFD_NUMBER);
  fpfd32_assert_manually(nines32, UINT32_C(0x6CB8967F));

  fpfd_impl_set_esf(&inf_impl, 0, -1, FPFD_INF);
  fpfd32_impl_set_manually(&inf_impl32,
                           UINT32_C(0x99999999), UINT32_C(0x99999999));
  fpfd_op2(impl_compress, inf, &inf_impl);
  fpfd_assert_rsf(inf, -1, FPFD_INF);
  fpfd32_assert_manually(inf32, UINT32_C(0xF8000000));

  fpfd_impl_set_esf(&sNaN_impl, 0, 1, FPFD_SNAN);
  fpfd32_impl_set_manually(&sNaN_impl32, UINT32_C(0), UINT32_C(123456));
  fpfd_op2(impl_compress, sNaN, &sNaN_impl);
  fpfd_assert_rsf(sNaN, 1, FPFD_SNAN);
  fpfd32_assert_manually(sNaN32, UINT32_C(0x7E01E240));

  fpfd_impl_set_esf(&qNaN_impl, 0, -1, FPFD_QNAN);
  fpfd32_impl_set_manually(&qNaN_impl32, UINT32_C(0), UINT32_C(123456));
  fpfd_op2(impl_compress, qNaN, &qNaN_impl);
  fpfd_assert_rsf(qNaN, -1, FPFD_QNAN);
  fpfd32_assert_manually(qNaN32, UINT32_C(0xFC01E240));

  return exitstatus;
}
