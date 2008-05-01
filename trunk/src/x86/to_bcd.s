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

# void fpfd32_to_bcd(fpfd32_bcd_t *dest, fpfd32_srcptr src);
#
# Converts the densely-packed-decimal representation in src to the binary-
# coded-decimal form in dest.

.globl fpfd32_to_bcd
fpfd32_to_bcd:
        movl 4(%esp), %eax
        movl 8(%esp), %ebx
        movl (%ebx), %ecx
        movl %ecx, %edx
        shrl $30, %edx
        andl $0x2, %edx
        negl %edx
        incl %edx
        movl %edx, 12(%eax)     # Map the sign bit from (1, 0) to (-1, +1)
        movl %ecx, %edx
        andl $0x3FF, %edx
        movl fpfd_dpd2bcd(,%edx,4), %edx
        movl %ecx, %ebx
        shrl $10, %ebx
        andl $0x3FF, %ebx
        movl fpfd_dpd2bcd(,%ebx,4), %ebx
        shll $12, %ebx
        orl %edx, %ebx          # Convert the trailing significand digits from
                                # DPD to BCD
        movl %ecx, %edx
        shrl $20, %edx
        andl $0x600, %edx
        xorl $0x600, %edx
        jz L1i                  # If the combination field begins with 11,
                                # follow 754r DRAFT 1.5.0, S3.5, p19, 1.i
        shrl $20, %ecx
        andl $0x7FF, %ecx
        movl %ecx, %edx         # Get the combination field
        andl $0x1C0, %edx
        shll $19, %edx
        orl %edx, %ebx
        movl %ebx, (%eax)       # Get the leading significand digit
        movl %ecx, %edx
        andl $0x3F, %ecx
        andl $0x600, %edx
        shrl $3, %edx
        orl %ecx, %edx
        subl $101, %edx
        movl %edx, 8(%eax)      # Subtract the bias and store the exponent
        jmp Ldone
L1i:
        shrl $20, %ecx
        andl $0x7FF, %ecx
        movl %ecx, %edx         # Get the combination field
        andl $0x040, %edx
        orl $0x200, %edx
        shll $19, %edx
        orl %edx, %ebx
        movl %ebx, (%eax)       # Get the leading significand digit
        movl %ecx, %edx
        andl $0x3F, %ecx
        andl $0x180, %edx
        shrl %edx
        orl %ecx, %edx
        subl $101, %edx
        movl %edx, 8(%eax)      # Subtract the bias and store the exponent
Ldone:
        movl $0, 4(%eax)        # Set the high-order significand bits to zero
        ret
