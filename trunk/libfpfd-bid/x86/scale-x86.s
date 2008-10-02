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
# Scale dest, so it can be compressed.

        .text
.globl fpfd32_impl_scale
        .type fpfd32_impl_scale, @function
fpfd32_impl_scale:
        pushl %ebx
        pushl %esi
        pushl %edi
        pushl %ebp
        movl 20(%esp), %esi     # Put dest in esi
        movl (%esi), %eax
        movl 4(%esi), %edx      # Put dest->mant in edx:eax
        bsrl %edx, %ebx         # Find the leading non-zero bit
        jz .LzeroMSW
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.LzeroMSW:
        bsrl %eax, %ebx
        jz .Lzero
        cmpl $1000000, %eax
        jb .LunderLSW           # The mantissa is too small
        cmpl $10000000, %eax
        jae .LoverLSW           # The mantissa is too big
        movl %eax, %edx
        movl $0, %eax
        movl 8(%esi), %ebx
        jmp .Lnorm
.LunderLSW:
        imull fpfd_lsw_bsr2mul(,%ebx,4), %eax
                                # Scale the mantissa to within normalized range
        movl fpfd_lsw_bsr2exp(,%ebx,4), %ebx
        addl 8(%esi), %ebx      # Correct the exponent
        movl %eax, %edx
        movl $0, %eax
        cmpl $1000000, %edx
        jae .Lnorm
        imull $10, %edx, %edx   # Mantissa still too small
        subl $1, %ebx           # Correct the exponent again
        jmp .Lnorm
.LoverLSW:
        movl %eax, %edi
        movl fpfd_lsw_bsr2mul(,%ebx,4), %edx
        mull %edx
        movl fpfd_lsw_bsr2shr(,%ebx,4), %ecx
        shrl %cl, %edx
        movl fpfd_lsw_bsr2exp(,%ebx,4), %ebx
        movl %edx, %ebp
        movl %edx, %eax
        movl fpfd_lsw_exp2mul(,%ebx,4), %edx
        mull %edx
        subl %eax, %edi
        movl %edi, %eax
        movl %ebp, %edx
        subl $1, %ebx
        jz .LexpcorrectLSW
        movl fpfd_lsw_exp2div(,%ebx,4), %edx
        mull %edx
        movl fpfd_lsw_exp2shr(,%ebx,4), %ecx
        shrl %cl, %edx
        movl %edx, %eax
        movl %ebp, %edx
.LexpcorrectLSW:
        addl $1, %ebx
        addl 8(%esi), %ebx      # Correct the exponent
        cmpl $10000000, %edx
        jb .Lnorm
        movl %eax, %edi         # Mantissa still too large
        movl %edx, %eax
        movl %edx, %ecx
        movl $0xCCCCCCCD, %edx
        mull %edx
        shrl $3, %edx           # Divide by 10
        addl $1, %ebx           # Correct the exponent again
        leal (%edx,%edx,4), %eax
        shll %eax
        subl %ecx, %eax
        negl %eax               # Calculate the remainder
        cmpl $0, %eax
        jne .Lnorm
        cmpl $5, %eax
        jne .Lnorm
        cmpl $0, %edi
        je .Lnorm
        addl $1, %edi           # Correct it with the last remainder
.Lnorm:
        movl %edx, (%esi)
        movl $0, 4(%esi)
        movl %ebx, 8(%esi)
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lzero:
        movl $0, 16(%esi)       # Set the special flag to FPFD_ZERO
        movl $0, %eax
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_scale, .-fpfd32_impl_scale
