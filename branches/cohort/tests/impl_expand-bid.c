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
 * Check that fpfd*_impl_expand is behaving correctly.
 */
int
main()
{
  /* Canonical inputs */

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

  /* Non-canonical inputs */

  fpfd_declare(big_mant);
  fpfd_declare(big_mant_sNaN);
  fpfd_declare(big_mant_qNaN);

  fpfd_impl_declare(big_mant_impl);
  fpfd_impl_declare(big_mant_sNaN_impl);
  fpfd_impl_declare(big_mant_qNaN_impl);

  /*
   * Test that fpfd*_impl_expand works for -0, 1, -1111111, 9999999, -inf, sNaN,
   * and qNaN.
   */

  fpfd32_set_manually(zero32, UINT32_C(0xB2800000));
  fpfd_op2(impl_expand, &zero_impl, zero);
  fpfd_impl_assert_rsf(&zero_impl, -1, FPFD_ZERO);

  fpfd32_set_manually(one32, UINT32_C(0x32800001));
  fpfd_op2(impl_expand, &one_impl, one);
  fpfd_impl_assert_resf(&one_impl, 0, 1, FPFD_NUMBER);
  fpfd32_impl_assert_mant(&one_impl32, UINT32_C(0), UINT32_C(1));

  fpfd32_set_manually(ones32, UINT32_C(0xB290F447));
  fpfd_op2(impl_expand, &ones_impl, ones);
  fpfd_impl_assert_resf(&ones_impl, 0, -1, FPFD_NUMBER);
  fpfd32_impl_assert_mant(&ones_impl32, UINT32_C(0), UINT32_C(1111111));

  fpfd32_set_manually(nines32, UINT32_C(0x6CB8967F));
  fpfd_op2(impl_expand, &nines_impl, nines);
  fpfd_impl_assert_resf(&nines_impl, 0, 1, FPFD_NUMBER);
  fpfd32_impl_assert_mant(&nines_impl32, UINT32_C(0), UINT32_C(9999999));

  fpfd32_set_manually(inf32, UINT32_C(0xF8000000));
  fpfd_op2(impl_expand, &inf_impl, inf);
  fpfd_impl_assert_rsf(&inf_impl, -1, FPFD_INF);

  fpfd32_set_manually(sNaN32, UINT32_C(0x7E01E240));
  fpfd_op2(impl_expand, &sNaN_impl, sNaN);
  fpfd_impl_assert_rsf(&sNaN_impl, 1, FPFD_SNAN);
  fpfd32_impl_assert_mant(&sNaN_impl32, UINT32_C(0), UINT32_C(123456));

  fpfd32_set_manually(qNaN32, UINT32_C(0xFC01E240));
  fpfd_op2(impl_expand, &qNaN_impl, qNaN);
  fpfd_impl_assert_rsf(&qNaN_impl, -1, FPFD_QNAN);
  fpfd32_impl_assert_mant(&qNaN_impl32, UINT32_C(0), UINT32_C(123456));

  /*
   * Mantissas with numerical value greater than the maximum representable by
   * the DPD encoding are non-canonical and evaluate to zero, even for NaN
   * payloads.
   */

  fpfd32_set_manually(big_mant32, UINT32_C(0x77FFFFFF));
  fpfd_op2(impl_expand, &big_mant_impl, big_mant);
  fpfd_impl_assert_rsf(&big_mant_impl, 1, FPFD_ZERO);

  fpfd32_set_manually(big_mant_sNaN32, UINT32_C(0x7E0FFFFF));
  fpfd_op2(impl_expand, &big_mant_sNaN_impl, big_mant_sNaN);
  fpfd_impl_assert_rsf(&big_mant_sNaN_impl, 1, FPFD_SNAN);
  fpfd32_impl_assert_mant(&big_mant_sNaN_impl32, UINT32_C(0), UINT32_C(0));

  fpfd32_set_manually(big_mant_qNaN32, UINT32_C(0x7C0FFFFF));
  fpfd_op2(impl_expand, &big_mant_qNaN_impl, big_mant_qNaN);
  fpfd_impl_assert_rsf(&big_mant_qNaN_impl, 1, FPFD_QNAN);
  fpfd32_impl_assert_mant(&big_mant_qNaN_impl32, UINT32_C(0), UINT32_C(0));

  return exitstatus;
}
