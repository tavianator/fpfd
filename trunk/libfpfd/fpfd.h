/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library                                 *
 *                                                                       *
 * The FPFD Library is free software; you can redistribute it and/or     *
 * modify it under the terms of the GNU Lesser General Public License as *
 * published by the Free Software Foundation; either version 3 of the    *
 * License, or (at your option) any later version.                       *
 *                                                                       *
 * The FPFD Library is distributed in the hope that it will be useful,   *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 * Lesser General Public License for more details.                       *
 *                                                                       *
 * You should have received a copy of the GNU Lesser General Public      *
 * License along with this program.  If not, see                         *
 * <http://www.gnu.org/licenses/>.                                       *
 *************************************************************************/

#ifndef FPFD_H
#define FPFD_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  FPFD_RNDN, FPFD_RNDNA, FPFD_RNDZ, FPFD_RNDU, FPFD_RNDD
} fpfd_rnd_t;

typedef unsigned char fpfd32_t[4];

typedef       unsigned char *fpfd32_ptr;
typedef const unsigned char *fpfd32_srcptr;

/* Assignment */

void fpfd32_set(fpfd32_ptr dest, fpfd32_srcptr src);

/* Addition */

int fpfd32_add(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd);

/* Subtraction */

int fpfd32_sub(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd);

/* Multiplication */

int fpfd32_mul(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd);

/* Division */

int fpfd32_div(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd);

#ifdef __cplusplus
}
#endif

#endif /* FPFD_H */
