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

        .text
.globl fpfd32_to_bcd
        .type fpfd32_to_bcd, @function
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
        movw fpfd_dpd2bcd(,%edx,2), %dx
        movl %ecx, %ebx
        shrl $10, %ebx
        andl $0x3FF, %ebx
        movw fpfd_dpd2bcd(,%ebx,2), %bx
        shll $12, %ebx
        orl %edx, %ebx          # Convert the trailing significand digits from
                                # DPD to BCD
        shrl $20, %ecx
        andl $0x7FF, %ecx
        movl %ecx, %edx
        andl $0x600, %edx
        cmpl $0x600, %edx
        je .L1i                 # If the combination field begins with 11,
                                # follow 754r DRAFT 1.5.0, S3.5, p19, 1.i
        movl %ecx, %edx
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
        movl $0, 4(%eax)        # Set the high-order significand bits to zero
        movl $0, 16(%eax)       # Set the special flag to FPFD_NUMBER
        ret
.L1i:
        movl %ecx, %edx
        andl $0x7E0, %edx
        cmpl $0x7E0, %edx
        je .LsNaN
        cmpl $0x7C0, %edx
        je .LqNaN
        andl $0x7C0, %edx
        cmpl $0x780, %edx
        je .Linf
        movl %ecx, %edx
        andl $0x040, %edx
        orl $0x200, %edx
        shll $18, %edx
        orl %edx, %ebx
        movl %ebx, (%eax)       # Get the leading significand digit
        movl %ecx, %edx
        andl $0x3F, %ecx
        andl $0x180, %edx
        shrl %edx
        orl %ecx, %edx
        subl $101, %edx
        movl %edx, 8(%eax)      # Subtract the bias and store the exponent
        movl $0, 4(%eax)        # Set the high-order significand bits to zero
        movl $0, 16(%eax)       # Set the special flag to FPFD_NUMBER
        ret
.LsNaN:
        movl %ebx, (%eax)
        movl $0, 4(%eax)
        movl $0, 8(%eax)
        movl $1, 16(%eax)
        ret
.LqNaN:
        movl %ebx, (%eax)
        movl $0, 4(%eax)
        movl $0, 8(%eax)
        movl $2, 16(%eax)
        ret
.Linf:
        movl %ebx, (%eax)
        movl $0, 4(%eax)
        movl $0, 8(%eax)
        movl $3, 16(%eax)
        ret
        .size fpfd32_to_bcd, .-fpfd32_to_bcd
