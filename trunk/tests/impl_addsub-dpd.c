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
 * Check that fpfd*_impl_addsub is behaving correctly.
 */
int
main()
{
  fpfd_impl_declare(res);
  fpfd_impl_declare(lhs);
  fpfd_impl_declare(rhs);

  /* Addition */

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x1111111));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x1111111));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs, 
                             -9, 1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x22222220), UINT32_C(0x00000000));

  fpfd_impl_set_esf(&lhs, 13, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs, 
                             5, -1, FPFD_NUMBER, 6);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345678), UINT32_C(0x00000876));

  fpfd_impl_set_esf(&lhs, 16, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs, 
                             8, 1, FPFD_NUMBER, 8);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345678), UINT32_C(0x00000000));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 17, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             9, -1, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345678), UINT32_C(0x00000000));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 24, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             16, 1, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345678), UINT32_C(0x00000000));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 25, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             17, -1, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345678), UINT32_C(0x00000000));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x98766789));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             -7, 1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x11111246), UINT32_C(0x70000000));

  /* Subtraction */

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x9876678));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x1234567));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             -9, 1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x86421110), UINT32_C(0x00000000));

  fpfd_impl_set_esf(&lhs, 12, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             4, -1, FPFD_NUMBER, 6);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345677), UINT32_C(0x99991234));

  fpfd_impl_set_esf(&lhs, 16, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             8, 1, FPFD_NUMBER, 1);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345677), UINT32_C(0x99999999));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 17, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             9, 1, FPFD_NUMBER, 9);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345677), UINT32_C(0x99999999));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 24, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             16, -1, FPFD_NUMBER, 9);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345677), UINT32_C(0x99999999));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 25, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x87654321));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             17, 1, FPFD_NUMBER, 9);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x12345677), UINT32_C(0x99999999));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(0x12345678));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(0x98766789));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs, 
                             -8, -1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x86421111), UINT32_C(0x00000000));

  return exitstatus;
}
