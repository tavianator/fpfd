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
 * must be scaled.
 */

        .text
.globl fpfd32_impl_compress
        .type fpfd32_impl_compress, @function
fpfd32_impl_compress:
        pushl %ebx
        movl 12(%esp), %ecx     /* Put src in ecx */
        movl 16(%ecx), %edx     /* Handle zeros, sNaN, qNaN, and infinities */
        testl %edx, %edx
        jz .Lzero
        cmpl $2, %edx
        je .LsNaN
        cmpl $3, %edx
        je .LqNaN
        cmpl $4, %edx
        je .Linf
        movl (%ecx), %eax
        movl %eax, %edx
        andl $0xFFF, %edx
        movw fpfd_bcd2dpd(,%edx,2), %dx
        movl %eax, %ebx
        shrl $12, %ebx
        andl $0xFFF, %ebx
        movw fpfd_bcd2dpd(,%ebx,2), %bx
        shll $10, %ebx
        orl %ebx, %edx          /* Get the trailing significand */
        andl $0xF000000, %eax
        shll $2, %eax
        orl %edx, %eax          /* Put the leading significand digit in place */
        movl $1, %ebx
        subl 12(%ecx), %ebx
        shll $30, %ebx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl 8(%ecx), %edx
        addl $101, %edx         /* Get the biased exponent */
        testl $0x20000000, %eax
        jnz .L1i                /* The leading digit is big */
        movl %edx, %ecx
        andl $0xC0, %ecx
        andl $0x3F, %edx
        shll $20, %edx
        shll $23, %ecx
        orl %edx, %eax          /* The low bits of the exponent */
        orl %ecx, %eax          /* The high bits of the exponent */
        orl %ebx, %eax          /* The sign bit */
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.L1i:
        andl $0x4FFFFFF, %eax
        movl %edx, %ecx
        andl $0xC0, %ecx
        andl $0x3F, %edx
        shll $20, %edx
        shll $21, %ecx
        orl %edx, %eax          /* The low bits of the exponent */
        orl %ecx, %eax          /* The high bits of the exponent */
        orl $0x60000000, %eax   /* Indicate a big leading digit */
        orl %ebx, %eax          /* The sign bit */
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.Lzero:
        movl $1, %ebx
        subl 12(%ecx), %ebx
        shll $30, %ebx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl $0x22500000, %eax
        orl %ebx, %eax          /* The sign bit */
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.LsNaN:
        movl (%ecx), %edx
        movl %edx, %eax
        andl $0xFFF, %eax
        movw fpfd_bcd2dpd(,%eax,2), %ax
        movl %edx, %ebx
        shrl $12, %ebx
        andl $0xFFF, %ebx
        movw fpfd_bcd2dpd(,%ebx,2), %bx
        shll $10, %ebx
        orl %ebx, %eax          /* Get the trailing significand */
        movl $1, %ebx
        subl 12(%ecx), %ebx
        shll $30, %ebx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        orl $0x7E000000, %eax
        orl %ebx, %eax          /* The sign bit */
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.LqNaN:
        movl (%ecx), %edx
        movl %edx, %eax
        andl $0xFFF, %eax
        movw fpfd_bcd2dpd(,%eax,2), %ax
        movl %edx, %ebx
        shrl $12, %ebx
        andl $0xFFF, %ebx
        movw fpfd_bcd2dpd(,%ebx,2), %bx
        shll $10, %ebx
        orl %ebx, %eax          /* Get the trailing significand */
        movl $1, %ebx
        subl 12(%ecx), %ebx
        shll $30, %ebx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        orl $0x7C000000, %eax
        orl %ebx, %eax          /* The sign bit */
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
.Linf:   
        movl $1, %ebx
        subl 12(%ecx), %ebx
        shll $30, %ebx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl $0x78000000, %eax
        orl %ebx, %eax          /* The sign bit */
        movl 8(%esp), %ecx
        movl %eax, (%ecx)
        popl %ebx
        ret
        .size fpfd32_impl_compress, .-fpfd32_impl_compress
