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

/* unsigned int fpfd32_impl_div(fpfd32_impl_t *dest,
                                const fpfd32_impl_t *lhs,
                                const fpfd32_impl_t *rhs); */

/*
 * Divide lhs by rhs, and put the result in dest.
 */

        .text
.globl fpfd32_impl_div
        .type fpfd32_impl_div, @function
fpfd32_impl_div:
        pushq %rbx
        pushq %r12
        pushq %r13
        movl 12(%rsi), %ecx
        xorl 12(%rdx), %ecx     /* XOR the signs: 1 (...0001) XOR -1 (...1111)
                                   gives -2 (...1110), x XOR x gives 0 */
        addl $1, %ecx           /* Add one to go from (-2, 0) to (-1, 1) */
        movl 8(%rsi), %r13d
        subl 8(%rdx), %r13d     /* Subtract the exponents */
        addl $2, %r13d
        movl %ecx, 12(%rdi)     /* Store the sign */
        movq fpfd_bcddiv@GOTPCREL(%rip), %r8
        movq fpfd_bcdmul@GOTPCREL(%rip), %r9
        movl (%rsi), %r10d
        movl (%rdx), %r11d
        bsrl %r10d, %ecx
        bsrl %r11d, %edx
        subl $31, %ecx
        subl $27, %edx
        negl %ecx
        negl %edx
        andl $0x3C, %ecx
        andl $0x1C, %edx
        shlq %cl, %r10          /* Shift lhs left to the 8th digit */
        shrl $2, %ecx
        subl %ecx, %r13d        /* Correct the exponent */
        movl %edx, %ecx
        shll %cl, %r11d         /* Shift rhs left to the 7th digit */
        shrl $2, %ecx
        addl %ecx, %r13d        /* Correct the exponent */
        xorl %esi, %esi
.Ldiv:
        /*
         * We divide in a loop, finding two digits at a time.  We first make an
         * estimate of the two digits guaranteed to not be too small.  Then,
         * find the product of rhs and the estimate, and compare it to lhs.  If
         * it is larger than lhs, subtract rhs from the product, and 1 from the
         * estimate, in a loop, until the product is less than or equal to lhs.
         * Then, subtract the product from lhs, shift lhs two digits left, and
         * find the next two digits.
         */
        movq %r10, %rax
        movl %r11d, %ebx
        xorl %ecx, %ecx
        shrq $20, %rax
        shrl $20, %ebx
        cmpl $0x1000, %eax
        jb .Lsmallnumerator
        /* lhs is more than one digit larger than rhs */
        movb %bl, %cl
        shrb $4, %cl
        movb %ah, %ch
        movb (%r8,%rcx), %cl    /* Use 2x2 fpfd_bcddiv to estimate first digit
                                   of estimate */
        cmpb $0x10, %cl
        jb .Lfirstestimate
        movb $0x9, %cl          /* If our estimate was >= 10, use 9.  An
                                   estimate >= would give us an impossible three
                                   digit final estimate. */
        jmp .Lfirstestimate
.Lsmallnumerator:
        /* lhs is at most one digit larger than rhs */
        movw %ax, %cx
        shlw $4, %cx
        movb %bl, %cl
        shrb $4, %cl
        movb (%r8,%rcx), %cl    /* Use 2x1 fpfd_bcddiv find estimate */
        cmpb $0x10, %cl
        jb .Lcheckestimate      /* If our estimate was < 10, it is good */
        movw %ax, %cx
        shlw $4, %cx
        movb %bl, %cl
        movb (%r8,%rcx), %cl    /* Otherwise, use a 2x2 fpfd_bcddiv to find
                                   first digit of estimate */
.Lfirstestimate:
        xorl %edx, %edx
        shlb $4, %cl            /* Shift one-digit estimate left, and find the
                                   correct ones digit in a loop */
.Lfindestimate:
        movb %cl, %dl
        addb $1, %dl            /* Try the estimate + 1 */
        movb %bl, %dh
        movw (%r9,%rdx,2), %dx  /* Use fpfd_bcdmul to find the product of the
                                   estimate + 1 and the higest 2 digits of
                                   rhs */
        cmpw %ax, %dx           /* Compare this product to the highest 3 or 4
                                   digits of lhs */
        ja .Lcheckestimate      /* If it's bigger, then our estimate without the
                                   added 1 was good */
        addb $1, %cl
        movb %cl, %bh
        andb $0x0F, %bh
        cmpb $9, %bh            /* If our ones digit is 9, we must be done */
        je .Lcheckestimate
        cmpw %ax, %dx
        jb .Lfindestimate       /* We're done if ax == dx */
