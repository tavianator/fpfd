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

/*
 * Converts the compact binary representation in src to the expanded form
 * dest.
 */

        .text
/* void fpfd32_impl_expand(fpfd32_impl_t *dest, fpfd32_srcptr src); */
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
        je .L32_c2ii            /* If the combination field begins with 11,
                                   follow 754-2008, S3.5.2, c.2.ii */
        shrl $3, %edx
        subl $101, %edx
        movl %edx, 8(%rdi)      /* Subtract bias and store exponent */
        andl $0x007FFFFF, %ecx
        testl %ecx, %ecx
        jz .L32_zero            /* Test for a zero mantissa to support
                                   FPFD_ZERO */
        movl %ecx, (%rdi)       /* Return concatenated significand */
        movl $0, 4(%rdi)        /* Set the high-order significand bits to 0 */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L32_c2ii:
        movl %edx, %eax
        andl $0x7E0, %eax
        cmpl $0x7E0, %eax
        je .L32_sNaN
        cmpl $0x7C0, %eax
        je .L32_qNaN
        andl $0x7C0, %eax
        cmpl $0x780, %eax
        je .L32_inf
        shrl %edx
        andl $0xFF, %edx
        subl $101, %edx
        movl %edx, 8(%rdi)      /* Subtract bias and store exponent */
        andl $0x001FFFFF, %ecx
        orl $0x00800000, %ecx
        cmpl $10000000, %ecx
        jae .L32_zero           /* If the significand exceeds the maximum
                                   significand of the decimal encoding, zero is
                                   used instead */
        movl %ecx, (%rdi)       /* Return concatenated significand */
        movl $0, 4(%rdi)        /* Set the high-order significand bits to 0 */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L32_zero:  
        movq $0, (%rdi)
        movl $0, 8(%rdi)
        movl $0, 16(%rdi)       /* Set the special flag to FPFD_ZERO */
        ret
