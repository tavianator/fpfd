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

# int fpfd32_impl_scale(fpfd32_impl_t *dest);
#
# Scale the value in dest, to fit in the compressed format

        .text
.globl fpfd32_impl_scale
        .type fpfd32_impl_scale, @function
fpfd32_impl_scale:
        movq (%rdi), %rdx       # Put dest->mant in rdx
        bsrq %rdx, %rcx         # Find the leading non-zero bit
        jz .Lzero
        addl $4, %ecx
        andl $0x7C, %ecx        # Add one and round up to a multiple of 4
        subl $64, %ecx
        negl %ecx               # Subtract from 64
        shlq %cl, %rdx          # Shift rdx all the way to the left
        shrl $2, %ecx
        subl $9, %ecx
        negl %ecx
        addl 8(%rdi), %ecx      # Add (32 + 4 - ecx)/4 to the exponent
        cmpl $90, %ecx
        jg .Loflow
        cmpl $-107, %ecx
        jl .Luflow
        cmpl $-101, %ecx
        jl .Lsubnorm
        movl %ecx, 8(%rdi)      # Set dest->exp to the adjusted exponent
        movl $0, %ecx
        shrdq $36, %rdx, %rax
        shrq $36, %rax          # Shift rdx.rax to the 28th bit
        movq %rdx, (%rdi)       # Set dest->mant to the scaled mantissa
        movq %rax, %rcx
        movq $0x0FFFFFFFFFFFFFFF, %rdx
        andq %rdx, %rcx         # Mask off the most significant nibble
        shrq $62, %rax
        cmpl $0, %eax
        je .Lspecial
        cmpl $5, %eax
        je .Lspecial
        ret
.Lsubnorm:
        negl %ecx
        subl $91, %ecx
        shll $2, %ecx
        movl $0, %ebx
        shrdq %cl, %rdx, %rax
        shrq %cl, %rax          # Shift rdx.rax to the correct bit
        movq %rdx, (%rdi)       # Set dest->mant to the subnormal mantissa
        movl $-101, 8(%rdi)     # Set the exponent to the subnormal exponent
        movq %rax, %rcx
        movq $0x0FFFFFFFFFFFFFFF, %rdx
        andq %rdx, %rcx  # Mask off the most significant nibble
        shrq $62, %rax
        cmpl $0, %eax
        je .Lspecial
        cmpl $5, %eax
        je .Lspecial
        ret
.Luflow:
        movq $0, (%rdi)
        movl $0, 8(%rdi)
        movq %rdx, %rcx
        movl $0, %eax
.Lspecial:
        cmpq $0, %rcx
        je .Lspecial2
        addl $1, %eax
        ret
.Lspecial2:
        ret
.Loflow:
        movl $3, 16(%esi)       # Set the special flag to FPFD_INF
        movl $10, %eax          # Return the special 10 value
        ret
.Lzero:
        movl $0, 8(%esi)        # Set dest->exp to zero
        movl $0, 16(%esi)       # Set the special flag to FPFD_ZERO
        movl $0, %eax
        ret
        .size fpfd32_impl_scale, .-fpfd32_impl_scale
