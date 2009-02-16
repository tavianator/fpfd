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
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs,
                             -12, 1, FPFD_NUMBER, 0);
  /* 2000000000000000000 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x1BC16D67), UINT32_C(0x4EC80000));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(100000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs, 
                             -12, -1, FPFD_NUMBER, 0);
  /* 1100000000000000000 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x0F43FC2C), UINT32_C(0x04EE0000));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(10000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs, 
                             -12, 1, FPFD_NUMBER, 0);
  /* 1010000000000000000 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x0E043DA6), UINT32_C(0x17250000));

  fpfd_impl_set_esf(&lhs, 14, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(1111111));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(5555555));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs,
                             2, -1, FPFD_NUMBER, 6);
  /* 1111111000000055555 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x0F6B7591), UINT32_C(0x4D084903));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 1, 1, FPFD_NUMBER);
  /* 18446744073709551605 */
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0xFFFFFFFF), UINT32_C(0xFFFFFFFF));
  /* 18446744073709551615 */
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0xFFFFFFFF), UINT32_C(0xFFFFFFFF));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs,
                             2, 1, FPFD_NUMBER, 6);
  /* 2029141848108050677 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x1C28F5C2), UINT32_C(0x8F5C28F5));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  /* 18446744073709551615 */
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0xFFFFFFFF), UINT32_C(0xFFFFFFFF));
  /* 18446744073709551614 */
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0xFFFFFFFF), UINT32_C(0xFFFFFFFE));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs,
                             1, -1, FPFD_NUMBER, 9);
  /* 3689348814741910322 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x33333333), UINT32_C(0x33333332));

  /* Subtraction */

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs,
                             -12, -1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(0));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(100000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             -12, -1, FPFD_NUMBER, 0);
  /* 900000000000000000 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x0C7D713B), UINT32_C(0x49DA0000));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, 1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(10000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs, 
                             -12, -1, FPFD_NUMBER, 0);
  /* 990000000000000000 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x0DBD2FC1), UINT32_C(0x37A30000));

  fpfd_impl_set_esf(&lhs, 14, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(1111111));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(4444444));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, -1, &lhs, &rhs,
                             2, -1, FPFD_NUMBER, 6);
  /* 1111111099999955555 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0xF6B7591), UINT32_C(0x4D06C263));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 0, -1, FPFD_NUMBER);
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0), UINT32_C(2000000));
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0), UINT32_C(1000000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs,
                             -12, 1, FPFD_NUMBER, 0);
  /* 1000000000000000000 */
  fpfd32_impl_assert_mant(&res32, UINT32_C(0x0DE0B6B3), UINT32_C(0xA7640000));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 1, 1, FPFD_NUMBER);
  /* 10000000000000000011 */
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0x8AC72304), UINT32_C(0x89E8000B));
  /* 1000000000000000000 */
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0x0DE0B6B3), UINT32_C(0xA7640000));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs,
                             0, -1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(11));

  fpfd_impl_set_esf(&lhs, 0, 1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 1, -1, FPFD_NUMBER);
  /* 10000000000000000011 */
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0x8AC72304), UINT32_C(0x89E8000B));
  /* 1000000000000000001 */
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0x0DE0B6B3), UINT32_C(0xA7640001));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs,
                             0, 1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(1));

  fpfd_impl_set_esf(&lhs, 0, -1, FPFD_NUMBER);
  fpfd_impl_set_esf(&rhs, 1, 1, FPFD_NUMBER);
  /* 10000000000000000011 */
  fpfd32_impl_set_manually(&lhs32, UINT32_C(0x8AC72304), UINT32_C(0x89E8000B));
  /* 1000000000000000003 */
  fpfd32_impl_set_manually(&rhs32, UINT32_C(0x0DE0B6B3), UINT32_C(0xA7640003));
  fpfd_impl_assert_orma2esfv(impl_addsub, &res, 1, &lhs, &rhs,
                             0, 1, FPFD_NUMBER, 0);
  fpfd32_impl_assert_mant(&res32, UINT32_C(0), UINT32_C(19));

  return exitstatus;
}
