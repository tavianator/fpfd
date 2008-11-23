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
        xorl 12(%rdx), %esi
        xorl 12(%rcx), %esi     # Calculate
                                # (sign ^ lhs->fields.sign ^ rhs->fields.sign)
        js .Lsub                # If the result is -1, we are subtracting
        movq (%rcx), %rax
        movl 8(%rcx), %ecx
        movl %ecx, %r10d
        subl 8(%rdx), %ecx      # lhs->fields.exp - rhs->fields.exp
        movl %ecx, %r11d
        movq (%rdx), %rdx
        bsrq %rax, %r8
        bsrq %rdx, %r9
        addl $4, %r8d
        addl $4, %r9d
        andl $0x7C, %r8d
        andl $0x7C, %r9d
        subl %r9d, %r8d
        shll $2, %ecx
        addl %r8d, %ecx         # Find the number of bits to shift by
        jns .Laddnoswitch
        negl %ecx
        subl %r11d, %r10d       # r10d = rhs->fields.exp
        xchgq %rax, %rdx
.Laddnoswitch:
        movq %r10, (%rdi)
        movl $0, 8(%rdi)
        movl $1, 12(%rdi)
        movl $1, 16(%rdi)       # Set the special flag to FPFD_NUMBER
        movl $0, %eax
        ret
.Lsub:
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
