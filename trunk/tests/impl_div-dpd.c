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
 * Check that fpfd*_impl_div is behaving correctly.
 */
int
main()
{
  fpfd_impl_declare(res);
  fpfd_impl_declare(lhs);
  fpfd_impl_declare(rhs);

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x7));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x9));
  fpfd_impl_assert_ora2esfv(impl_div, &res, &lhs, &rhs, -8, 1, FPFD_NUMBER, 7);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(0x77777777));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x7654321));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x1234567));
  fpfd_impl_assert_ora2esfv(impl_div, &res, &lhs, &rhs, -6, 1, FPFD_NUMBER, 6);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(0x6200004));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x7200000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x1234567));
  fpfd_impl_assert_ora2esfv(impl_div, &res, &lhs, &rhs, -6, 1, FPFD_NUMBER, 2);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(0x5832004));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x1100000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x1234567));
  fpfd_impl_assert_ora2esfv(impl_div, &res, &lhs, &rhs, -8, 1, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(0x89100065));

  return exitstatus;
}
