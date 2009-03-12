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
 * Shrinks the expanded encoding in src to the compact encoding in dest. Src
 * must be normalized.
 */

        .text
/* void fpfd32_impl_compress(fpfd32_ptr dest, const fpfd32_impl_t *src); */
.globl fpfd32_impl_compress
        .type fpfd32_impl_compress, @function
fpfd32_impl_compress:
        movl (%rsi), %eax       /* Get the coefficient */
        movl 12(%rsi), %ecx
        subl $1, %ecx
        negl %ecx
        shll $30, %ecx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl 16(%rsi), %edx     /* Handle zeros, sNaN, qNaN, and infinities */
        testl %edx, %edx
        jz .L32_zero
        cmpl $2, %edx
        je .L32_sNaN
        cmpl $3, %edx
        je .L32_qNaN
        cmpl $4, %edx
        je .L32_inf
        movl 8(%rsi), %edx
        addl $101, %edx         /* Get the biased exponent */
        testl $0x800000, %eax
        jnz .L32_c2ii           /* Significand has highest bit set */
        shll $23, %edx
        orl %edx, %eax          /* The exponent */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)
        ret
.L32_c2ii:
        andl $0x1FFFFF, %eax
        shll $21, %edx
        orl %edx, %eax          /* The exponent */
        orl $0x60000000, %eax   /* Indicate the highest significand bit */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)
        ret
.L32_zero:
        movl $0x32800000, %eax
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)
        ret
.L32_sNaN:
        orl $0x7E000000, %eax
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)
        ret
.L32_qNaN:
        orl $0x7C000000, %eax
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)
        ret
.L32_inf:   
        movl $0x78000000, %eax
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)
        ret
        .size fpfd32_impl_compress, .-fpfd32_impl_compress

/* void fpfd64_impl_compress(fpfd64_ptr dest, const fpfd64_impl_t *src); */
.globl fpfd64_impl_compress
        .type fpfd64_impl_compress, @function
fpfd64_impl_compress:
        movq (%rsi), %rax       /* Get the coefficient */
        movl 20(%rsi), %ecx
        subl $1, %ecx
        negl %ecx
        shlq $62, %rcx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl 24(%rsi), %edx     /* Handle zeros, sNaN, qNaN, and infinities */
        testl %edx, %edx
        jz .L64_zero
        cmpl $2, %edx
        je .L64_sNaN
        cmpl $3, %edx
        je .L64_qNaN
        cmpl $4, %edx
        je .L64_inf
        movl 16(%rsi), %edx
        addl $398, %edx         /* Get the biased exponent */
        movq $0x20000000000000, %r8
        testq %r8, %rax
        jnz .L64_c2ii           /* Significand has highest bit set */
        shlq $53, %rdx
        orq %rdx, %rax          /* The exponent */
        orq %rcx, %rax          /* The sign bit */
        movq %rax, (%rdi)
        ret
.L64_c2ii:
        movq $0x7FFFFFFFFFFFF, %r8
        andq %r8, %rax
        shlq $51, %rdx
        orq %rdx, %rax          /* The exponent */
        movq $0x6000000000000000, %r8
        orq %r8, %rax           /* Indicate the highest significand bit */
        orq %rcx, %rax          /* The sign bit */
        movq %rax, (%rdi)
        ret
.L64_zero:
        movq $0x3280000000000000, %rax
        orq %rcx, %rax          /* The sign bit */
        movq %rax, (%rdi)
        ret
.L64_sNaN:
        movq $0x7E00000000000000, %r8
        orq %r8, %rax
        orq %rcx, %rax          /* The sign bit */
        movq %rax, (%rdi)
        ret
.L64_qNaN:
        movq $0x7C00000000000000, %r8
        orq %r8, %rax
        orq %rcx, %rax          /* The sign bit */
        movq %rax, (%rdi)
        ret
.L64_inf:   
        movq $0x7800000000000000, %rax
        orq %rcx, %rax          /* The sign bit */
        movq %rax, (%rdi)
        ret
        .size fpfd64_impl_compress, .-fpfd64_impl_compress

/* void fpfd128_impl_compress(fpfd128_ptr dest, const fpfd128_impl_t *src); */
.globl fpfd128_impl_compress
        .type fpfd128_impl_compress, @function
fpfd128_impl_compress:
        movq (%rsi), %r8
        movq 8(%rsi), %rax      /* Get the coefficient */
        movl 40(%rsi), %ecx
        subl $1, %ecx
        negl %ecx
        shlq $62, %rcx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl 44(%rsi), %edx     /* Handle zeros, sNaN, qNaN, and infinities */
        testl %edx, %edx
        jz .L128_zero
        cmpl $2, %edx
        je .L128_sNaN
        cmpl $3, %edx
        je .L128_qNaN
        cmpl $4, %edx
        je .L128_inf
        movl 36(%rsi), %edx
        addl $6176, %edx        /* Get the biased exponent */
        movq $0x2000000000000, %r9
        testq %r9, %rax
        jnz .L128_c2ii          /* Significand has highest bit set */
        shlq $49, %rdx
        orq %rdx, %rax          /* The exponent */
        orq %rcx, %rax          /* The sign bit */
        movq %r8, (%rdi)
        movq %rax, 8(%rdi)
        ret
.L128_c2ii:
        movq $0x7FFFFFFFFFFF, %r9
        andq %r9, %rax
        shlq $47, %rdx
        orq %rdx, %rax          /* The exponent */
        movq $0x6000000000000000, %r9
        orq %r9, %rax           /* Indicate the highest significand bit */
        orq %rcx, %rax          /* The sign bit */
        movq %r8, (%rdi)
        movq %rax, 8(%rdi)
        ret
.L128_zero:
        movq $0x3280000000000000, %rax
        orq %rcx, %rax          /* The sign bit */
        movq $0, (%rdi)
        movq %rax, 8(%rdi)
        ret
.L128_sNaN:
        movq $0x7E00000000000000, %r9
        orq %r9, %rax
        orq %rcx, %rax          /* The sign bit */
        movq %r8, (%rdi)
        movq %rax, 8(%rdi)
        ret
.L128_qNaN:
        movq $0x7C00000000000000, %r9
        orq %r9, %rax
        orq %rcx, %rax          /* The sign bit */
        movq %r8, (%rdi)
        movq %rax, 8(%rdi)
        ret
.L128_inf:   
        movq $0x7800000000000000, %rax
        orq %rcx, %rax          /* The sign bit */
        movq $0, (%rdi)
        movq %rax, 8(%rdi)
        ret
        .size fpfd128_impl_compress, .-fpfd128_impl_compress
