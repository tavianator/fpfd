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
        pushl %ebx
        pushl %esi
        movl 12(%esp), %esi     # Put dest in esi
        movl (%esi), %eax
        movl 4(%esi), %edx      # Put dest->mant in edx:eax
        bsrl %edx, %ecx         # Find the leading non-zero bit
        jz .LzeroMSW
        addl $4, %ecx
        andl $0x3C, %ecx        # Add one and round up to a multiple of 4
        subl $32, %ecx
        negl %ecx               # Subtract from 32
        shldl %cl, %eax, %edx
        shll %cl, %eax          # Shift edx:eax all the way to the left
        shrl $2, %ecx
        subl $9, %ecx
        negl %ecx
        addl 8(%esi), %ecx      # Add (32 + 4 - ecx)/4 to the exponent
        cmpl $90, %ecx
        jg .Loflow
        cmpl $-107, %ecx
        jl .LuflowMSW
        cmpl $-101, %ecx
        jl .LsubnormMSW
        movl %ecx, 8(%esi)      # Set dest->exp to the adjusted exponent
        movl $0, %ecx
        shrdl $4, %eax, %ecx
        shrdl $4, %edx, %eax
        shrl $4, %edx           # Shift edx:eax.ecx to the 28th bit
        movl %edx, (%esi)
        movl $0, 4(%esi)        # Set dest->mant to the scaled mantissa
        movl %eax, %ebx
        andl $0x0FFFFFFF, %ebx  # Mask off the most significant nibble
        shrl $28, %eax
        cmpl $0, %eax
        je .LspecialMSW
        cmpl $5, %eax
        je .LspecialMSW
        popl %esi
        popl %ebx
        ret
.LsubnormMSW:
        negl %ecx
        subl $100, %ecx
        shll $2, %ecx
        movl $0, %ebx
        shrdl %cl, %eax, %ebx
        shrdl %cl, %edx, %eax
        shrl %cl, %edx          # Shift edx:eax.ebx to the correct bit
        movl %ebx, %ecx
        movl %edx, (%esi)
        movl $0, 4(%esi)        # Set dest->mant to the subnormal mantissa
        movl $-101, 8(%esi)     # Set the exponent to the subnormal exponent
        movl %eax, %ebx
        andl $0x0FFFFFFF, %ebx  # Mask off the most significant nibble
        shrl $28, %eax
        cmpl $0, %eax
        je .LspecialMSW
        cmpl $5, %eax
        je .LspecialMSW
        popl %esi
        popl %ebx
        ret
.LuflowMSW:
        movl $0, (%esi)
        movl $0, 4(%esi)
        movl $-101, 8(%esi)     # Set the exponent to the subnormal exponent
        movl %edx, %ebx
        movl %eax, %ecx
        movl $0, %eax
.LspecialMSW:
        cmpl $0, %ebx
        je .LspecialMSW2
        addl $1, %eax
        popl %esi
        popl %ebx
        ret
.LspecialMSW2:
        cmpl $0, %ecx
        je .LspecialMSW3
        addl $1, %eax
.LspecialMSW3:
        popl %esi
        popl %ebx
        ret
.LzeroMSW:
        bsrl %eax, %ecx
        jz .Lzero
        addl $4, %ecx
        andl $0x3C, %ecx        # Add one and round up to a multiple of 4
        subl $32, %ecx
        negl %ecx               # Subtract from 32
        shll %cl, %eax          # Shift eax all the way to the left
        shrl $2, %ecx
        subl $1, %ecx
        negl %ecx
        addl 8(%esi), %ecx      # Add (4 - ecx)/4 to the exponent
        cmpl $90, %ecx
        jg .Loflow
        cmpl $-107, %ecx
        jl .LuflowLSW
        cmpl $-101, %ecx
        jl .LsubnormLSW
        movl %ecx, 8(%esi)      # Set dest->exp to the adjusted exponent
        shrdl $4, %eax, %edx
        shrl $4, %eax           # Shift eax.edx to the 28th bit
        movl %eax, (%esi)
        movl $0, 4(%esi)        # Set dest->mant to the scaled mantissa
        movl %edx, %eax
        shrl $28, %eax
        popl %esi
        popl %ebx
        ret
.LsubnormLSW:
        negl %ecx
        subl $101, %ecx
        shll $2, %ecx
        addl $4, %ecx
        shrdl %cl, %eax, %edx
        shrl %cl, %eax          # Shift eax.edx to the correct bit
        movl %eax, (%esi)
        movl $0, 4(%esi)        # Set dest->mant to the subscaled mantissa
        movl $-101, 8(%esi)     # Set the exponent to the sumnormal exponent
        movl %edx, %eax
        andl $0x0FFFFFFF, %edx
        shrl $28, %eax
        cmpl $0, %eax
        je .LspecialLSW
        cmpl $5, %eax
        je .LspecialLSW
        popl %esi
        popl %ebx
        ret
.LuflowLSW:
        movl $0, (%esi)
        movl $0, 4(%esi)
        movl $-101, 8(%esi)     # Set the exponent to the subnormal exponent
        movl %eax, %edx
        movl $0, %eax
.LspecialLSW:
        cmpl $0, %edx
        je .LspecialLSW2
        addl $1, %eax
.LspecialLSW2:
        popl %esi
        popl %ebx
        ret
.Loflow:
        movl $3, 16(%esi)       # Set the special flag to FPFD_INF
        movl $10, %eax          # Return the special 10 value
        popl %esi
        popl %ebx
        ret
.Lzero:
        movl $-101, 8(%esi)     # Set dest->exp to the subnormal exponent
        movl $0, %eax
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_scale, .-fpfd32_impl_scale
