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
        xorl %r9d, %r9d
        xorl %r10d, %r10d
        xorl %r11d, %r11d       /* Zero some registers */
        /* We use the fpfd_bcdmul table to multiply digits two at a time.  So,
           if we have abcdefg * hijklmn, perform the multiplication like
           this: */
        movb %al, %cl
        movb %bl, %ch
        movb %al, %dl
        movb %bh, %dh
        /* Clump the memory reads together to get as many on a bus tick as we
           can if we miss the cache */
        movw (%r8,%rcx,2), %r9w         /* r9w  = fg * mn */
        movw (%r8,%rdx,2), %r10w        /* r10w = fg * kl */
        rorl $16, %ebx
        movb %bl, %ch
        movb %bh, %dh
        movw (%r8,%rcx,2), %r11w        /* r11w = fg * ij */
        movw (%r8,%rdx,2), %dx          /* dx   = fg * h  */
        movw %r9w, %cx
        movb %ch, %cl
        movb %r10b, %sil
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl
        cmpb $0x9, %cl
        jbe .Lnocarry1
        addb $0x6, %cl
.Lnocarry1:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %r10b, %sil
        andw $0x00F0, %si
        addw %si, %cx
        movw %cx, %si
        andw $0x0F00, %si
        cmpw $0x90, %si
        jbe .Lnocarry2
        addw $0x60, %cx
.Lnocarry2:
        shll $8, %ecx
        movb %r9b, %cl
        movl %ecx, %r9d
        shrl $16, %ecx
        movq %r9, (%rdi)        /* Store the mantissa */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        popq %rbx
        ret
        .size fpfd32_impl_mul, .-fpfd32_impl_mul
