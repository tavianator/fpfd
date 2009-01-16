/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library Benchmark Suite.                *
 *                                                                       *
 * The FPFD Library Benchmark Suite is free software; you can            *
 * redistribute it and/or modify it under the terms of the GNU General   *
 * Public License as published by the Free Software Foundation; either   *
 * version 3 of the License, or (at your option) any later version.      *
 *                                                                       *
 * The FPFD Library Benchmark Suite is distributed in the hope that it   *
 * will be useful, but WITHOUT ANY WARRANTY; without even the implied    *
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See *
 * the GNU General Public License for more details.                      *
 *                                                                       *
 * You should have received a copy of the GNU General Public License     *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *************************************************************************/

#include "bench.h"

/*
 * These routines benchmark GCC's internal _Decimal* type arithmetic.
 */

void gcc32_bench_add(unsigned int trials);
void gcc32_bench_sub(unsigned int trials);
void gcc32_bench_mul(unsigned int trials);
void gcc32_bench_div(unsigned int trials);

/* For casting between fpfd*_t and _Decimal* */
typedef union {
  fpfd32_t fpfd;
  _Decimal32 dec;
} fpfd32_union_t;
