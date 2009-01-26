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
 * Ensure that fpfd.h can be included in a C++ program and behave properly.
 */
int
main()
{
  fpfd_flags_t flags;
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(res); /* Result */

  /* Ensure that a pretty standard operation compiles and works */
  fpfd_set(pz, zero);
  fpfd_assert_ora2msfx(mul, res, pz, pz, FPFD_RNDN, 1, FPFD_ZERO, FPFD_NONE);

  /* fpfd_flags_t can't be an enum type for this conversion to work */
  flags = FPFD_UNDERFLOW | FPFD_INEXACT;

  return exitstatus;
}
