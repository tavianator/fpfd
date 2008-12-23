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
        subl $60, %r8d
        subl $60, %r9d
        shrl $2, %r8d
        shrl $2, %r9d
        negl %r8d
        negl %r9d
        movl %r9d, %ecx
        subl %r8d, %ecx
        addl 8(%rsp), %ecx
        subl 24(%rsp), %ecx
        jns .Laddnoswitch
        movq 16(%rsp), %rax
        xchgq (%rsp), %rax
        movq %rax, 16(%rsp)
        movq 24(%rsp), %rax
        xchgq 8(%rsp), %rax
        movq %rax, 24(%rsp)
        xchgl %r8d, %r9d
        negl %ecx
.Laddnoswitch:
        movq (%rsp), %rax
        leal (,%r8d,4), %ecx
        shlq %cl, %rax
        movq %rax, (%rdi)
        movq 8(%rsp), %rax
        addl %r8d, %eax
        movq %rax, 8(%rdi)
        movl $1, 16(%rdi)       # Set the special flag to FPFD_NUMBER
        addq $32, %rsp
        ret
.Lsub:
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
