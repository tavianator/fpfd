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
 * Check that fpfd*_impl_inc is behaving correctly.
 */
int
main()
{
  fpfd_impl_declare(number);
  fpfd_impl_declare(nines);
  fpfd_impl_declare(overflow);

  fpfd_impl_set_esf(&number, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&number32, UINT32_C(0), UINT32_C(1234567));
  fpfd_impl_assert_oresf(impl_inc, &number, 0, 1, FPFD_NUMBER);
  fpfd32_impl_assert_mant(&number32, UINT32_C(0), UINT32_C(1234568));

  fpfd_impl_set_esf(&nines, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&nines32, UINT32_C(0), UINT32_C(9999999));
  fpfd_impl_assert_oresf(impl_inc, &nines, 1, -1, FPFD_NUMBER);
  fpfd32_impl_assert_mant(&nines32, UINT32_C(0), UINT32_C(1000000));

  fpfd_impl_set_esf(&overflow, 90, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&overflow32, UINT32_C(0), UINT32_C(9999999));
  fpfd_impl_assert_orsf(impl_inc, &overflow, 1, FPFD_INF);

  return exitstatus;
}
