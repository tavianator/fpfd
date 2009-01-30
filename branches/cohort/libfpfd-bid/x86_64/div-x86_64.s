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

/* unsigned int fpfd32_impl_div(fpfd32_impl_t *dest,
                                const fpfd32_impl_t *lhs,
                                const fpfd32_impl_t *rhs); */

/*
 * Divide lhs by rhs, and put the result in dest.
 */

        .text
.globl fpfd32_impl_div
        .type fpfd32_impl_div, @function
fpfd32_impl_div:
        movl 12(%rsi), %ecx
        xorl 12(%rdx), %ecx     /* XOR the signs: 1 (...0001) XOR -1 (...1111)
                                   gives -2 (...1110), x XOR x gives 0 */
        addl $1, %ecx           /* Add one to go from (-2, 0) to (-1, 1) */
        movl %ecx, 12(%rdi)     /* Store the sign in dest->fields.sign */
        movl 8(%rsi), %ecx
        subl 8(%rdx), %ecx      /* Subtract the exponents */
        movl %ecx, 20(%rdi)     /* Store the cohort */
        subl $6, %ecx           /* We multiply the quotient by 1000000 to ensure
                                   full precision */
        movl %ecx, 8(%rdi)      /* Store the exponent in dest->fields.exp */
        movl (%rsi), %eax
        movl (%rdx), %ecx
        xorl %edx, %edx
        divl %ecx               /* Divide the mantissas */
        movl %edx, %r8d         /* Store the remainder for later */
        movl $1000000, %r9d     /* Multiply the quotient by 1000000 */
        mulq %r9
        movq %rax, %r10
        movl %r8d, %eax
        mull %r9d               /* Multiply the remainder by 1000000 */
        divl %ecx               /* Divide by the denominator */
        addq %rax, %r10         /* Add the scaled remainder to the mantissa */
        movq %r10, (%rdi)       /* Store the mantissa */
        movl $10, %eax
        mull %edx
        divl %ecx
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        cmpl $0, %eax
        je .Lspecial
        cmpl $5, %eax
        je .Lspecial
        ret
.Lspecial:
        cmpl $0, %edx
        je .Lspecial1
        addl $1, %eax
.Lspecial1:
        ret
        .size fpfd32_impl_div, .-fpfd32_impl_div
