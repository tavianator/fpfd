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

/* void fpfd32_impl_expand(fpfd32_impl_t *dest, fpfd32_srcptr src); */

/*
 * Converts the densely-packed-decimal representation in src to the binary-
 * coded-decimal form in dest.
 */

        .text
.globl fpfd32_impl_expand
        .type fpfd32_impl_expand, @function
fpfd32_impl_expand:
        pushl %ebx
        movl 8(%esp), %eax
        movl 12(%esp), %ebx
        movl (%ebx), %ecx
        movl %ecx, %edx
        shrl $30, %edx
        andl $0x2, %edx
        negl %edx
        addl $1, %edx
        movl %edx, 12(%eax)     /* Map the sign bit from (1, 0) to (-1, +1) */
        movl %ecx, %edx
        /* Convert the trailing significand digits from DPD to BCD */
        andl $0x3FF, %edx
        movw fpfd_dpd2bcd(,%edx,2), %dx
        movl %ecx, %ebx
        shrl $10, %ebx
        andl $0x3FF, %ebx
        movw fpfd_dpd2bcd(,%ebx,2), %bx
        shll $12, %ebx
        orl %edx, %ebx
        shrl $20, %ecx
        andl $0x7FF, %ecx
        movl %ecx, %edx
        andl $0x600, %edx
        cmpl $0x600, %edx
        je .Lc1i                /* If the combination field begins with 11, */
                                /* follow 754-2008, S3.5.2, p11, c.1.i */
        movl %ecx, %edx
        andl $0x1C0, %edx
        shll $18, %edx
        orl %edx, %ebx
        jz .Lzero
        movl %ebx, (%eax)       /* Get the leading significand digit */
        movl $0, 4(%eax)        /* Set the high-order significand bits to 0 */
        movl %ecx, %edx
        andl $0x3F, %ecx
        andl $0x600, %edx
        shrl $3, %edx
        orl %ecx, %edx
        subl $101, %edx
        movl %edx, 8(%eax)      /* Subtract the bias and store the exponent */
        movl $1, 16(%eax)       /* Set the special flag to FPFD_NUMBER */
        popl %ebx
        ret
.Lc1i:
        movl %ecx, %edx
        andl $0x7E0, %edx
        cmpl $0x7E0, %edx
        je .LsNaN
        cmpl $0x7C0, %edx
        je .LqNaN
        andl $0x7C0, %edx
        cmpl $0x780, %edx
        je .Linf
        movl %ecx, %edx
        andl $0x040, %edx
        orl $0x200, %edx
        shll $18, %edx
        orl %edx, %ebx
        movl %ebx, (%eax)       /* Get the leading significand digit */
        movl $0, 4(%eax)        /* Set the high-order significand bits to 0 */
        movl %ecx, %edx
        andl $0x3F, %ecx
        andl $0x180, %edx
        shrl %edx
        orl %ecx, %edx
        subl $101, %edx
        movl %edx, 8(%eax)      /* Subtract the bias and store the exponent */
        movl $1, 16(%eax)       /* Set the special flag to FPFD_NUMBER */
        popl %ebx
        ret
.Lzero:
        movl $0, (%eax)
        movl $0, 4(%eax)
        movl $0, 8(%eax)
        movl $0, 16(%eax)       /* Set the special flag to FPFD_ZERO */
        popl %ebx
        ret
.LsNaN:
        movl %ebx, (%eax)
        movl $0, 4(%eax)
        movl $0, 8(%eax)
        movl $2, 16(%eax)       /* Set the special flag to FPFD_SNAN */
        popl %ebx
        ret
.LqNaN:
        movl %ebx, (%eax)
        movl $0, 4(%eax)
        movl $0, 8(%eax)
        movl $3, 16(%eax)       /* Set the special flag to FPFD_QNAN */
        popl %ebx
        ret
.Linf:
        movl %ebx, (%eax)
        movl $0, 4(%eax)
        movl $0, 8(%eax)
        movl $4, 16(%eax)       /* Set the special flag to FPFD_INF */
        popl %ebx
        ret
        .size fpfd32_impl_expand, .-fpfd32_impl_expand
