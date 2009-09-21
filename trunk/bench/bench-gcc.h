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

void gcc32_bench_add(sandglass_t *sandglass, unsigned int trials);
void gcc64_bench_add(sandglass_t *sandglass, unsigned int trials);
void gcc128_bench_add(sandglass_t *sandglass, unsigned int trials);

void gcc32_bench_sub(sandglass_t *sandglass, unsigned int trials);
void gcc64_bench_sub(sandglass_t *sandglass, unsigned int trials);
void gcc128_bench_sub(sandglass_t *sandglass, unsigned int trials);

void gcc32_bench_mul(sandglass_t *sandglass, unsigned int trials);
void gcc64_bench_mul(sandglass_t *sandglass, unsigned int trials);
void gcc128_bench_mul(sandglass_t *sandglass, unsigned int trials);

void gcc32_bench_div(sandglass_t *sandglass, unsigned int trials);
void gcc64_bench_div(sandglass_t *sandglass, unsigned int trials);
void gcc128_bench_div(sandglass_t *sandglass, unsigned int trials);

/* For casting between fpfd*_t and _Decimal* */

typedef union {
  fpfd32_t fpfd;
  _Decimal32 dec;
} fpfd32_union_t;

typedef union {
  fpfd64_t fpfd;
  _Decimal64 dec;
} fpfd64_union_t;

typedef union {
  fpfd128_t fpfd;
  _Decimal128 dec;
} fpfd128_union_t;

/* Prototypes for internal GCC functions */

_Decimal32 __dpd_addsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __dpd_adddd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __dpd_addtd3(_Decimal128 lhs, _Decimal128 rhs);

_Decimal32 __dpd_subsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __dpd_subdd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __dpd_subtd3(_Decimal128 lhs, _Decimal128 rhs);

_Decimal32 __dpd_mulsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __dpd_muldd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __dpd_multd3(_Decimal128 lhs, _Decimal128 rhs);

_Decimal32 __dpd_divsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __dpd_divdd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __dpd_divtd3(_Decimal128 lhs, _Decimal128 rhs);

_Decimal32 __bid_addsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __bid_adddd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __bid_addtd3(_Decimal128 lhs, _Decimal128 rhs);

_Decimal32 __bid_subsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __bid_subdd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __bid_subtd3(_Decimal128 lhs, _Decimal128 rhs);

_Decimal32 __bid_mulsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __bid_muldd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __bid_multd3(_Decimal128 lhs, _Decimal128 rhs);

_Decimal32 __bid_divsd3(_Decimal32 lhs, _Decimal32 rhs);
_Decimal64 __bid_divdd3(_Decimal64 lhs, _Decimal64 rhs);
_Decimal128 __bid_divtd3(_Decimal128 lhs, _Decimal128 rhs);
