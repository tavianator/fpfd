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

/*
 * Check that fpfd*_impl_expand is behaving correctly
 */
int
main()
{
  /* Canonical inputs */

  fpfd_declare(zero);
  fpfd_declare(one);
  fpfd_declare(nines);
  fpfd_declare(inf);
  fpfd_declare(sNaN);
  fpfd_declare(qNaN);

  fpfd_impl_declare(zero_impl);
  fpfd_impl_declare(one_impl);
  fpfd_impl_declare(nines_impl);
  fpfd_impl_declare(inf_impl);
  fpfd_impl_declare(sNaN_impl);
  fpfd_impl_declare(qNaN_impl);

  /*
   * Test that fpfd*_impl_expand works for 0, 1, 9999999, +inf, sNan, and qNaN.
   */

  fpfd32_set_manually(zero32, UINT32_C(0x21400000));
  fpfd_impl_assert_ora1sf(impl_expand, &zero_impl, zero,
                          1, FPFD_ZERO);

  fpfd32_set_manually(one32, UINT32_C(0x22500001));
  fpfd_impl_assert_ora1esf(impl_expand, &one_impl, one,
                           0, 1, FPFD_NUMBER);
  fpfd32_impl_assert_mant(&one_impl32, UINT32_C(0), UINT32_C(0x1));

  fpfd32_set_manually(nines32, UINT32_C(0x6853FCFF));
  fpfd_impl_assert_ora1esf(impl_expand, &nines_impl, nines,
                           0, 1, FPFD_NUMBER);
  fpfd32_impl_assert_mant(&nines_impl32, UINT32_C(0), UINT32_C(0x9999999));

  fpfd32_set_manually(inf32, UINT32_C(0x78000000));
  fpfd_impl_assert_ora1sf(impl_expand, &inf_impl, inf,
                          1, FPFD_INF);

  fpfd32_set_manually(sNaN32, UINT32_C(0x7E028E56));
  fpfd_impl_assert_ora1sf(impl_expand, &sNaN_impl, sNaN,
                          1, FPFD_SNAN);
  fpfd32_impl_assert_mant(&sNaN_impl32, UINT32_C(0), UINT32_C(0x123456));

  fpfd32_set_manually(qNaN32, UINT32_C(0x7C028E56));
  fpfd_impl_assert_ora1sf(impl_expand, &qNaN_impl, qNaN,
                          1, FPFD_QNAN);
  fpfd32_impl_assert_mant(&qNaN_impl32, UINT32_C(0), UINT32_C(0x123456));
  
  return exitstatus;
}
