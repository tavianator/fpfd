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
 * Converts the compact binary representation in src to the expanded form
 * dest.
 */

        .text
.globl fpfd32_impl_expand
        .type fpfd32_impl_expand, @function
fpfd32_impl_expand:
        movl (%rsi), %ecx
        movl %ecx, %edx
        shrl $30, %edx
        andl $0x2, %edx
        negl %edx
        incl %edx
        movl %edx, 12(%rdi)     /* Map the sign bit from (1, 0) to (-1, +1) */
        movl %ecx, %edx
        shrl $20, %edx
        andl $0x7FF, %edx       /* Get the combination field */
        movl %edx, %eax
        andl $0x600, %eax
        cmpl $0x600, %eax
        je .L2ii                /* If the combination field begins with 11,
                                   follow 754r DRAFT 1.5.0, S3.5, p19, 2.ii */
        shrl $3, %edx
        subl $101, %edx
        movl %edx, 8(%rdi)      /* Subtract bias and store exponent */
        andl $0x007FFFFF, %ecx
        testl %ecx, %ecx
        jz .Lzero               /* Test for a zero mantissa to support
                                   FPFD_ZERO */
        movl %ecx, (%rdi)       /* Return concatenated significand */
        movl $0, 4(%rdi)        /* Set the high-order significand bits to 0 */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L2ii:
        movl %edx, %eax
        andl $0x7E0, %eax
        cmpl $0x7E0, %eax
        je .LsNaN
        cmpl $0x7C0, %eax
        je .LqNaN
        andl $0x7C0, %eax
        cmpl $0x780, %eax
        je .Linf
        shrl %edx
        andl $0xFF, %edx
        subl $101, %edx
        movl %edx, 8(%rdi)      /* Subtract bias and store exponent */
        andl $0x001FFFFF, %ecx
        orl $0x00800000, %ecx
        cmpl $10000000, %ecx
        jae .Lzero              /* If the significand exceeds the maximum
                                   significand of the decimal encoding, zero is
                                   used instead */
        movl %ecx, (%rdi)       /* Return concatenated significand */
        movl $0, 4(%rdi)        /* Set the high-order significand bits to 0 */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.Lzero:  
        movq $0, (%rdi)
        movl $0, 8(%rdi)
        movl $0, 16(%rdi)       /* Set the special flag to FPFD_ZERO */
        ret
.LsNaN:
        movl $2, 16(%rdi)       /* Set the special flag to FPFD_SNAN */
        andl $0x000FFFFF, %ecx
        cmpl $1000000, %ecx
        jae .LNaNzero           /* If the payload exceeds the maximum payload of
                                   the decimal encoding, zero is used instead */
        movl %ecx, (%rdi)
        movl $0, 4(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        ret
.LqNaN:
        movl $3, 16(%rdi)       /* Set the special flag to FPFD_QNAN */
        andl $0x000FFFFF, %ecx
        cmpl $1000000, %ecx
        jae .LNaNzero           /* If the payload exceeds the maximum payload of
                                   the decimal encoding, zero is used instead */
        movl %ecx, (%rdi)
        movl $0, 4(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        ret
.LNaNzero:
        movq $0, (%rdi)         /* Set the payload to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        ret
.Linf:
        movq $0, (%rdi)         /* Set the payload to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        movl $4, 16(%rdi)       /* Set the special flag to FPFD_INF */
        ret
        .size fpfd32_impl_expand, .-fpfd32_impl_expand
