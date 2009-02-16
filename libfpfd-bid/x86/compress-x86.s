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

/* void fpfd32_impl_compress(fpfd32_ptr dest, const fpfd32_impl_t *src); */

/*
 * Shrinks the expanded encoding in src to the compact encoding in dest. Src
 * must be normalized.
 */

        .text
.globl fpfd32_impl_compress
        .type fpfd32_impl_compress, @function
fpfd32_impl_compress:
        pushl %ebx
        movl 12(%esp), %ecx
        movl (%ecx), %eax       /* Get the coefficient */
        movl 12(%ecx), %ebx
        subl $1, %ebx
        negl %ebx
        shll $30, %ebx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl 16(%ecx), %edx     /* Handle zeros, sNaN, qNaN, and infinities */
        testl %edx, %edx
        jz .Lzero
        cmpl $2, %edx
        je .LsNaN
        cmpl $3, %edx
        je .LqNaN
        cmpl $4, %edx
        je .Linf
        movl 8(%ecx), %edx
        addl $101, %edx         /* Get the biased exponent */
        testl $0x800000, %eax
        jnz .L2ii
        shll $23, %edx
        orl %edx, %eax
        orl %ebx, %eax
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.L2ii:
        andl $0x1FFFFF, %eax
        shll $21, %edx
        orl %edx, %eax
        orl $0x60000000, %eax
        orl %ebx, %eax
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.Lzero:
        movl $0x32800000, %eax
        orl %ebx, %eax
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.LsNaN:
        orl $0x7E000000, %eax
        orl %ebx, %eax
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.LqNaN:
        orl $0x7C000000, %eax
        orl %ebx, %eax
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.Linf:   
        movl $0x78000000, %eax
        orl %ebx, %eax
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
        .size fpfd32_impl_compress, .-fpfd32_impl_compress
