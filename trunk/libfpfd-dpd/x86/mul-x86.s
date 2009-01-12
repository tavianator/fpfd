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
        pushl %ebx
        pushl %esi
        pushl %edi              /* Callee-save registers */
        movl 20(%esp), %esi
        movl 24(%esp), %edi
        movl 8(%esi), %ebx
        addl 8(%edi), %ebx      /* Add the exponents */
        movl 12(%esi), %ecx
        xorl 12(%edi), %ecx     /* XOR the signs: 1 (...0001) XOR -1 (...1111)
                                   gives -2 (...1110), x XOR x gives 0 */
        addl $1, %ecx           /* Add one to go from (-2, 0) to (-1, 1) */
        movl 16(%esp), %esi
        movl %eax, (%esi)
        movl %edx, 4(%esi)      /* Store the mantissa */
        movl %ebx, 8(%esi)      /* Store the exponent */
        movl %ecx, 12(%esi)     /* Store the sign */
        movl $1, 16(%esi)       /* Set the special flag to FPFD_NUMBER */
        popl %edi
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_mul, .-fpfd32_impl_mul
