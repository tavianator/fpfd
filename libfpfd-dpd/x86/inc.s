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

# void fpfd32_impl_inc(fpfd32_impl_t *dest);
#
# Increment the mantissa, in case we need to round. dest must be normalized.
# To increment the mantissa, we add one to the BCD value, then check for
# overflow in a loop. If (M & 0xA) == 0xA, then the least significant digit
# is 0xA (or 0xB, 0xE, or 0xF, which can never happen). In that case, we add
# 0x6 to M, and check for a carry in the second digit by (M & 0xA0) == 0xA0,
# if so add 0x60, etc.

        .text
.globl fpfd32_impl_inc
        .type fpfd32_impl_inc, @function
fpfd32_impl_inc:
        movl 4(%esp), %ecx
        movl (%ecx), %eax
        addl $1, %eax           # Increment the mantissa
        movl %eax, %edx
        andl $0xA, %edx
        cmpl $0xA, %edx         # Test for overflow (LSD == 10)
        je .Lcarryinit
        movl %eax, (%ecx)
        ret
.Lcarryinit:
        pushl %ebx
        pushl %esi              # Callee-save registers
        movl $6, %ebx           # For decimal carries
.Lcarry:
        addl %ebx, %eax
        movl %eax, %esi
        shll $4, %edx
        shll $4, %ebx
        cmpl $0x60000000, %ebx
        je .Lrollover           # If we carry past 28 bits, we've rolled over
        andl %edx, %esi
        cmpl %edx, %esi
        je .Lcarry
        movl %eax, (%ecx)
        popl %esi
        popl %ebx
        ret
.Lrollover:
        movl 8(%ecx), %eax
        addl $1, %eax           # Increment the exponent
        cmpl $90, %eax
        ja .Loflow              # Test for overflow
        movl %eax, 8(%ecx)
        movl $0x01000000, (%ecx)
        popl %esi
        popl %ebx
        ret
.Loflow:
        movl $3, 16(%ecx)       # Set the special flag to FPFD_INF
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_inc, .-fpfd32_impl_inc
