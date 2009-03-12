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
        pushq %rbx
        pushq %r12
        pushq %r13
        movl 12(%rsi), %ecx
        xorl 12(%rdx), %ecx     /* XOR the signs: 1 (...0001) XOR -1 (...1111)
                                   gives -2 (...1110), x XOR x gives 0 */
        addl $1, %ecx           /* Add one to go from (-2, 0) to (-1, 1) */
        movl 8(%rsi), %r8d
        addl 8(%rdx), %r8d      /* Add the exponents */
        movl %r8d, 8(%rdi)      /* Store the exponent */
        movl %ecx, 12(%rdi)     /* Store the sign */
        movl (%rsi), %eax
        movl (%rdx), %ebx
        movq fpfd_bcdmul@GOTPCREL(%rip), %r8
        xorl %ecx, %ecx
        xorl %edx, %edx
        xorl %esi, %esi
        xorl %r9d, %r9d
        xorl %r10d, %r10d
        xorl %r11d, %r11d
        /*
         * We use the fpfd_bcdmul table to multiply digits two at a time.  So,
         * if we have
         *
         *     a(bc)(de)(fg)
         *   X h(ij)(kl)(mn)
         *   ---------------,
         *
         * perform the multiplication like this:
         */
        movb %al, %cl
        movb %bl, %ch
        movb %al, %dl
        movb %bh, %dh
        /* Clump the memory reads together to get as many on a bus cycle as we
           can if we miss the cache */
        movw (%r8,%rcx,2), %si          /* si  = fg * mn */
        movw (%r8,%rdx,2), %r9w         /* r9w = fg * kl */
        rorl $16, %ebx
        movb %ah, %cl
        movb %bl, %dh
        movw (%r8,%rcx,2), %r10w        /* r10w = de * mn */
        movw (%r8,%rdx,2), %r11w        /* r11w = fg * ij */
        /* Add r9*100 to rsi */
        shll $8, %r9d
        addl $0x666600, %esi
        movl %esi, %ecx
        addl %r9d, %esi
        xorl %r9d, %ecx
        xorl %esi, %ecx
        notl %ecx
        andl $0x1111000, %ecx
        shrl $3, %ecx
        leal (%rcx,%rcx,2), %ecx
        subl %ecx, %esi
        /* Add r10*100 to rsi */
        shll $8, %r10d
        addl $0x6666600, %esi
        movl %esi, %ecx
        addl %r10d, %esi
        xorl %r10d, %ecx
        xorl %esi, %ecx
        notl %ecx
        andl $0x11111000, %ecx
        shrl $3, %ecx
        leal (%rcx,%rcx,2), %ecx
        subl %ecx, %esi
        /* Add r11*10000 to rsi */
        shll $16, %r11d
        addl $0x6666600, %esi
        movl %esi, %ecx
        addl %r11d, %esi
        xorl %r11d, %ecx
        xorl %esi, %ecx
        notl %ecx
        andl $0x11111000, %ecx
        shrl $3, %ecx
        leal (%rcx,%rcx,2), %ecx
        subl %ecx, %esi
        /* Get the next batch of digits */
        xorl %ecx, %ecx
        xorl %edx, %edx
        xorl %r9d, %r9d
        xorl %r10d, %r10d
        xorl %r11d, %r11d
        /*
         *     a(bc)(de)(fg)
         *   X h(ij)(kl)(mn)
         *   ---------------
         */
        movb %al, %cl
        movb %bh, %ch
        movb %ah, %dl
        movb %bl, %dh
        movw (%r8,%rcx,2), %r9w         /* r9w  = fg * h */
        movw (%r8,%rdx,2), %r10w        /* r10w = de * ij */
        rorl $16, %eax
        rorl $16, %ebx
        movb %bh, %dh
        movb %al, %cl
        movb %bl, %ch
        movw (%r8,%rdx,2), %r11w        /* r11w = de * kl */
        movw (%r8,%rcx,2), %dx          /* dx   = bc * mn */
        movq $0x0666666666666666, %r12
        movq $0x1111111111111110, %r13  /* We have to do 64-bit additions from
                                           now on, so keep these magic numbers
                                           around */
        /* Add r11*10000 to rsi */
        shll $16, %r11d
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r11, %rsi
        xorq %r11, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add rdx*10000 to rsi */
        shll $16, %edx
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %rdx, %rsi
        xorq %rdx, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add r9*1000000 to rsi */
        shlq $24, %r9
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r9, %rsi
        xorq %r9, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add r10*1000000 to rsi */
        shlq $24, %r10
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r10, %rsi
        xorq %r10, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Get the next batch of digits */
        xorl %ecx, %ecx
        xorl %edx, %edx
        xorl %r9d, %r9d
        xorl %r10d, %r10d
        xorl %r11d, %r11d
        /*
         *     a(bc)(de)(fg)
         *   X h(ij)(kl)(mn)
         *   ---------------
         */
        movb %al, %cl
        movb %bh, %ch
        movb %ah, %dl
        movb %bl, %dh
        movw (%r8,%rcx,2), %r9w         /* r9w  = bc * kl */
        movw (%r8,%rdx,2), %r10w        /* r10w = a  * mn */
        rorl $16, %eax
        rorl $16, %ebx
        movb %ah, %dl
        movb %bh, %dh
        movb %bl, %ch
        movw (%r8,%rdx,2), %r11w        /* r11w = de * h  */
        movw (%r8,%rcx,2), %dx          /* dx   = bc * ij */
        /* Add r9*1000000 to rsi */
        shlq $24, %r9
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r9, %rsi
        xorq %r9, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add r10*1000000 to rsi */
        shlq $24, %r10
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r10, %rsi
        xorq %r10, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add r11*100000000 to rsi */
        shlq $32, %r11
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r11, %rsi
        xorq %r11, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add rdx*100000000 to rsi */
        shlq $32, %rdx
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %rdx, %rsi
        xorq %rdx, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Get the next batch of digits */
        xorl %ecx, %ecx
        xorl %edx, %edx
        xorl %r9d, %r9d
        xorl %r10d, %r10d
        xorl %r11d, %r11d
        /*
         *     a(bc)(de)(fg)
         *   X h(ij)(kl)(mn)
         *   ---------------
         */
        rorl $16, %eax
        movb %al, %cl
        movb %bh, %ch
        movb %ah, %dl
        movb %bl, %dh
        movw (%r8,%rcx,2), %r9w         /* r9w  = bc * h  */
        movw (%r8,%rdx,2), %r10w        /* r10w = a  * ij  */
        rorl $16, %ebx
        movb %dl, %cl
        movb %bh, %dh
        movw (%r8,%rcx,2), %r11w        /* r11w = a * h   */
        movw (%r8,%rdx,2), %dx          /* dx   = a * kl  */
        /* Add rdx*100000000 to rsi */
        shlq $32, %rdx
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %rdx, %rsi
        xorq %rdx, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add r9*10000000000 to rsi */
        shlq $40, %r9
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r9, %rsi
        xorq %r9, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add r10*10000000000 to rsi */
        shlq $40, %r10
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r10, %rsi
        xorq %r10, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        /* Add r11*1000000000000 to rsi */
        shlq $48, %r11
        addq %r12, %rsi
        movq %rsi, %rcx
        addq %r11, %rsi
        xorq %r11, %rcx
        xorq %rsi, %rcx
        notq %rcx
        andq %r13, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rsi
        movq %rsi, (%rdi)
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        popq %r13
        popq %r12
        popq %rbx
        ret
        .size fpfd32_impl_mul, .-fpfd32_impl_mul
