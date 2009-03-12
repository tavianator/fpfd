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
 * must be scaled.
 */

        .text
/* void fpfd32_impl_compress(fpfd32_ptr dest, const fpfd32_impl_t *src); */
.globl fpfd32_impl_compress
        .type fpfd32_impl_compress, @function
fpfd32_impl_compress:
        movl 16(%rsi), %r9d     /* Handle zeros and infinities */
        testl %r9d, %r9d
        jz .L32_zero
        cmpl $4, %r9d
        je .L32_inf
        movl (%rsi), %eax       /* Put src->mant in eax */
        /* Convert the BCD digits to DPD */
        movl %eax, %ecx
        movl %eax, %edx
        movq fpfd_bcd2dpd@GOTPCREL(%rip), %r8   /* For position-independance */
        andl $0xFFF, %ecx
        shrl $12, %edx
        andl $0xFFF, %edx
        movw (%r8,%rcx,2), %cx  /* Lowest three digits */
        movw (%r8,%rdx,2), %dx  /* Highest three digits */
        shll $10, %edx
        orl %ecx, %edx          /* Complete trailing significand */
        andl $0xF000000, %eax   /* Leading digit */
        shll $2, %eax
        orl %edx, %eax          /* Put the leading significand digit in place */
        movl $1, %ecx
        subl 12(%rsi), %ecx
        shll $30, %ecx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        cmpl $2, %r9d           /* Handle NaNs */
        je .L32_sNaN
        cmpl $3, %r9d
        je .L32_qNaN
        movl 8(%rsi), %edx      /* Put src->fields.exp in edx */
        addl $101, %edx         /* Add the bias */
        testl $0x20000000, %eax
        jnz .L32_1i             /* Test for a big leading digit (8 or 9) */
        movl %edx, %esi
        andl $0xC0, %esi        /* Get the trailing exponent bits */
        andl $0x3F, %edx        /* Get the leading exponent bits */
        shll $20, %edx
        shll $23, %esi
        orl %esi, %eax          /* The trailing exponent bits */
        orl %edx, %eax          /* The leading exponent bits*/
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L32_1i:
        andl $0x4FFFFFF, %eax   /* Mask off the highest bit of the big digit */
        movl %edx, %esi
        andl $0xC0, %esi        /* Get the trailing exponent bits */
        andl $0x3F, %edx        /* Get the leading exponent bits */
        shll $20, %edx
        shll $21, %esi
        orl %esi, %eax          /* The trailing exponent bits */
        orl %edx, %eax          /* The leading exponent bits*/
        orl $0x60000000, %eax   /* Indicate a big leading digit */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L32_zero:
        movl $1, %ecx
        subl 12(%rsi), %ecx
        shll $30, %ecx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl $0x22500000, %eax  /* A zero mantissa and exponent */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L32_sNaN:
        orl $0x7E000000, %eax   /* Indicate a signalling NaN */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L32_qNaN:
        orl $0x7C000000, %eax   /* Indicate a quiet NaN */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L32_inf:   
        movl $1, %ecx
        subl 12(%rsi), %ecx
        shll $30, %ecx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl $0x78000000, %eax  /* An infinity, with zero payload */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
        .size fpfd32_impl_compress, .-fpfd32_impl_compress

/* void fpfd64_impl_compress(fpfd64_ptr dest, const fpfd64_impl_t *src); */
.globl fpfd64_impl_compress
        .type fpfd64_impl_compress, @function
fpfd64_impl_compress:
        movl 24(%rsi), %r9d     /* Handle zeros and infinities */
        testl %r9d, %r9d
        jz .L64_zero
        cmpl $4, %r9d
        je .L64_inf
        movq (%rsi), %rax       /* Put src->mant in eax */
        /* Convert the BCD digits to DPD */
        movq fpfd_bcd2dpd@GOTPCREL(%rip), %r8   /* For position-independance */
        movl %eax, %ecx
        movl %eax, %edx
        movq %rax, %r9
        movq %rax, %r10
        movq %rax, %r11
        andl $0xFFF, %ecx
        shrl $12, %edx
        andl $0xFFF, %edx
        shrq $24, %r9
        andl $0xFFF, %r9d
        shrq $36, %r10
        andl $0xFFF, %r10d
        shrq $48, %r11
        andl $0xFFF, %r11d
        movw (%r8,%rcx,2), %cx          /* First declet */
        movw (%r8,%rdx,2), %dx          /* Decond declet */
        movw (%r8,%r9,2), %r9w          /* Third declet */
        movw (%r8,%r10,2), %r10w        /* Fourth declet */
        movw (%r8,%r11,2), %r11w        /* Fifth declet */
        shll $10, %edx
        orl %ecx, %edx
        shll $20, %r9d
        orl %r9d, %edx
        shlq $30, %r10
        orq %r10, %rdx
        shlq $40, %r11
        orq %r11, %rdx
        /* Complete trailing significand */
        movq $0xF000000000000000, %r8
        andq %r8, %rax          /* Leading digit */
        shlq $14, %rax
        orq %rdx, %rax          /* Put the leading significand digit in place */
        movl $1, %ecx
        subl 20(%rsi), %ecx
        shlq $62, %rcx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl 24(%rsi), %r9d     /* Handle zeros and infinities */
        cmpl $2, %r9d
        je .L64_sNaN
        cmpl $3, %r9d
        je .L64_qNaN
        movl 8(%rsi), %edx      /* Put src->fields.exp in edx */
        addl $398, %edx         /* Add the bias */
        /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
        testl $0x20000000, %eax
        jnz .L64_1i             /* Test for a big leading digit (8 or 9) */
        movl %edx, %esi
        andl $0xC0, %esi        /* Get the trailing exponent bits */
        andl $0x3F, %edx        /* Get the leading exponent bits */
        shll $20, %edx
        shll $23, %esi
        orl %esi, %eax          /* The trailing exponent bits */
        orl %edx, %eax          /* The leading exponent bits*/
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L64_1i:
        andl $0x4FFFFFF, %eax   /* Mask off the highest bit of the big digit */
        movl %edx, %esi
        andl $0xC0, %esi        /* Get the trailing exponent bits */
        andl $0x3F, %edx        /* Get the leading exponent bits */
        shll $20, %edx
        shll $21, %esi
        orl %esi, %eax          /* The trailing exponent bits */
        orl %edx, %eax          /* The leading exponent bits*/
        orl $0x60000000, %eax   /* Indicate a big leading digit */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L64_zero:
        movl $1, %ecx
        subl 12(%rsi), %ecx
        shll $30, %ecx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl $0x22500000, %eax  /* A zero mantissa and exponent */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L64_sNaN:
        orl $0x7E000000, %eax   /* Indicate a signalling NaN */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L64_qNaN:
        orl $0x7C000000, %eax   /* Indicate a quiet NaN */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.L64_inf:   
        movl $1, %ecx
        subl 12(%rsi), %ecx
        shll $30, %ecx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl $0x78000000, %eax  /* An infinity, with zero payload */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
        .size fpfd64_impl_compress, .-fpfd64_impl_compress
