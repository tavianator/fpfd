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
        imull fpfd32_scale_lsw_bsr2mul(,%ebx,4), %eax
                                # Scale the mantissa to within normalized range
        movl fpfd32_scale_lsw_bsr2exp(,%ebx,4), %ebx
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
        movl fpfd32_scale_lsw_bsr2mul(,%ebx,4), %edx
        mull %edx
        movl fpfd32_scale_lsw_bsr2shr(,%ebx,4), %ecx
        shrl %cl, %edx
        movl fpfd32_scale_lsw_bsr2exp(,%ebx,4), %ebx
        movl %edx, %ebp
        movl %edx, %eax
        movl fpfd32_scale_lsw_exp2mul(,%ebx,4), %edx
        mull %edx
        subl %eax, %edi
        movl %edi, %eax
        movl %ebp, %edx
        subl $1, %ebx
        jz .LexpcorrectLSW
        movl fpfd32_scale_lsw_exp2div(,%ebx,4), %edx
        mull %edx
        movl fpfd32_scale_lsw_exp2shr(,%ebx,4), %ecx
        shrl %cl, %edx
        movl %edx, %eax
        movl %ebp, %edx
        cmpl $0, %eax
        je .LspecialLSW
        cmpl $5, %eax
        jne .LexpcorrectLSW
.LspecialLSW:
        movl %eax, %ecx
        movl fpfd32_scale_lsw_exp2mul(,%ebx,4), %edx
        mull %edx
        movl %ebp, %edx
        xchgl %eax, %ecx
        cmpl %ecx, %edi
        je .LexpcorrectLSW
        addl $1, %eax
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
        je .LspecialLSW2
        cmpl $5, %eax
        jne .Lnorm
.LspecialLSW2:
        cmpl $0, %edi
        je .Lnorm
        addl $1, %eax           # Correct it with the last remainder
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

        .data
.globl fpfd32_scale_lsw_bsr2mul
        .align 32
        .type fpfd32_scale_lsw_bsr2mul, @object
        .size fpfd32_scale_lsw_bsr2mul, 256
fpfd32_scale_lsw_bsr2mul:
        .long 1000000           # fpfd32_scale_lsw_bsr2mul[0]
        .long 1000000           # fpfd32_scale_lsw_bsr2mul[1]
        .long 1000000           # fpfd32_scale_lsw_bsr2mul[2]
        .long 100000            # fpfd32_scale_lsw_bsr2mul[3]
        .long 100000            # fpfd32_scale_lsw_bsr2mul[4]
        .long 100000            # fpfd32_scale_lsw_bsr2mul[5]
        .long 10000             # fpfd32_scale_lsw_bsr2mul[6]
        .long 10000             # fpfd32_scale_lsw_bsr2mul[7]
        .long 10000             # fpfd32_scale_lsw_bsr2mul[8]
        .long 1000              # fpfd32_scale_lsw_bsr2mul[9]
        .long 1000              # fpfd32_scale_lsw_bsr2mul[10]
        .long 1000              # fpfd32_scale_lsw_bsr2mul[11]
        .long 1000              # fpfd32_scale_lsw_bsr2mul[12]
        .long 100               # fpfd32_scale_lsw_bsr2mul[13]
        .long 100               # fpfd32_scale_lsw_bsr2mul[14]
        .long 100               # fpfd32_scale_lsw_bsr2mul[15]
        .long 10                # fpfd32_scale_lsw_bsr2mul[16]
        .long 10                # fpfd32_scale_lsw_bsr2mul[17]
        .long 10                # fpfd32_scale_lsw_bsr2mul[18]
        .long 1                 # fpfd32_scale_lsw_bsr2mul[19]
        .long 1                 # fpfd32_scale_lsw_bsr2mul[20]
        .long 1                 # fpfd32_scale_lsw_bsr2mul[21]
        .long 1                 # fpfd32_scale_lsw_bsr2mul[22]
        .long 0xCCCCCCCD        # fpfd32_scale_lsw_bsr2mul[23]
                                #   = (10 ** -1 << 35) + 1
        .long 0xCCCCCCCD        # fpfd32_scale_lsw_bsr2mul[24]
        .long 0xCCCCCCCD        # fpfd32_scale_lsw_bsr2mul[25]
        .long 0xCCCCCCCD        # fpfd32_scale_lsw_bsr2mul[26]
        .long 0xA3D70A3E        # fpfd32_scale_lsw_bsr2mul[27]
                                #   = (10 ** -2 << 38) + 1
        .long 0xA3D70A3E        # fpfd32_scale_lsw_bsr2mul[28]
        .long 0xA3D70A3E        # fpfd32_scale_lsw_bsr2mul[29]
        .long 0x83126E98        # fpfd32_scale_lsw_bsr2mul[30]
                                #   = (10 ** -3 << 41) + 1
        .long 0x83126E98        # fpfd32_scale_lsw_bsr2mul[31]

.globl fpfd32_scale_lsw_bsr2shr
        .align 32
        .type fpfd32_scale_lsw_bsr2shr, @object
        .size fpfd32_scale_lsw_bsr2shr, 256
