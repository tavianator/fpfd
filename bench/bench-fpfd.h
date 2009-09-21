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
 * Routines which benchmark part of the programmer or implementation interfaces.
 * Each stores information about the number of clock ticks in a global hash
 * table, with strings describing the routine being profiled as the key.
 */

void fpfd32_bench_impl_expand(sandglass_t *sandglass, unsigned int trials);
void fpfd64_bench_impl_expand(sandglass_t *sandglass, unsigned int trials);
void fpfd128_bench_impl_expand(sandglass_t *sandglass, unsigned int trials);

void fpfd32_bench_impl_addsub(sandglass_t *sandglass, unsigned int trials);

void fpfd32_bench_impl_mul(sandglass_t *sandglass, unsigned int trials);
void fpfd64_bench_impl_mul(sandglass_t *sandglass, unsigned int trials);

void fpfd32_bench_impl_div(sandglass_t *sandglass, unsigned int trials);
void fpfd32_bench_impl_scale(sandglass_t *sandglass, unsigned int trials);
void fpfd32_bench_impl_inc(sandglass_t *sandglass, unsigned int trials);

void fpfd32_bench_impl_compress(sandglass_t *sandglass, unsigned int trials);
void fpfd64_bench_impl_compress(sandglass_t *sandglass, unsigned int trials);
void fpfd128_bench_impl_compress(sandglass_t *sandglass, unsigned int trials);

void fpfd32_bench_add(sandglass_t *sandglass, unsigned int trials);
void fpfd32_bench_sub(sandglass_t *sandglass, unsigned int trials);
void fpfd32_bench_mul(sandglass_t *sandglass, unsigned int trials);
void fpfd32_bench_div(sandglass_t *sandglass, unsigned int trials);
void fpfd32_bench_fma(sandglass_t *sandglass, unsigned int trials);
