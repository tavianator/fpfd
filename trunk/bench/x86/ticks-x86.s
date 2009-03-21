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

/*
 * Return the time stamp counter, and serialize the instruction
 */

        .text
/* long ticks(); */
.globl ticks
        .type ticks, @function
ticks:
        pushl %ebx              /* Callee-save register, clobbered by cpuid */
        pushl %esi
        cpuid                   /* Serialize */
        rdtsc                   /* Read time stamp counter */
        movl %eax, %esi         /* Store tsc */
        cpuid                   /* Serialize again */
        movl %esi, %eax
        popl %esi
        popl %ebx
        ret
        .size ticks, .-ticks
