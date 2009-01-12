/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library.                                *
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

/* void fpfd32_impl_mul(fpfd32_impl_t *dest,
                        const fpfd32_impl_t *lhs, const fpfd32_impl_t *rhs); */

/*
 * Multiply lhs and rhs, and put the result in dest.
 */

        .text
.globl fpfd32_impl_mul
        .type fpfd32_impl_mul, @function
fpfd32_impl_mul:
        movl 12(%rsi), %ecx
        xorl 12(%rdx), %ecx     /* XOR the signs: 1 (...0001) XOR -1 (...1111)
                                   gives -2 (...1110), x XOR x gives 0 */
        addl $1, %ecx           /* Add one to go from (-2, 0) to (-1, 1) */
        movl 8(%rsi), %r8d
        addl 8(%rdx), %r8d      /* Add the exponents */
        movl %r8d, 8(%rdi)      /* Store the exponent */
        movl %ecx, 12(%rdi)     /* Store the sign */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
        .size fpfd32_impl_mul, .-fpfd32_impl_mul
