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
 * Converts the densely-packed-decimal representation in src to the binary-
 * coded-decimal form in dest.
 */

        .text
/* void fpfd32_impl_expand(fpfd32_impl_t *dest, fpfd32_srcptr src); */
.globl fpfd32_impl_expand
        .type fpfd32_impl_expand, @function
fpfd32_impl_expand:
        movl (%rsi), %eax       /* Put *src in eax */
        movl %eax, %edx
        shrl $30, %edx
        andl $0x2, %edx         /* Put sign bit << 1 in edx */
        subl $1, %edx
        negl %edx
        movl %edx, 12(%rdi)     /* Map the sign bit from (1, 0) to (-1, +1) */
        /* Convert the trailing significand digits from DPD to BCD */
        movq fpfd_dpd2bcd@GOTPCREL(%rip), %r8   /* For position-independance */
        movl %eax, %ecx
        movl %eax, %edx
        andl $0x3FF, %ecx
        shrl $10, %edx
        andl $0x3FF, %edx
        movw (%r8,%rcx,2), %cx  /* First declet */
        movw (%r8,%rdx,2), %dx  /* Second declet */
        shll $12, %edx
        orl %ecx, %edx          /* We have all 6 trailing digits now */
        shrl $20, %eax
        andl $0x7FF, %eax       /* Put combination field in eax */
        movl %eax, %ecx
        andl $0x600, %ecx
        cmpl $0x600, %ecx
        je .L32_c1i             /* If the combination field begins with 11,
                                   follow 754-2008, S3.5.2, p11, c.1.i */
        movl %eax, %ecx
        andl $0x1C0, %ecx
        shll $18, %ecx
        orl %ecx, %edx          /* Extract leading digit */
        jz .L32_zero            /* Test for a zero mantissa */
        movl %edx, (%rdi)       /* Store the BCD mantissa */
        movl $0, 4(%rdi)        /* Set the high-order significand bits to 0 */
        movl %eax, %ecx
        andl $0x3F, %eax        /* Trailing exponent bits */
        andl $0x600, %ecx
        shrl $3, %ecx           /* Leading exponent bits */
        orl %eax, %ecx
        subl $101, %ecx         /* Subtract the exponent bias */
        movl %ecx, 8(%rdi)      /* Store the exponent */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L32_c1i:
        /* The leading bits of the combination field determine special values */
        movl %eax, %ecx
        andl $0x7E0, %ecx
        cmpl $0x7E0, %ecx
        je .L32_sNaN            /* 111111 signifies sNaN */
        cmpl $0x7C0, %ecx
        je .L32_qNaN            /* 111110 signifies qNaN */
        andl $0x7C0, %ecx
        cmpl $0x780, %ecx
        je .L32_inf             /* 11110* signifies infinity */
        movl %eax, %ecx
        andl $0x040, %ecx
        orl $0x200, %ecx        /* Get the leading significand digit */
        shll $18, %ecx
        orl %ecx, %edx          /* Put the leading digit in place */
        movl %edx, (%rdi)       /* Store the significand */
        movl $0, 4(%rdi)        /* Set the high-order significand bits to 0 */
        movl %eax, %ecx
        andl $0x3F, %eax        /* Trailing exponent bits */
        andl $0x180, %ecx
        shrl %ecx               /* Leading exponent bits */
        orl %eax, %ecx          /* Complete exponent */
        subl $101, %ecx         /* Subtract the exponent bias */
        movl %ecx, 8(%rdi)      /* Store the exponent */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L32_zero:
        movq $0, (%rdi)         /* Set the mantissa to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        movl $0, 16(%rdi)       /* Set the special flag to FPFD_ZERO */
        ret
