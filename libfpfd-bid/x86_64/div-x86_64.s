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
        movl 8(%rsi), %r11d
        subl 8(%rdx), %r11d     /* Subtract the exponents */
        movl (%rsi), %eax
        movl (%rdx), %ecx
        xorl %edx, %edx
        divl %ecx               /* Divide the mantissas */
        movl %eax, %r10d
        cmpl $1000000, %eax
        jae .Ldone
        movl $10000000, %r9d
.Ldivloop:
        movl %edx, %r8d         /* Store the remainder for later */
        mulq %r9                /* Multiply the quotient by 10**7 */
        movq %rax, %r10
        movl %r8d, %eax
        mull %r9d               /* Multiply the remainder by 10000000 */
        divl %ecx               /* Divide by the denominator */
        addq %rax, %r10         /* Add the scaled remainder to the mantissa */
        movq %r10, %rax
        subl $7, %r11d          /* Correct the exponent */
        cmpq $1000000, %r10
        jb .Ldivloop
.Ldone:
        movl $10, %eax
        mull %edx
        divl %ecx               /* Get the first digit of the remainder */
        movq %r10, (%rdi)       /* Store the mantissa */
        movl %r11d, 8(%rdi)     /* Store the exponent */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        testl %eax, %eax
        jz .Lspecial
        cmpl $5, %eax
        je .Lspecial
        ret
.Lspecial:
        testl %edx, %edx
        jz .Lspecial1
        addl $1, %eax
.Lspecial1:
        ret
        .size fpfd32_impl_div, .-fpfd32_impl_div
