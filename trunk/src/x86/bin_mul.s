#########################################################################
# Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               #
#                                                                       #
# This file is part of The FPFD Library                                 #
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

# void fpfd32_bin_mul(fpfd32_bin_t *dest,
#                     const fpfd32_bin_t *lhs, const fpfd32_bin_t *rhs);
#
# Multiply lhs and rhs, and put the result in dest.

.globl fpfd32_bin_mul
fpfd32_bin_mul:
        movl 8(%esp), %ebx
        movl 12(%esp), %ecx
        movl (%ebx), %eax
        movl (%ecx), %edx
        mull %edx               # Multiply the mantissas
        movl 8(%ebx), %ebx
        addl 8(%ecx), %ebx      # Add the exponents
        movl 4(%esp), %ecx
        movl %eax, (%ecx)
        movl %edx, 4(%ecx)
        movl %ebx, 8(%ecx)      # Store the new mantissa and exponents
        movl 8(%esp), %eax
        movl 12(%esp), %ebx
        movl 12(%eax), %edx
        xorl 12(%ebx), %edx     # XOR the signs: 1 (...0001) xor -1 (...1111)
                                # gives -2 (...1110), X xor X gives 0
        addl $1, %edx           # Add one to go from (-2, 0) to (-1, 1)
        movl %edx, 16(%ecx)     # Store the sign
        ret
