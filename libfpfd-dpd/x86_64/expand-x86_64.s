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

# void fpfd32_impl_expand(fpfd32_impl_t *dest, fpfd32_srcptr src);
#
# Converts the densely-packed-decimal representation in src to the binary-
# coded-decimal form in dest.

        .text
.globl fpfd32_impl_expand
        .type fpfd32_impl_expand, @function
fpfd32_impl_expand:
        movl (%rsi), %eax
        movl %eax, %edx
        shrl $30, %edx
        andl $0x2, %edx
        negl %edx
        addl $1, %edx
        movl %edx, 12(%rdi)     # Map the sign bit from (1, 0) to (-1, +1)
        movl %eax, %ecx
        movl %eax, %edx
        andl $0x3FF, %ecx
        movq fpfd_dpd2bcd@GOTPCREL(%rip), %r8   # For position-independance
        movw (%r8,%rcx,2), %cx
        shrl $10, %edx
        andl $0x3FF, %edx
        movw (%r8,%rdx,2), %dx
        shll $12, %edx
        orl %ecx, %edx          # Convert the trailing significand digits from
                                # DPD to BCD
        shrl $20, %eax
        andl $0x7FF, %eax
        movl %eax, %ecx
        andl $0x600, %ecx
        cmpl $0x600, %ecx
        je .L1i                 # If the combination field begins with 11,
                                # follow 754r DRAFT 1.5.0, S3.5, p19, 1.i
        movl %eax, %ecx
        andl $0x1C0, %ecx
        shll $19, %ecx
        orl %ecx, %edx
        jz .Lzero
        movl %edx, (%rdi)       # Get the leading significand digit
        movl $0, 4(%rdi)        # Set the high-order significand bits to zero
        movl %eax, %ecx
        andl $0x3F, %eax
        andl $0x600, %ecx
        shrl $3, %ecx
        orl %eax, %ecx
        subl $101, %ecx
        movl %ecx, 8(%rdi)      # Subtract the bias and store the exponent
        movl $1, 16(%rdi)       # Set the special flag to FPFD_NUMBER
        ret
.L1i:
        movl %eax, %ecx
        andl $0x7E0, %ecx
        cmpl $0x7E0, %ecx
        je .LsNaN
        cmpl $0x7C0, %ecx
        je .LqNaN
        cmpl $0x780, %ecx
        je .Linf
        movl %eax, %ecx
        andl $0x040, %ecx
        orl $0x200, %ecx
        shll $18, %ecx
        orl %ecx, %edx
        movl %edx, (%rdi)       # Get the leading significand digit
        movl $0, 4(%rdi)        # Set the high-order significand bits to zero
        movl %eax, %ecx
        andl $0x3F, %eax
        andl $0x180, %ecx
        shrl %ecx
        orl %eax, %ecx
        subl $101, %ecx
        movl %ecx, 8(%rdi)      # Subtract the bias and store the exponent
        movl $1, 16(%rdi)       # Set the special flag to FPFD_NUMBER
        ret
.Lzero:
        movl $0, (%rdi)
        movl $0, 4(%rdi)
        movl $0, 8(%rdi)
        movl $0, 16(%rdi)       # Set the special flag to FPFD_ZERO
        ret
.LsNaN:
        movl %edx, (%rdi)
        movl $0, 4(%rdi)
        movl $0, 8(%rdi)
        movl $2, 16(%rdi)       # Set the special flag to FPFD_SNAN
        ret
.LqNaN:
        movl %edx, (%rdi)
        movl $0, 4(%rdi)
        movl $0, 8(%rdi)
        movl $3, 16(%rdi)       # Set the special flag to FPFD_QNAN
        ret
.Linf:
        movl %edx, (%rdi)
        movl $0, 4(%rdi)
        movl $0, 8(%rdi)
        movl $4, 16(%rdi)       # Set the special flag to FPFD_INF
        ret
        .size fpfd32_impl_expand, .-fpfd32_impl_expand
