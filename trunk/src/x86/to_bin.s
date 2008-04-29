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

# void fpfd32_to_bin(fpfd32_bin_t *dest, fpfd32_srcptr src);
#
# Converts the compact binary representation in src to the expanded form
# dest.

.globl fpfd32_to_bin
fpfd32_to_bin:
        movl 4(%esp), %eax
        movl 8(%esp), %ebx
        movl (%ebx), %ecx
        movl %ecx, %edx
        shrl $30, %edx
        andl $0x2, %edx
        negl %edx
        incl %edx
        movl %edx, 12(%eax)
        movl %ecx, %edx
        shrl $20, %edx
        andl $0x7FF, %edx
        testl $0x600, %edx
        je L2ii
        shrl $3, %edx
        subl $101, %edx
        movl %edx, 8(%eax)
        andl $0x007FFFFF, %ecx
        movl %ecx, 4(%eax)
        jmp Ldone
L2ii:
        shrl %edx
        andl $0xFF, %edx
        subl $101, %edx
        movl %edx, 8(%eax)
        andl $0x001FFFFF, %ecx
        orl $0x00400000, %ecx
        movl %ecx, 4(%eax)
Ldone:
        movl 0(%eax)
        ret
