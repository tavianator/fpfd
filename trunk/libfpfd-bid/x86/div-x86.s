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
        pushl %ebx
        pushl %esi
        pushl %edi
        pushl %ebp      /* Callee-save registers */
        subl $4, %esp
        movl 24(%esp), %ebx
        movl 28(%esp), %esi
        movl 32(%esp), %edi     /* Put dest, lhs and rhs in ebx, esi and edi */
        movl 12(%esi), %ecx
        xorl 12(%edi), %ecx     /* XOR the signs: 1 (...0001) XOR -1 (...1111)
                                   gives -2 (...1110), x XOR x gives 0 */
        addl $1, %ecx           /* Add one to go from (-2, 0) to (-1, 1) */
        movl %ecx, 12(%ebx)     /* Store the sign in dest->fields.sign */
        movl 8(%esi), %ecx
        subl 8(%edi), %ecx      /* Subtract the exponents */
        movl %ecx, (%esp)       /* Store the exponent on the stack */
        movl (%esi), %eax
        movl (%edi), %ecx
        xorl %edx, %edx
        divl %ecx
        movl %eax, %ebx
        xorl %edi, %edi
        cmpl $1000000, %eax
        jae .Ldone
        movl $10000000, %ebp
.Ldivloop:
        movl %edx, %esi         /* Store the remainder for later */
        mull %ebp               /* Multiply the quotient by 10000000 */
        movl %edx, %edi
        movl %eax, %ebx
        movl %esi, %eax
        mull %ebp               /* Multiply the remainder by 10000000 */
        divl %ecx               /* Divide by the denominator */
        addl %eax, %ebx
        adcl $0, %edi           /* Add the scaled remainder to the mantissa */
        movl %ebx, %eax
        subl $7, (%esp)         /* Correct the exponent */
        testl %edi, %edi
        jnz .Ldone
        cmpl $1000000, %eax
        jb .Ldivloop
.Ldone:
        movl $10, %eax
        mull %edx
        divl %ecx
        movl 24(%esp), %ecx     /* Put dest in ebx */
        movl %ebx, (%ecx)
        movl %edi, 4(%ecx)      /* Store the mantissa */
        movl (%esp), %ebx
        movl %ebx, 8(%ecx)      /* Store the exponent */
        movl $1, 16(%ecx)       /* Set the special flag to FPFD_NUMBER */
        testl %eax, %eax
        jz .Lspecial
        cmpl $5, %eax
        je .Lspecial
        addl $4, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lspecial:
        testl %edx, %edx
        jz .Lspecial1
        addl $1, %eax
.Lspecial1:
        addl $4, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_div, .-fpfd32_impl_div
