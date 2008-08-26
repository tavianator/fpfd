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

#include "../libfpfd/fpfd.h"
#include "../libfpfd/fpfd_impl.h"
#include <stdio.h>  /* For FILE     */
#include <stdint.h> /* For uint32_t */

/*
 * Conversion to/from uint32_t's. Obviously, this is encoding dependant.
 */

void fpfd32_set_manually(fpfd32_ptr dest, uint32_t src);
void fpfd32_get_manually(uint32_t *dest, fpfd32_srcptr src);

void fpfd32_impl_set_manually(fpfd32_impl_t *dest, uint32_t h, uint32_t l);

/*
 * Return nonzero if, for example, the expanded mantissa == mant.
 */
int fpfd32_impl_check_mant(const fpfd32_impl_t *impl, uint32_t h, uint32_t l);
int fpfd32_check_mant(fpfd32_srcptr src, uint32_t mant);
int fpfd32_check_exp(fpfd32_srcptr src, int exp);
int fpfd32_check_sign(fpfd32_srcptr src, int sign);
int fpfd32_check_special(fpfd32_srcptr src, fpfd_special_t special);
int fpfd32_check_manually(fpfd32_srcptr src, uint32_t mask, uint32_t cmp);

/*
 * Functions to write fpfd-related things to a stream.
 */
const char *fpfd_rnd_str(fpfd_rnd_t rnd);
const char *fpfd_special_str(fpfd_special_t special);
void fpfd32_dump(FILE *file, fpfd32_srcptr fp);
void fpfd32_impl_dump(FILE *file, const fpfd32_impl_t *fp);
