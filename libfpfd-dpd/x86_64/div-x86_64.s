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
        addl $1, %r13d
        movl %ecx, 12(%rdi)     /* Store the sign */
        movq fpfd_bcddiv@GOTPCREL(%rip), %r8
        movq fpfd_bcdmul@GOTPCREL(%rip), %r9
        movl (%rsi), %r10d
        movl (%rdx), %r11d
        bsrl %r10d, %ecx
        bsrl %r11d, %edx
        subl $27, %ecx
        subl $27, %edx
        negl %ecx
        negl %edx
        andl $0x1C, %ecx
        andl $0x1C, %edx
        shll %cl, %r10d         /* Shift lhs left to the 7th digit */
        shrl $2, %ecx
        subl %ecx, %r13d        /* Correct the exponent */
        movl %edx, %ecx
        shll %cl, %r11d         /* Shift rhs left to the 7th digit */
        shrl $2, %ecx
        addl %ecx, %r13d        /* Correct the exponent */
        xorl %esi, %esi
.Ldiv:
        movl %r10d, %eax
        movl %r11d, %ebx
        xorl %ecx, %ecx
        shrl $20, %eax
        shrl $20, %ebx
        cmpl $0x99, %eax
        jb .Ldivgoodnum
        /* Numerator is too large for estimation; guess 9 */
        movb $9, %cl
        jmp .Lcheckestimate
.Ldivgoodnum:
        movb %bl, %cl
        movb %al, %ch
        movb (%r8,%rcx), %cl    /* Use fpfd_bcddiv to find the quotient of the
                                   first two digits of lhs and rhs, an estimate
                                   of the next quotient digit */
        testb %cl, %cl
        jnz .Lcheckestimate
        /* Estimate is zero, so store zero as the next digit, and guess 9 for
           the new estimate */
        shll $4, %esi
        shll $4, %r10d
        subl $1, %r13d
        movb $9, %cl
.Lcheckestimate:
        shll $4, %esi
        addb %cl, %sil
        xorl %eax, %eax
        xorl %edx, %edx
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
        leal (%r12d,%r12d,2), %r12d
        subl %r12d, %eax
        /* Add ecx*100 to eax */
        shll $16, %ecx
        addl $0x06666666, %eax
        movl %eax, %edx
        addl %ecx, %eax
        xorl %ecx, %edx
        xorl %eax, %edx
        notl %edx
        andl $0x11111110, %edx
        shrl $3, %edx
        leal (%edx,%edx,2), %edx
        subl %edx, %eax
        /* Add ebx*1000000 to eax */
        shll $24, %ebx
        addl $0x06666666, %eax
        movl %eax, %edx
        addl %ebx, %eax
        xorl %ebx, %edx
        xorl %eax, %edx
        notl %edx
        andl $0x11111110, %edx
        shrl $3, %edx
        leal (%edx,%edx,2), %edx
        subl %edx, %eax
        /* See if the product is greater than lhs */
        cmpl %eax, %r10d
        jae .Ldivrem
.Ldivfixestimate:
        subl $1, %esi
        movl %eax, %ecx
        subl %r11d, %eax
        xorl %eax, %ecx
        xorl %r11d, %ecx
        andl $0x11111110, %ecx
        shrl $3, %ecx
        leal (%ecx,%ecx,2), %ecx
        subl %ecx, %eax
        cmpl %eax, %r10d
        jb .Ldivfixestimate
.Ldivrem:
        movl %r10d, %ecx
        subl %eax, %r10d
        xorl %eax, %ecx
        xorl %r10d, %ecx
        andl $0x11111110, %ecx
        shrl $3, %ecx
        leal (%ecx,%ecx,2), %ecx
        subl %ecx, %r10d
        shll $4, %r10d
        cmpl $0x10000000, %esi
        jae .Ldone
        subl $1, %r13d          /* Correct the exponent */
        jmp .Ldiv
.Ldone:
        movl %esi, %eax
        shrl $4, %esi
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
        testl %r10d, %r10d
        jz .Lspecial1
        addl $1, %eax
.Lspecial1:
        popq %r13
        popq %r12
        popq %rbx
        ret
        .size fpfd32_impl_div, .-fpfd32_impl_div