.L32_sNaN:
        movl $2, 16(%rdi)       /* Set the special flag to FPFD_SNAN */
        andl $0x000FFFFF, %ecx
        cmpl $1000000, %ecx
        jae .L32_NaNzero        /* If the payload exceeds the maximum payload of
                                   the decimal encoding, zero is used instead */
        movl %ecx, (%rdi)
        movl $0, 4(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        ret
.L32_qNaN:
        movl $3, 16(%rdi)       /* Set the special flag to FPFD_QNAN */
        andl $0x000FFFFF, %ecx
        cmpl $1000000, %ecx
        jae .L32_NaNzero        /* If the payload exceeds the maximum payload of
                                   the decimal encoding, zero is used instead */
        movl %ecx, (%rdi)
        movl $0, 4(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        ret
.L32_NaNzero:
        movq $0, (%rdi)         /* Set the payload to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        ret
.L32_inf:
        movq $0, (%rdi)         /* Set the payload to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        movl $4, 16(%rdi)       /* Set the special flag to FPFD_INF */
        ret
        .size fpfd32_impl_expand, .-fpfd32_impl_expand

/* void fpfd64_impl_expand(fpfd64_impl_t *dest, fpfd64_srcptr src); */
.globl fpfd64_impl_expand
        .type fpfd64_impl_expand, @function
fpfd64_impl_expand:
        movq (%rsi), %rcx
        movq %rcx, %rdx
        shrq $62, %rdx
        andl $0x2, %edx
        negl %edx
        incl %edx
        movl %edx, 20(%rdi)     /* Map the sign bit from (1, 0) to (-1, +1) */
        movq %rcx, %rdx
        shrq $50, %rdx
        andl $0x1FFF, %edx      /* Get the combination field */
        movl %edx, %eax
        andl $0x1800, %eax
        cmpl $0x1800, %eax
        je .L64_c2ii            /* If the combination field begins with 11,
                                   follow 754-2008, S3.5.2, c.2.ii */
        shrl $3, %edx
        subl $398, %edx
        movl %edx, 16(%rdi)      /* Subtract bias and store exponent */
        movq $0x001FFFFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        testq %rcx, %rcx
        jz .L64_zero            /* Test for a zero mantissa to support
                                   FPFD_ZERO */
        movq %rcx, (%rdi)       /* Return concatenated significand */
        movq $0, 8(%rdi)        /* Set the high-order significand bits to 0 */
        movl $1, 24(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L64_c2ii:
        movl %edx, %eax
        andl $0x1F80, %eax
        cmpl $0x1F80, %eax
        je .L64_sNaN
        cmpl $0x1F00, %eax
        je .L64_qNaN
        andl $0x1F00, %eax
        cmpl $0x1E00, %eax
        je .L64_inf
        shrl %edx
        andl $0x3FF, %edx
        subl $398, %edx
        movl %edx, 16(%rdi)      /* Subtract bias and store exponent */
        movq $0x0007FFFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        movq $0x0020000000000000, %rdx
        orq %rdx, %rcx
        movq $10000000000000000, %rdx
        cmpq %rdx, %rcx
        jae .L64_zero           /* If the significand exceeds the maximum
                                   significand of the decimal encoding, zero is
                                   used instead */
        movq %rcx, (%rdi)       /* Return concatenated significand */
        movq $0, 8(%rdi)        /* Set the high-order significand bits to 0 */
        movl $1, 24(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L64_zero:  
        movq $0, (%rdi)
        movq $0, 8(%rdi)
        movl $0, 16(%rdi)
        movl $0, 24(%rdi)       /* Set the special flag to FPFD_ZERO */
        ret
.L64_sNaN:
        movl $2, 24(%rdi)       /* Set the special flag to FPFD_SNAN */
        movq $0x0003FFFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        movq $1000000000000000, %rdx
        cmpq %rdx, %rcx
        jae .L64_NaNzero        /* If the payload exceeds the maximum payload of
                                   the decimal encoding, zero is used instead */
        movq %rcx, (%rdi)
        movq $0, 8(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 16(%rdi)       /* Set the exponent to zero */
        ret
.L64_qNaN:
        movl $3, 16(%rdi)       /* Set the special flag to FPFD_QNAN */
        movq $0x0003FFFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        movq $1000000000000000, %rdx
        cmpq %rdx, %rcx
        jae .L64_NaNzero        /* If the payload exceeds the maximum payload of
                                   the decimal encoding, zero is used instead */
        movq %rcx, (%rdi)
        movq $0, 8(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 16(%rdi)       /* Set the exponent to zero */
        ret
.L64_NaNzero:
        movq $0, (%rdi)
        movq $0, 8(%rdi)        /* Set the payload to zero */
        movl $0, 16(%rdi)       /* Set the exponent to zero */
        ret
.L64_inf:
        movq $0, (%rdi)
        movq $0, 8(%rdi)        /* Set the payload to zero */
        movl $0, 16(%rdi)       /* Set the exponent to zero */
        movl $4, 24(%rdi)       /* Set the special flag to FPFD_INF */
        ret
        .size fpfd64_impl_expand, .-fpfd64_impl_expand

/* void fpfd128_impl_expand(fpfd128_impl_t *dest, fpfd128_srcptr src); */
.globl fpfd128_impl_expand
        .type fpfd128_impl_expand, @function
fpfd128_impl_expand:
        movq (%rsi), %r8        /* Low-order trailing significand */
        movq 8(%rsi), %rcx
        movq %rcx, %rdx
        shrq $62, %rdx
        andl $0x2, %edx
        negl %edx
        incl %edx
        movl %edx, 40(%rdi)     /* Map the sign bit from (1, 0) to (-1, +1) */
        movq %rcx, %rdx
        shrq $50, %rdx
        andl $0x1FFFF, %edx     /* Get the combination field */
        movl %edx, %eax
        andl $0x18000, %eax
        cmpl $0x18000, %eax
        je .L128_c2ii           /* If the combination field begins with 11,
                                   follow 754-2008, S3.5.2, c.2.ii */
        shrl $3, %edx
        subl $6176, %edx
        movl %edx, 36(%rdi)      /* Subtract bias and store exponent */
        movq $0x0001FFFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        testq %rcx, %rcx
        jnz .L128_nonzero
        testq %r8, %r8
        jz .L128_zero           /* Test for a zero mantissa to support
                                   FPFD_ZERO */
.L128_nonzero:
        movq %r8, (%rdi)
        movq %rcx, 8(%rdi)      /* Return concatenated significand */
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the high-order significand bits to 0 */
        movl $1, 44(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L128_c2ii:
        movl %edx, %eax
        andl $0x1F800, %eax
        cmpl $0x1F800, %eax
        je .L128_sNaN
        cmpl $0x1F000, %eax
        je .L128_qNaN
        andl $0x1F000, %eax
        cmpl $0x1E000, %eax
        je .L128_inf
        shrl %edx
        andl $0x3FFF, %edx
        subl $6176, %edx
        movl %edx, 36(%rdi)      /* Subtract bias and store exponent */
        movq $0x00007FFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        movq $0x0002000000000000, %rdx
        orq %rdx, %rcx
        movq $0x1ED09BEAD87C0, %rdx
        cmpq %rdx, %rcx
        ja .L128_zero           /* If the significand exceeds the maximum
                                   significand of the decimal encoding, zero is
                                   used instead */
        jb .L128_nottoobig
        movq $0x378D8E6400000000, %rdx
        cmpq %rdx, %r8
        jae .L128_zero
.L128_nottoobig:
        movq %r8, (%rdi)
        movq %rcx, 8(%rdi)      /* Return concatenated significand */
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the high-order significand bits to 0 */
        movl $1, 44(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L128_zero:  
        movq $0, (%rdi)
        movq $0, 8(%rdi)
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)
        movl $0, 36(%rdi)
        movl $0, 44(%rdi)       /* Set the special flag to FPFD_ZERO */
        ret
.L128_sNaN:
        movl $2, 44(%rdi)       /* Set the special flag to FPFD_SNAN */
        movq $0x00003FFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        movq $0x314DC6448D93, %rdx
        cmpq %rdx, %rcx
        ja .L128_NaNzero        /* If the payload exceeds the maximum
                                   payload of the decimal encoding, zero is
                                   used instead */
        jb .L128_NaNnottoobig
        movq $0x38C15B0A00000000, %rdx
        cmpq %rdx, %r8
        jae .L128_NaNzero
        jmp .L128_NaNnottoobig
.L128_qNaN:
        movl $3, 44(%rdi)       /* Set the special flag to FPFD_QNAN */
        movq $0x00003FFFFFFFFFFF, %rdx
        andq %rdx, %rcx
        movq $0x314DC6448D93, %rdx
        cmpq %rdx, %rcx
        ja .L128_NaNzero        /* If the payload exceeds the maximum
                                   payload of the decimal encoding, zero is
                                   used instead */
        jb .L128_NaNnottoobig
        movq $0x38C15B0A00000000, %rdx
        cmpq %rdx, %r8
        jae .L128_NaNzero
        jmp .L128_NaNnottoobig
.L128_NaNnottoobig:
        movq %r8, (%rdi)
        movq %rcx, 8(%rdi)
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the high-order payload bits to zero */
        movl $0, 36(%rdi)       /* Set the exponent to zero */
        ret
.L128_NaNzero:
        movq $0, (%rdi)
        movq $0, 8(%rdi)
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the payload to zero */
        movl $0, 36(%rdi)       /* Set the exponent to zero */
        ret
.L128_inf:
        movq $0, (%rdi)
        movq $0, 8(%rdi)
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the payload to zero */
        movl $0, 36(%rdi)       /* Set the exponent to zero */
        movl $4, 44(%rdi)       /* Set the special flag to FPFD_INF */
        ret
        .size fpfd128_impl_expand, .-fpfd128_impl_expand
