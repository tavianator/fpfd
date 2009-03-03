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
        xorl %edx, %edx         /* Zero some registers */
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
        movb %r10b, %sil        /* Add r10w*100 to r9 */
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* First digit */
        cmpb $0x9, %cl          /* Test for carry */
        jbe .Lnocarry1          /* Not using cmov, because it's slower */
        addb $0x6, %cl          /* Correct BCD sum */
.Lnocarry1:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %r10b, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Second digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si         /* Test for carry */
        jbe .Lnocarry2
        addw $0x60, %cx         /* Correct BCD sum */
.Lnocarry2:
        shll $8, %ecx
        movb %r9b, %cl          /* Get the low two digits of r9 */
        andw $0xFF00, %r10w
        shll $8, %r10d
        addl %r10d, %ecx        /* Add the two highest digits of r10w*100 to r9.
                                   Carry is impossible; r10d <= 0x980000 */
        movl %ecx, %r9d
        shrl $16, %ecx
        movb %cl, %ch
        movb %r11b, %sil        /* Add r11w*10000 to r9 */
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* First digit */
        cmpb $0x9, %cl
        jbe .Lnocarry3
        addb $0x6, %cl
.Lnocarry3:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %r11b, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Second digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry4
        addw $0x60, %cx
.Lnocarry4:
        shll $16, %ecx
        movw %r9w, %cx          /* Get the low four digits of r9 */
        andw $0xFF00, %r11w
        shll $16, %r11d
        addl %r11d, %ecx        /* Add the two highest digits of r11w*10000 to
                                   r9 */
        movl %ecx, %r9d
        shrl $24, %ecx
        movb %cl, %ch
        movb %dl, %sil          /* Add dx*1000000 to r9 */
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* First digit */
        cmpb $0x9, %cl
        jbe .Lnocarry5
        addb $0x6, %cl
.Lnocarry5:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %dl, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Second digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry6
        addw $0x60, %cx
.Lnocarry6:
        shlq $24, %rcx
        andl $0x00FFFFFF, %r9d
        orq %r9, %rcx           /* Get the low six digits of r9 */
        andw $0xFF00, %dx
        shlq $24, %rdx
        addq %rdx, %rcx         /* Add the two highest digits of dx*1000000 to
                                   r9 */
        movq %rcx, %r9
        shrl $8, %eax           /* We're done the 2x7 multiplication */
        xorl %ecx, %ecx
        xorl %edx, %edx
        movb %al, %cl
        movb %bl, %ch
        movb %al, %dl
        movb %bh, %dh
        movw (%r8,%rcx,2), %r10w        /* r10w = de * ij */
        movw (%r8,%rdx,2), %r11w        /* r11w = de * h  */
        rorl $16, %ebx
        movb %bl, %ch
        movb %bh, %dh
        movw (%r8,%rcx,2), %r12w        /* r12w = de * mn */
        movw (%r8,%rdx,2), %dx          /* dx   = de * kl */
        movw %r9w, %cx
        movb %ch, %cl
        movb %r12b, %sil        /* Add r12w*100 to r9 */
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* First digit */
        cmpb $0x9, %cl
        jbe .Lnocarry7
        addb $0x6, %cl
.Lnocarry7:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %r12b, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Second digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry8
        addw $0x60, %cx
.Lnocarry8:
        shll $8, %ecx
        movb %r9b, %cl
        movw %cx, %r9w          /* Store the low four digits of r9 */
        movl %r9d, %esi
        shrl $16, %esi
        shrl $16, %ecx
        addw %si, %cx
        movb %cl, %ch
        shrw $8, %r12w
        movb %r12b, %sil
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* Third digit */
        cmpb $0x9, %cl
        jbe .Lnocarry9
        addb $0x6, %cl
.Lnocarry9:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %r12b, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Fourth digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry10
        addw $0x60, %cx
.Lnocarry10:
        shll $16, %ecx
        movw %r9w, %cx
        movq $0xFFFFFFFFFF000000, %r12
        andq %r12, %r9
        addq %r9, %rcx          /* Store the low six digits of r9 */
        movq %rcx, %r9
        shrl $16, %ecx
        movb %cl, %ch
        movb %dl, %sil          /* Add dl*10000 to r9 */
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* First digit */
        cmpb $0x9, %cl
        jbe .Lnocarry11
        addb $0x6, %cl
.Lnocarry11:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %dl, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Second digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry12
        addw $0x60, %cx
.Lnocarry12:
        shll $16, %ecx
        movw %r9w, %cx
        movq $0xFFFFFFFFFF000000, %r12
        andq %r12, %r9
        addq %rcx, %r9          /* Get the low six digits of r9 */
        movl %r9d, %esi
        shrl $24, %esi
        shrl $24, %ecx
        addw %si, %cx
        movb %cl, %ch
        movb %dh, %dl
        movb %dl, %sil
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* Third digit */
        cmpb $0x9, %cl
        jbe .Lnocarry13
        addb $0x6, %cl
.Lnocarry13:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %dl, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Fourth digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry14
        addw $0x60, %cx
.Lnocarry14:
        shlq $24, %rcx
        movl %r9d, %r12d
        andl $0x00FFFFFF, %r12d
        orq %r12, %rcx
        movq $0xFFFFFFFF00000000, %rdx
        andq %rdx, %r9
        addq %r9, %rcx
        movq %rcx, %r9
        shrq $24, %rcx
        movb %r10b, %sil
        movb %cl, %ch           /* Add r10w*1000000 to r9 */
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* First digit */
        cmpb $0x9, %cl
        jbe .Lnocarry15
        addb $0x6, %cl
.Lnocarry15:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %r10b, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Second digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry16
        addw $0x60, %cx
.Lnocarry16:
        shlq $24, %rcx
        movl %r9d, %r12d
        andl $0x00FFFFFF, %r12d
        orq %r12, %rcx          /* Get the low six digits of r9 */
        movq $0xFFFFFFFF00000000, %r12
        andq %r12, %r9
        addq %rcx, %r9
        movq %r9, %rsi
        shrq $32, %rsi
        shrq $32, %rcx
        addw %si, %cx
        movb %cl, %ch
        shrw $8, %r10w
        movb %r10b, %sil
        andb $0x0F, %cl
        andb $0x0F, %sil
        addb %sil, %cl          /* Third digit */
        cmpb $0x9, %cl
        jbe .Lnocarry17
        addb $0x6, %cl
.Lnocarry17:
        andb $0xF0, %ch
        addb %ch, %cl
        xorb %ch, %ch
        movb %r10b, %sil
        andw $0x00F0, %si
        addw %si, %cx           /* Fourth digit */
        movw %cx, %si
        andw $0x0FF0, %si
        cmpw $0x90, %si
        jbe .Lnocarry18
        addw $0x60, %cx
.Lnocarry18:
        shlq $32, %rcx
        movl %r9d, %r12d
        orq %r12, %rcx
        movq $0xFFFFFF0000000000, %rdx
        andq %rdx, %r9
        addq %r9, %rcx
        movq %rcx, %r9
        shrq $40, %rcx
        movb %r11b, %sil
        movb %cl, %ch           /* Add r11w*100000000 to r9 */
        movq %r9, (%rdi)        /* Store the mantissa */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        popq %r12
        popq %rbx
        ret
        .size fpfd32_impl_mul, .-fpfd32_impl_mul
