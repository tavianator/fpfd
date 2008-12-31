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
        pushq 8(%rcx)
        pushq (%rcx)
        pushq 8(%rdx)
        pushq (%rdx)
        xorl 12(%rsp), %esi
        xorl 28(%rsp), %esi
        js .Lsub
        bsrq (%rsp), %r8        # Addition
        bsrq 16(%rsp), %r9
        subl $63, %r8d
        subl $63, %r9d
        negl %r8d
        negl %r9d
        shrl $2, %r8d
        shrl $2, %r9d
        movl %r9d, %edx
        subl %r8d, %edx
        addl 8(%rsp), %edx
        subl 24(%rsp), %edx
        jns .Laddnoswitch
        movq 16(%rsp), %rax
        xchgq (%rsp), %rax
        movq %rax, 16(%rsp)
        movl 24(%rsp), %eax
        xchgl 8(%rsp), %eax
        movl %eax, 24(%rsp)
        xchgl %r8d, %r9d
        negl %edx
.Laddnoswitch:
        movq (%rsp), %rax
        leal (,%r8d,4), %ecx
        shlq %cl, %rax
        subl %edx, %r9d
        js .Laddnoadd
        leal (,%r9d,4), %ecx
        movq 16(%rsp), %rdx
        shlq %cl, %rdx
        addq %rdx, %rax
.Laddnoadd:
        movq %rax, (%rdi)       # Save the mantissa
        movl 8(%rsp), %eax
        subl %r8d, %eax
        movl %eax, 8(%rdi)      # Adjust and save the exponent
        movl 12(%rsp), %eax
        movl %eax, 12(%rdi)     # Save the sign
        movl $1, 16(%rdi)       # Set the special flag to FPFD_NUMBER
        movl $0, %eax
        addq $32, %rsp
        ret
.Lsub:
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