.L32_sNaN:
        movl %edx, (%rdi)
        movl $0, 4(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        movl $2, 16(%rdi)       /* Set the special flag to FPFD_SNAN */
        ret
.L32_qNaN:
        movl %edx, (%rdi)
        movl $0, 4(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 8(%rdi)        /* Set the exponent to zero */
        movl $3, 16(%rdi)       /* Set the special flag to FPFD_QNAN */
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
        movq (%rsi), %rax       /* Put *src in rax */
        movq %rax, %rdx
        shrl $62, %edx
        andl $0x2, %edx         /* Put sign bit << 1 in edx */
        subl $1, %edx
        negl %edx
        movl %edx, 12(%rdi)     /* Map the sign bit from (1, 0) to (-1, +1) */
        /* Convert the trailing significand digits from DPD to BCD */
        movq fpfd_dpd2bcd@GOTPCREL(%rip), %r8   /* For position-independance */
        movl %eax, %ecx
        movl %eax, %edx
        movl %eax, %r9d
        movq %rax, %r10
        movq %rax, %r11
        andl $0x3FF, %ecx
        shrl $10, %edx
        andl $0x3FF, %edx
        shrl $20, %r9d
        andl $0x3FF, %r9d
        shrq $30, %r10
        andl $0x3FF, %r10d
        shrq $40, %r11
        andl $0x3FF, %r11d
        movw (%r8,%rcx,2), %cx          /* First declet */
        movw (%r8,%rdx,2), %dx          /* Second declet */
        movw (%r8,%r9,2), %r9w          /* Third declet */
        movw (%r8,%r10,2), %r10w        /* Fourth declet */
        movw (%r8,%r11,2), %r11w        /* Fifth declet */
        shll $12, %edx
        orl %ecx, %edx
        shll $24, %r9d
        orl %r9d, %edx
        shlq $36, %r10
        orq %r10, %rdx
        shlq $48, %r11
        orq %r11, %rdx          /* We have all 15 trailing digits now */
        shrq $50, %rax
        andl $0x1FFF, %eax      /* Put combination field in eax */
        movl %eax, %ecx
        andl $0x1800, %ecx
        cmpl $0x1800, %ecx
        je .L64_c1i             /* If the combination field begins with 11,
                                   follow 754-2008, S3.5.2, p11, c.1.i */
        movl %eax, %ecx
        andl $0x700, %ecx
        shlq $52, %rcx
        orq %rcx, %rdx          /* Extract leading digit */
        jz .L64_zero            /* Test for a zero mantissa */
        movq %rdx, (%rdi)       /* Store the BCD mantissa */
        movq $0, 8(%rdi)        /* Set the high-order significand bits to 0 */
        movl %eax, %ecx
        andl $0x1FF, %eax       /* Trailing exponent bits */
        andl $0x1800, %ecx
        shrl $3, %ecx           /* Leading exponent bits */
        orl %eax, %ecx
        subl $398, %ecx         /* Subtract the exponent bias */
        movl %ecx, 16(%rdi)     /* Store the exponent */
        movl $1, 24(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L64_c1i:
        /* The leading bits of the combination field determine special values */
        movl %eax, %ecx
        andl $0x1F80, %ecx
        cmpl $0x1F80, %ecx
        je .L64_sNaN            /* 111111 signifies sNaN */
        cmpl $0x1F00, %ecx
        je .L64_qNaN            /* 111110 signifies qNaN */
        andl $0x1F00, %ecx
        cmpl $0x1E00, %ecx
        je .L64_inf             /* 11110* signifies infinity */
        movl %eax, %ecx
        andl $0x100, %ecx
        orl $0x800, %ecx        /* Get the leading significand digit */
        shlq $52, %rcx
        orq %rcx, %rdx          /* Put the leading digit in place */
        movq %rdx, (%rdi)       /* Store the significand */
        movq $0, 8(%rdi)        /* Set the high-order significand bits to 0 */
        movl %eax, %ecx
        andl $0xFF, %eax        /* Trailing exponent bits */
        andl $0x600, %ecx
        shrl %ecx               /* Leading exponent bits */
        orl %eax, %ecx          /* Complete exponent */
        subl $398, %ecx         /* Subtract the exponent bias */
        movl %ecx, 16(%rdi)     /* Store the exponent */
        movl $1, 24(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
.L64_zero:
        movq $0, (%rdi)
        movq $0, 8(%rdi)        /* Set the mantissa to zero */
        movl $0, 16(%rdi)       /* Set the exponent to zero */
        movl $0, 24(%rdi)       /* Set the special flag to FPFD_ZERO */
        ret
.L64_sNaN:
        movq %rdx, (%rdi)
        movq $0, 8(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 16(%rdi)       /* Set the exponent to zero */
        movl $2, 24(%rdi)       /* Set the special flag to FPFD_SNAN */
        ret
.L64_qNaN:
        movq %rdx, (%rdi)
        movq $0, 8(%rdi)        /* Set the high-order payload bits to zero */
        movl $0, 16(%rdi)       /* Set the exponent to zero */
        movl $3, 24(%rdi)       /* Set the special flag to FPFD_QNAN */
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
        pushq %r12
        movq (%rsi), %rax       /* Put *src in rax */
        movq %rax, %rdx
        shrl $62, %edx
        andl $0x2, %edx         /* Put sign bit << 1 in edx */
        subl $1, %edx
        negl %edx
        movl %edx, 12(%rdi)     /* Map the sign bit from (1, 0) to (-1, +1) */
        /* Convert the trailing significand digits from DPD to BCD */
        movq fpfd_dpd2bcd@GOTPCREL(%rip), %r8   /* For position-independance */
        movl %eax, %ecx
        movl %eax, %edx
        movl %eax, %r9d
        movq %rax, %r10
        movq %rax, %r11
        movq %rax, %r12
        andl $0x3FF, %ecx
        shrl $10, %edx
        andl $0x3FF, %edx
        shrl $20, %r9d
        andl $0x3FF, %r9d
        shrq $30, %r10
        andl $0x3FF, %r10d
        shrq $40, %r11
        andl $0x3FF, %r11d
        shrq $50, %r12
        andl $0x3FF, %r12d
        movw (%r8,%rcx,2), %cx          /* First declet */
        movw (%r8,%rdx,2), %dx          /* Second declet */
        movw (%r8,%r9,2), %r9w          /* Third declet */
        movw (%r8,%r10,2), %r10w        /* Fourth declet */
        movw (%r8,%r11,2), %r11w        /* Fifth declet */
        movw (%r8,%r12,2), %r12w        /* Sixth declet */
        shll $12, %edx
        orl %ecx, %edx
        shll $24, %r9d
        orl %r9d, %edx
        shlq $36, %r10
        orq %r10, %rdx
        shlq $48, %r11
        orq %r11, %rdx
        movl %r12d, %ecx
        shlq $60, %r12
        orq %rdx, %r12          /* r12 stores lower 16 digits */
        movq %rax, %rdx
        shrq $62, %rdx
        movq 8(%rsi), %rax
        shlq $2, %rax
        orq %rdx, %rax          /* rax has next 5 declets */
        movl %eax, %edx
        movl %eax, %r9d
        movq %rax, %r10
        movq %rax, %r11
        andl $0x3FF, %eax
        shrl $10, %edx
        andl $0x3FF, %edx
        shrl $20, %r9d
        andl $0x3FF, %r9d
        shrq $30, %r10
        andl $0x3FF, %r10d
        shrq $40, %r11
        andl $0x3FF, %r11d
        movw (%r8,%rax,2), %ax          /* Seventh declet */
        movw (%r8,%rdx,2), %dx          /* Eighth declet */
        movw (%r8,%r9,2), %r9w          /* Ninth declet */
        movw (%r8,%r10,2), %r10w        /* Tenth declet */
        movw (%r8,%r11,2), %r11w        /* Eleventh declet */
        shrl $4, %ecx
        shll $8, %eax
        orl %eax, %ecx
        shll $20, %edx
        orl %edx, %ecx
        shlq $32, %r9
        orq %r9, %rcx
        shlq $44, %r10
        orq %r9, %rcx
        movl %r11d, %r9d
        shrl $8, %r9d
        shlq $56, %r11
        orq %r11, %rcx
        movq %rcx, %rdx         /* We have all 33 trailing digits now, in
                                   r9:rdx:r12 */
        movq 8(%rsi), %rax
        shrq $46, %rax
        andl $0x1FFFF, %eax     /* Put combination field in eax */
        movl %eax, %ecx
        andl $0x18000, %ecx
        cmpl $0x18000, %ecx
        je .L128_c1i            /* If the combination field begins with 11,
                                   follow 754-2008, S3.5.2, p11, c.1.i */
        movl %eax, %ecx
        andl $0x7000, %ecx
        shll $8, %ecx
        orl %ecx, %r9d          /* Extract leading digit */
        jnz .L128_nonzero       /* Test for a zero mantissa */
        testq %rdx, %rdx
        jnz .L128_nonzero
        testq %r12, %r12
        jz .L128_zero
.L128_nonzero:
        movq %r12, (%rdi)
        movq %rdx, 8(%rdi)
        movq %r9, 16(%rdi)      /* Store the BCD mantissa */
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the high-order significand bits to 0 */
        movl %eax, %ecx
        andl $0x1FFF, %eax      /* Trailing exponent bits */
        andl $0x18000, %ecx
        shrl $3, %ecx           /* Leading exponent bits */
        orl %eax, %ecx
        subl $6176, %ecx        /* Subtract the exponent bias */
        movl %ecx, 36(%rdi)     /* Store the exponent */
        movl $1, 44(%rdi)       /* Set the special flag to FPFD_NUMBER */
        popq %r12
        ret
.L128_c1i:
        /* The leading bits of the combination field determine special values */
        movl %eax, %ecx
        andl $0x1F800, %ecx
        cmpl $0x1F800, %ecx
        je .L128_sNaN           /* 111111 signifies sNaN */
        cmpl $0x1F000, %ecx
        je .L128_qNaN           /* 111110 signifies qNaN */
        andl $0x1F000, %ecx
        cmpl $0x1E000, %ecx
        je .L128_inf            /* 11110* signifies infinity */
        movl %eax, %ecx
        andl $0x1000, %ecx
        orl $0x8000, %ecx       /* Get the leading significand digit */
        shrl $8, %ecx
        orl %ecx, %r9d          /* Put the leading digit in place */
        movq %r12, (%rdi)
        movq %rdx, 8(%rdi)
        movq %r9, 16(%rdi)      /* Store the BCD mantissa */
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the high-order significand bits to 0 */
        movl %eax, %ecx
        andl $0xFFF, %eax       /* Trailing exponent bits */
        andl $0x6000, %ecx
        shrl %ecx               /* Leading exponent bits */
        orl %eax, %ecx          /* Complete exponent */
        subl $6176, %ecx        /* Subtract the exponent bias */
        movl %ecx, 36(%rdi)     /* Store the exponent */
        movl $1, 44(%rdi)       /* Set the special flag to FPFD_NUMBER */
        popq %r12
        ret
.L128_zero:
        movq $0, (%rdi)
        movq $0, 8(%rdi)
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the mantissa to zero */
        movl $0, 36(%rdi)       /* Set the exponent to zero */
        movl $0, 44(%rdi)       /* Set the special flag to FPFD_ZERO */
        popq %r12
        ret
.L128_sNaN:
        movq %r12, (%rdi)
        movq %rdx, 8(%rdi)
        movq %r9, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the high-order payload bits to zero */
        movl $0, 36(%rdi)       /* Set the exponent to zero */
        movl $2, 44(%rdi)       /* Set the special flag to FPFD_SNAN */
        popq %r12
        ret
.L128_qNaN:
        movq %r12, (%rdi)
        movq %rdx, 8(%rdi)
        movq %r9, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the high-order payload bits to zero */
        movl $0, 36(%rdi)       /* Set the exponent to zero */
        movl $3, 44(%rdi)       /* Set the special flag to FPFD_QNAN */
        popq %r12
        ret
.L128_inf:
        movq $0, (%rdi)
        movq $0, 8(%rdi)
        movq $0, 16(%rdi)
        movq $0, 24(%rdi)
        movl $0, 32(%rdi)       /* Set the payload to zero */
        movl $0, 36(%rdi)       /* Set the exponent to zero */
        movl $4, 24(%rdi)       /* Set the special flag to FPFD_INF */
        popq %r12
        ret
        .size fpfd128_impl_expand, .-fpfd128_impl_expand
