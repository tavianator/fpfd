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

# uint32_t fpfd32_bcd_normalize(fpfd32_bcd_t *dest);
#
# Normalize the value in dest.

.globl fpfd32_bcd_normalize
fpfd32_bcd_normalize:
        movl 4(%esp), %ebx      # Put dest in ebx
        movl (%ebx), %eax
        movl 4(%ebx), %edx      # Put dest->mant in edx:eax
        bsrl %edx, %ecx         # Find the leading non-zero bit
        jz LzeroMSW
        addl $4, %ecx
        andl $0xC, %ecx         # Add one and round up to a multiple of 4
        subl $32, %ecx
        negl %ecx               # Subtract from 32
        shldl %cl, %eax, %edx
        shll %cl, %eax          # Shift edx:eax all the way to the left
        shrl $2, %ecx
        subl $9, %ecx
        negl %ecx
        addl 8(%ebx), %ecx      # Add (32 + 4 - ecx)/4 to the exponent
        cmpl $90, %ecx
        jg Loflow
        cmpl $-107, %ecx
        jl LuflowMSW
        cmpl $-101, %ecx
        jl LsubnormMSW
        movl %ecx, 8(%ebx)      # Set dest->exp to the adjusted exponent
        movl $0, %ecx
        shrdl $4, %eax, %ecx
        shrdl $4, %edx, %eax
        shrl $4, %edx           # Shift edx:eax.ecx to the 28th bit
        movl %edx, (%ebx)
        movl $0, 4(%ebx)        # Set dest->mant to the normalized mantissa
        movl %eax, %ebx
        andl $0x0FFFFFFF, %ebx  # Mask off the most significant nibble
        shrl $28, %eax
        cmpl $0, %eax
        je LspecialMSW
        cmpl $5, %eax
        je LspecialMSW
        ret
LsubnormMSW:
        negl %ecx
        subl $101, %ecx
        shll $2, %ecx
        addl $4, %ecx
        movl $0, %ebx
        shrdl %cl, %eax, %ebx
        shrdl %cl, %edx, %eax
        shrl %cl, %edx          # Shift edx:eax.ebx to the correct bit
        movl %ebx, %ecx
        movl 4(%esp), %ebx      # Put dest in ebx
        movl %edx, (%ebx)
        movl $0, 4(%ebx)        # Set dest->mant to the subnormalized mantissa
        movl $-101, 8(%ebx)     # Set the exponent to the sumnormal exponent
        movl %eax, %ebx
        andl $0x0FFFFFFF, %ebx  # Mask off the most significant nibble
        shrl $28, %eax
        cmpl $0, %eax
        je LspecialMSW
        cmpl $5, %eax
        je LspecialMSW
        ret
LuflowMSW:
        movl $0, (%ebx)
        movl $0, 4(%ebx)
        movl $0, 8(%ebx)
        movl %eax, %ecx
        movl %edx, %ebx
        movl $0, %eax
LspecialMSW:
        cmpl $0, %ebx
        je LspecialMSW2
        addl $1, %eax
        ret
LspecialMSW2:
        cmpl $0, %ecx
        je LspecialMSW3
        addl $1, %eax
LspecialMSW3:
        ret
LzeroMSW:
        bsrl %eax, %ecx
        jz Lzero
        addl $4, %ecx
        andl $0xC, %ecx         # Add one and round up to a multiple of 4
        subl $32, %ecx
        negl %ecx               # Subtract from 32
        shll %cl, %eax          # Shift eax all the way to the left
        shrl $2, %ecx
        subl $1, %ecx
        negl %ecx
        addl 8(%ebx), %ecx      # Add (4 - ecx)/4 to the exponent
        cmpl $90, %ecx
        jg Loflow
        cmpl $-107, %ecx
        jl LuflowLSW
        cmpl $-101, %ecx
        jl LsubnormLSW
        movl %ecx, 8(%ebx)      # Set dest->exp to the adjusted exponent
        shrdl $4, %eax, %edx
        shrl $4, %eax           # Shift eax.edx to the 28th bit
        movl %eax, (%ebx)
        movl $0, 4(%ebx)        # Set dest->mant to the normalized mantissa
        movl %edx, %eax
        shrl $28, %eax
        ret
LsubnormLSW:
        negl %ecx
        subl $101, %ecx
        shll $2, %ecx
        addl $4, %ecx
        shrdl %cl, %eax, %edx
        shrl %cl, %eax          # Shift eax.edx to the correct bit
        movl %eax, (%ebx)
        movl $0, 4(%ebx)        # Set dest->mant to the subnormalized mantissa
        movl $-101, 8(%ebx)     # Set the exponent to the sumnormal exponent
        movl %edx, %eax
        andl $0x0FFFFFFF, %edx
        shrl $28, %eax
        cmpl $0, %eax
        je LspecialLSW
        cmpl $5, %eax
        je LspecialLSW
        ret
LuflowLSW:
        movl $0, (%ebx)
        movl $0, 4(%ebx)
        movl $0, 8(%ebx)
        movl %eax, %edx
        movl $0, %eax
LspecialLSW:
        cmpl $0, %edx
        je LspecialLSW2
        addl $1, %eax
LspecialLSW2:
        ret
Loflow:
        movl $3, 16(%ebx)       # Set the special flag to FPFD_INF
        movl $10, %eax          # Return the special 10 value
        ret
Lzero:
        movl $0, (%ebx)
        movl $0, 4(%ebx)
        movl $0, 8(%ebx)
        movl $0, %eax
        ret
