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
        xorl 12(%r10), %esi
        xorl 12(%r11), %esi
        js .Lsub
        bsrq (%r10), %r8        # Addition
        bsrq (%r11), %r9
        subl $63, %r8d
        subl $63, %r9d
        negl %r8d
        negl %r9d
        shrl $2, %r8d
        shrl $2, %r9d
        movl %r9d, %edx
        subl %r8d, %edx
        addl 8(%r10), %edx
        subl 8(%r11), %edx
        jns .Laddnoswitch
        xchgq %r10, %r11
        xchgl %r8d, %r9d
        negl %edx
.Laddnoswitch:
        movq (%r10), %rax
        leal (,%r8d,4), %ecx
        shlq %cl, %rax
        subl %edx, %r9d
        js .Laddnoadd
        leal (,%r9d,4), %ecx
        movq (%r11), %rdx
        shlq %cl, %rdx
        addq %rdx, %rax
.Laddnoadd:
        movq %rax, (%rdi)       # Save the mantissa
        movl 8(%r10), %eax
        subl %r8d, %eax
        movl %eax, 8(%rdi)      # Adjust and save the exponent
        movl 12(%r10), %eax
        movl %eax, 12(%rdi)     # Save the sign
        movl $1, 16(%rdi)       # Set the special flag to FPFD_NUMBER
        movl $0, %eax
        ret
.Lsub:
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
