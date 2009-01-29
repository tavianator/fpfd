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
        movl (%rsi), %eax       /* Put src->mant in eax */
        movl %eax, %ecx
        movl %eax, %edx
        /* Convert the BCD digits to DPD */
        movq fpfd_bcd2dpd@GOTPCREL(%rip), %r8   /* For position-independance */
        andq $0xFFF, %rcx
        movw (%r8,%rcx,2), %cx  /* Lowest three digits */
        shrl $12, %edx
        andq $0xFFF, %rdx
        movw (%r8,%rdx,2), %dx  /* Highest three digits */
        shll $10, %edx
        orl %ecx, %edx          /* Complete trailing significand */
        andl $0xF000000, %eax   /* Leading digit */
        shll $2, %eax
        orl %edx, %eax          /* Put the leading significand digit in place */
        movl 12(%rsi), %ecx     /* Put src->fields.sign in ecx */
        subl $1, %ecx
        negl %ecx
        shll $30, %ecx          /* Map the sign bit from (-1, +1) to (1, 0), and
                                   shift it to the MSB */
        movl 16(%rsi), %edx     /* Handle zeros, sNaN, qNaN, and infinities */
        cmpl $0, %edx
        je .Lzero
        cmpl $2, %edx
        je .LsNaN
        cmpl $3, %edx
        je .LqNaN
        cmpl $4, %edx
        je .Linf
        movl 8(%rsi), %edx      /* Put src->fields.exp in edx */
        addl $101, %edx         /* Add the bias */
        testl $0x20000000, %eax
        jnz .L1i                /* Test for a big leading digit (8 or 9) */
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
.L1i:
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
.Lzero:
        movl $0x22500000, %eax  /* A zero mantissa and exponent */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.LsNaN:
        orl $0x7E000000, %eax   /* Indicate a signalling NaN */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.LqNaN:
        orl $0x7C000000, %eax   /* Indicate a quiet NaN */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
.Linf:   
        movl $0x78000000, %eax  /* An infinity, with zero payload */
        orl %ecx, %eax          /* The sign bit */
        movl %eax, (%rdi)       /* Store the result in dest */
        ret
        .size fpfd32_impl_compress, .-fpfd32_impl_compress