fpfd32_scale_lsw_bsr2shr:
        .zero 92        # fpfd32_scale_lsw_bsr2shr[i], i < 23, is undefined
        .long 3         # fpfd32_scale_lsw_bsr2shr[23]
        .long 3         # fpfd32_scale_lsw_bsr2shr[24]
        .long 3         # fpfd32_scale_lsw_bsr2shr[25]
        .long 3         # fpfd32_scale_lsw_bsr2shr[26]
        .long 6         # fpfd32_scale_lsw_bsr2shr[27]
        .long 6         # fpfd32_scale_lsw_bsr2shr[28]
        .long 6         # fpfd32_scale_lsw_bsr2shr[29]
        .long 9         # fpfd32_scale_lsw_bsr2shr[30]
        .long 9         # fpfd32_scale_lsw_bsr2shr[31]

.globl fpfd32_scale_lsw_bsr2exp
        .align 32
        .type fpfd32_scale_lsw_bsr2exp, @object
        .size fpfd32_scale_lsw_bsr2exp, 256
fpfd32_scale_lsw_bsr2exp:
        .long -6        # fpfd32_scale_lsw_bsr2exp[0]
        .long -6        # fpfd32_scale_lsw_bsr2exp[1]
        .long -6        # fpfd32_scale_lsw_bsr2exp[2]
        .long -5        # fpfd32_scale_lsw_bsr2exp[3]
        .long -5        # fpfd32_scale_lsw_bsr2exp[4]
        .long -5        # fpfd32_scale_lsw_bsr2exp[5]
        .long -4        # fpfd32_scale_lsw_bsr2exp[6]
        .long -4        # fpfd32_scale_lsw_bsr2exp[7]
        .long -4        # fpfd32_scale_lsw_bsr2exp[8]
        .long -3        # fpfd32_scale_lsw_bsr2exp[9]
        .long -3        # fpfd32_scale_lsw_bsr2exp[10]
        .long -3        # fpfd32_scale_lsw_bsr2exp[11]
        .long -3        # fpfd32_scale_lsw_bsr2exp[12]
        .long -2        # fpfd32_scale_lsw_bsr2exp[13]
        .long -2        # fpfd32_scale_lsw_bsr2exp[14]
        .long -2        # fpfd32_scale_lsw_bsr2exp[15]
        .long -1        # fpfd32_scale_lsw_bsr2exp[16]
        .long -1        # fpfd32_scale_lsw_bsr2exp[17]
        .long -1        # fpfd32_scale_lsw_bsr2exp[18]
        .long 0         # fpfd32_scale_lsw_bsr2exp[19]
        .long 0         # fpfd32_scale_lsw_bsr2exp[20]
        .long 0         # fpfd32_scale_lsw_bsr2exp[21]
        .long 0         # fpfd32_scale_lsw_bsr2exp[22]
        .long 1         # fpfd32_scale_lsw_bsr2exp[23]
        .long 1         # fpfd32_scale_lsw_bsr2exp[24]
        .long 1         # fpfd32_scale_lsw_bsr2exp[25]
        .long 1         # fpfd32_scale_lsw_bsr2exp[26]
        .long 2         # fpfd32_scale_lsw_bsr2exp[27]
        .long 2         # fpfd32_scale_lsw_bsr2exp[28]
        .long 2         # fpfd32_scale_lsw_bsr2exp[29]
        .long 3         # fpfd32_scale_lsw_bsr2exp[30]
        .long 3         # fpfd32_scale_lsw_bsr2exp[31]

.globl fpfd32_scale_lsw_exp2mul
        .align 32
        .type fpfd32_scale_lsw_exp2mul, @object
        .size fpfd32_scale_lsw_exp2mul, 256
fpfd32_scale_lsw_exp2mul:
        .long 1         # fpfd32_scale_lsw_exp2mul[0]
        .long 10        # fpfd32_scale_lsw_exp2mul[1]
        .long 100       # fpfd32_scale_lsw_exp2mul[2]
        .long 1000      # fpfd32_scale_lsw_exp2mul[3]

.globl fpfd32_scale_lsw_exp2div
        .align 32
        .type fpfd32_scale_lsw_exp2div, @object
        .size fpfd32_scale_lsw_exp2div, 256
fpfd32_scale_lsw_exp2div:
        .long 0                 # fpfd32_scale_lsw_exp2div[0] is undefined
        .long 0xCCCCCCCD        # fpfd32_scale_lsw_exp2div[1]
                                #   = (10 ** -1 << 35) + 1
        .long 0xA3D70A3E        # fpfd32_scale_lsw_exp2div[2]
                                #   = (10 ** -2 << 38) + 1
        .long 0x83126E98        # fpfd32_scale_lsw_exp2div[3]
                                #   = (10 ** -3 << 41) + 1

.globl fpfd32_scale_lsw_exp2shr
        .align 32
        .type fpfd32_scale_lsw_exp2shr, @object
        .size fpfd32_scale_lsw_exp2shr, 256
fpfd32_scale_lsw_exp2shr:
        .long 0         # fpfd32_scale_lsw_exp2shr[0] is undefined
        .long 3         # fpfd32_scale_lsw_exp2shr[1]
        .long 6         # fpfd32_scale_lsw_exp2shr[2]
        .long 9         # fpfd32_scale_lsw_exp2shr[3]