.Lcheckestimate:
        /* Now we find the product of rhs and the estimate, and compare it
           to lhs */
        shlq $8, %rsi
        movb %cl, %sil          /* Store the estimate as the next two quotient
                                   digits */
        xorl %eax, %eax
        xorl %edx, %edx         /* Zero some registers */
        movl %r11d, %ebx
        movb %bl, %ch
        movb %cl, %dl
        movb %bh, %dh
        shrl $16, %ebx
        movw (%r9,%rcx,2), %ax
        movw (%r9,%rdx,2), %dx
        movb %bl, %ch
        movb %cl, %bl
        movw (%r9,%rbx,2), %bx
        movw (%r9,%rcx,2), %cx  /* Multiply rhs by the estimate (product is
                                   ax + 100*dx + 10000*cx + 1000000*bx */
        /* Add edx*100 to eax */
        shll $8, %edx
        addl $0x06666666, %eax
        movl %eax, %r12d
        addl %edx, %eax
        xorl %edx, %r12d
        xorl %eax, %r12d
        notl %r12d
        andl $0x11111110, %r12d
        shrl $3, %r12d
        leal (%r12,%r12,2), %r12d
        subl %r12d, %eax
        /* Add ecx*10000 to eax */
        shll $16, %ecx
        addl $0x06666666, %eax
        movl %eax, %edx
        addl %ecx, %eax
        xorl %ecx, %edx
        xorl %eax, %edx
        notl %edx
        andl $0x11111110, %edx
        shrl $3, %edx
        leal (%rdx,%rdx,2), %edx
        subl %edx, %eax
        /* Add ebx*1000000 to rax */
        shlq $24, %rbx
        movq $0x0666666666666666, %rcx
        addq %rcx, %rax
        movq %rax, %rdx
        addq %rbx, %rax
        xorq %rbx, %rdx
        xorq %rax, %rdx
        notq %rdx
        movq $0x1111111111111110, %rcx
        andq %rcx, %rdx
        shrq $3, %rdx
        leaq (%rdx,%rdx,2), %rdx
        subq %rdx, %rax
        /* See if the product is greater than lhs */
        cmpq %r10, %rax
        jb .Lrem
.Lfixestimate:
        movb %sil, %dl
        subb $1, %sil
        xorb %sil, %dl
        andb $0x10, %dl
        shrb $3, %dl
        leal (%rdx,%rdx,2), %edx
        subb %dl, %sil           /* Subtract 1 from the estimate */
        movq %rax, %rdx
        subq %r11, %rax
        xorq %rax, %rdx
        xorq %r11, %rdx
        andq %rcx, %rdx
        shrq $3, %rdx
        leaq (%rdx,%rdx,2), %rdx
        subq %rdx, %rax         /* Subtract rhs from the product */
        cmpq %rax, %r10
        jb .Lfixestimate        /* If we're still too large, try again */
.Lrem:
        movq %r10, %rdx
        subq %rax, %r10
        xorq %rax, %rdx
        xorq %r10, %rdx
        andq %rcx, %rdx
        shrq $3, %rdx
        leaq (%rdx,%rdx,2), %rdx
        subq %rdx, %r10         /* Subtract the product from lhs */
        shlq $8, %r10           /* Shift lhs two digits left */
        cmpq $0x10000000, %rsi
        jae .Ldone              /* If we have enough precision, we're done */
        subl $2, %r13d          /* Correct the exponent */
        jmp .Ldiv
.Ldone:
        subl $1, %r13d
        movl %esi, %eax
        shrq $4, %rsi
        movq %rsi, (%rdi)       /* Store the mantissa */
        movl %r13d, 8(%rdi)     /* Store the exponent */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        andl $0xF, %eax
        testl %eax, %eax
        jz .Lspecial
        cmpl $5, %eax
        je .Lspecial
        popq %r13
        popq %r12
        popq %rbx
        ret
.Lspecial:
        testl %r10d, %r10d      /* If lhs != 0, we have a remainder */
        jz .Lspecial1
        addl $1, %eax
.Lspecial1:
        popq %r13
        popq %r12
        popq %rbx
        ret
        .size fpfd32_impl_div, .-fpfd32_impl_div
