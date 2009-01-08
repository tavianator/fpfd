#########################################################################
# Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               #
#                                                                       #
# This file is part of The FPFD Library.                                #
#                                                                       #
# The FPFD Library is free software; you can redistribute it and/or     #
# modify it under the terms of the GNU Lesser General Public License as #
# published by the Free Software Foundation; either version 3 of the    #
# License, or (at your option) any later version.                       #
#                                                                       #
# The FPFD Library is distributed in the hope that it will be useful,   #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     #
# Lesser General Public License for more details.                       #
#                                                                       #
# You should have received a copy of the GNU Lesser General Public      #
# License along with this program.  If not, see                         #
# <http://www.gnu.org/licenses/>.                                       #
#########################################################################

# unsigned int fpfd32_impl_addsub(fpfd32_impl_t *dest, int sign,
#                                 const fpfd32_impl_t *lhs,
#                                 const fpfd32_impl_t *rhs);
#
# Add lhs and rhs if sign == 1, or subtract lhs and rhs if sign == -1, and store
# the result in dest.

        .text
.globl fpfd32_impl_addsub
        .type fpfd32_impl_addsub, @function
fpfd32_impl_addsub:
        movq %rdx, %r10
        movq %rcx, %r11
        xorl 12(%r11), %esi
        xorl $1, %esi           # Find the effective sign of rhs
        bsrq (%r10), %r8
        bsrq (%r11), %r9
        subl $63, %r8d
        subl $63, %r9d
        negl %r8d
        negl %r9d
        shrl $2, %r8d
        shrl $2, %r9d
        movl %r9d, %edx
        subl %r8d, %edx
        movl 12(%r10), %eax
        movl %eax, -4(%rsp)
        addl 8(%r10), %edx
        subl 8(%r11), %edx
        jns .Lnoswitch
        movl %esi, -4(%rsp)
        xchgq %r10, %r11
        xchgl %r8d, %r9d
        negl %edx
.Lnoswitch:
        xorl %eax, %esi
        movl 8(%r10), %eax
        movl %eax, -8(%rsp)     # Store the result exponent
        movq (%r10), %rax
        leal (,%r8d,4), %ecx
        shlq %cl, %rax
        shrq $32, %rcx
        cmpl $0, %esi
        js .Lsubshift           # Determine if adding or subtracting digits
        subl %edx, %r9d
        movq (%r11), %rdx
        js .Laddshr
        leal (,%r9d,4), %ecx
        shlq %cl, %rdx
        movq $0, %r9
        jmp .Ladd
.Laddshr:
        negl %r9d
        leal (,%r9d,4), %ecx
        cmpl $16, %r9d
        movq $0, %r9
        je .Lrem
        ja .Laddshrtoofar
        shrdq %cl, %rdx, %r9
        shrq %cl, %rdx
        jmp .Ladd
.Laddshrtoofar:
        xchgq %rax, %rdx
        shrdq $4, %rax, %r9
        shrq $4, %rax
        jmp .Lrem
.Ladd:
        movq %rax, %rsi
        movq %rdx, %r11
        movq %rdx, %rcx
        movq $0, %rdx
        andb $0x0F, %al
        andb $0x0F, %cl
.Laddloop:
        adcb %al, %cl
        cmpb $0x9, %cl
        ja .Laddcarry
        addb %cl, %dl
        rorq $4, %rdx
        shrq $4, %rsi
        shrq $4, %r11
        test %rsi, %rsi
        jz .Ladddone
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl
        jmp .Laddloop
.Laddcarry:
        addb $0x06, %cl
        andb $0x0F, %cl
        addb %cl, %dl
        rorq $4, %rdx
        shrq $4, %rsi
        shrq $4, %r11
        test %rsi, %rsi
        jz .Ladddonecarry
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl
        stc
        jmp .Laddloop
.Ladddonecarry:
        shrdq $4, %rdx, %r9
        shrq $4, %rdx
        movq %r9, %rax
        movq $0x1000000000000000, %rcx
        orq %rcx, %rdx
        subl $1, %r8d
        jmp .Lrem
.Ladddone:
        movq %r9, %rax
        movq $0, %r9
        jmp .Lrem
.Lsubshift:
        subl %edx, %r9d
        movq (%r11), %rdx
        js .Lsubshr
        leal (,%r9d,4), %ecx
        shlq %cl, %rdx
        movq $0, %r9
        jmp .Lsub
.Lsubshr:
        negl %r9d
        leal (,%r9d,4), %ecx
        cmpl $16, %r9d
        movq $0, %r9
        je .Lrem
        ja .Lsubshrtoofar
        shrdq %cl, %rdx, %r9
        shrq %cl, %rdx
        jmp .Lsub
.Lsubshrtoofar:
        xchgq %rax, %rdx
        shrdq $4, %rax, %r9
        shrq $4, %rax
        jmp .Lrem
.Lsub:
        movq %rax, %rsi
        movq %rdx, %r11
        movq %rdx, %rcx
        movq $0, %rdx
        andb $0x0F, %al
        andb $0x0F, %cl
.Lsubloop:
        sbbb %cl, %al
        jc .Lsubborrow
        addb %al, %dl
        rorq $4, %rdx
        shrq $4, %rsi
        shrq $4, %r11
        test %rsi, %rsi
        jz .Lsubdone
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl
        jmp .Lsubloop
.Lsubborrow:
        addb $0x0A, %al
        addb %al, %dl
        rorq $4, %rdx
        shrq $4, %rsi
        shrq $4, %r11
        test %rsi, %rsi
        jz .Lsubdoneborrow
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl
        stc
        jmp .Lsubloop
.Lsubdoneborrow:
        bsfq %rdx, %rcx
        addl $1, %ecx
        andl $0x3C, %ecx
        movq $0x999999999999999A, %rax
        shlq %cl, %rax
        subq %rdx, %rax
        movq %rax, %rdx
        movq %r9, %rax
        movq $0, %r9
        negl -4(%rsp)
        jmp .Lrem
.Lsubdone:
        movq %r9, %rax
        movq $0, %r9
.Lrem:
        movq %rdx, (%rdi)       # Save the mantissa
        movl -8(%rsp), %edx
        subl %r8d, %edx
        movl %edx, 8(%rdi)      # Adjust and save the exponent
        movl -4(%rsp), %edx
        movl %edx, 12(%rdi)     # Save the sign
        movl $1, 16(%rdi)       # Set the special flag to FPFD_NUMBER
        shrdq $60, %rax, %r9
        shrq $60, %rax
        cmpl $0, %eax
        je .Lspecial
        cmpl $5, %eax
        je .Lspecial
        ret
.Lspecial:
        cmpq $0, %r9
        je .Lspecial1
        addl $1, %eax
.Lspecial1:
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
