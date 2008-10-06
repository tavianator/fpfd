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
        movq (%rdi), %rax       # Put dest->mant in rax
        bsrq %rax, %r8          # Find the leading non-zero bit
        jz .Lzero
        cmpq $1000000, %rax
        jb .Lunder              # The mantissa is too small
        cmpq $10000000, %rax
        jae .Lover              # The mantissa is too big
        movq %rax, %rdx
        movl $0, %eax
        movl 8(%rdi), %esi
        jmp .Lnorm
.Lunder:
        leaq fpfd32_scale_bsr2mul(%rip), %r9
        imull (%r9,%r8,4), %eax # Scale the mantissa to within normalized range
        leaq fpfd32_scale_bsr2exp(%rip), %r9
        movl (%r9,%r8,4), %esi
        addl 8(%rdi), %esi      # Correct the exponent
        movl %eax, %edx
        movl $0, %eax
        cmpl $1000000, %edx
        jae .Lnorm
        imulq $10, %rdx, %rdx   # Mantissa still too small
        subl $1, %esi           # Correct the exponent again
        jmp .Lnorm
.Lover:
        movq %rax, %r9
        leaq fpfd32_scale_bsr2div(%rip), %r10
        movq (%r10,%r8,8), %rdx
        mulq %rdx
        leaq fpfd32_scale_bsr2shr(%rip), %r10
        movb (%r10,%r8,1), %cl
        shrq %cl, %rdx
        leaq fpfd32_scale_bsr2exp(%rip), %r10
        movl (%r10,%r8,4), %esi
        movl %edx, %r8d
        movl %edx, %eax
        leaq fpfd32_scale_exp2mul(%rip), %r10
        movq (%r10,%rsi,8), %rdx
        mulq %rdx
        subq %rax, %r9
        movq %r9, %rax
        movl %r8d, %edx
        subl $1, %esi
        jz .Lexpcorrect
        leaq fpfd32_scale_exp2div(%rip), %r10
        movq (%r10,%rsi,8), %rdx
        mulq %rdx
        leaq fpfd32_scale_exp2shr(%rip), %r10
        movb (%r10,%rsi,1), %cl
        shrq %cl, %rdx
        movl %edx, %eax
        movl %r8d, %edx
        cmpl $0, %eax
        je .Lspecial
        cmpl $5, %eax
        jne .Lexpcorrect
.Lspecial:
        movl %eax, %ecx
        leaq fpfd32_scale_exp2mul(%rip), %r10
        movq (%r10,%rsi,8), %rdx
        mulq %rdx
        movl %r8d, %edx
        xchgq %rax, %rcx
        cmpq %rcx, %r9
        je .Lexpcorrect
        addl $1, %eax
.Lexpcorrect:
        addl $1, %esi
        addl 8(%rdi), %esi      # Correct the exponent
        cmpl $10000000, %edx
        jb .Lnorm
        movl %eax, %r8d         # Mantissa still too large
        movl %edx, %eax
        movl %edx, %ecx
        movq $0xCCCCCCCCCCCCCCCD, %rdx
        mulq %rdx
        shrq $3, %rdx           # Divide by 10
        addl $1, %esi           # Correct the exponent again
        leal (%edx,%edx,4), %eax
        shll %eax
        subl %ecx, %eax
        negl %eax               # Calculate the remainder
        cmpl $0, %eax
        je .Lspecial2
        cmpl $5, %eax
        jne .Lnorm
.Lspecial2:
        cmpl $0, %r8d
        je .Lnorm
        addl $1, %eax           # Correct it with the last remainder
.Lnorm:
        movq %rdx, (%rdi)
        movl %esi, 8(%rdi)
        ret
.Lzero:
        movl $0, 16(%rdi)       # Set the special flag to FPFD_ZERO
        movl $0, %eax
        ret
        .size fpfd32_impl_scale, .-fpfd32_impl_scale

        .section .rodata
        .align 32
        .type fpfd32_scale_bsr2mul, @object
        .size fpfd32_scale_bsr2mul, 80
fpfd32_scale_bsr2mul:
        .long 1000000                   # fpfd32_scale_bsr2mul[0]
        .long 1000000                   # fpfd32_scale_bsr2mul[1]
        .long 1000000                   # fpfd32_scale_bsr2mul[2]
        .long 100000                    # fpfd32_scale_bsr2mul[3]
        .long 100000                    # fpfd32_scale_bsr2mul[4]
        .long 100000                    # fpfd32_scale_bsr2mul[5]
        .long 10000                     # fpfd32_scale_bsr2mul[6]
        .long 10000                     # fpfd32_scale_bsr2mul[7]
        .long 10000                     # fpfd32_scale_bsr2mul[8]
        .long 1000                      # fpfd32_scale_bsr2mul[9]
        .long 1000                      # fpfd32_scale_bsr2mul[10]
        .long 1000                      # fpfd32_scale_bsr2mul[11]
        .long 1000                      # fpfd32_scale_bsr2mul[12]
        .long 100                       # fpfd32_scale_bsr2mul[13]
        .long 100                       # fpfd32_scale_bsr2mul[14]
        .long 100                       # fpfd32_scale_bsr2mul[15]
        .long 10                        # fpfd32_scale_bsr2mul[16]
        .long 10                        # fpfd32_scale_bsr2mul[17]
        .long 10                        # fpfd32_scale_bsr2mul[18]
        .long 10                        # fpfd32_scale_bsr2mul[19]

        .align 32
        .type fpfd32_scale_bsr2div, @object
        .size fpfd32_scale_bsr2div, 512
fpfd32_scale_bsr2div:
        .zero 184                       # fpfd32_scale_bsr2mul[i], i < 23
        .quad 0xCCCCCCCCCCCCCCCD        # fpfd32_scale_bsr2div[23] = 10 ** -1
        .quad 0xCCCCCCCCCCCCCCCD        # fpfd32_scale_bsr2div[24] = 10 ** -1
        .quad 0xCCCCCCCCCCCCCCCD        # fpfd32_scale_bsr2div[25] = 10 ** -1
        .quad 0xCCCCCCCCCCCCCCCD        # fpfd32_scale_bsr2div[26] = 10 ** -1
        .quad 0xA3D70A3D70A3D70B        # fpfd32_scale_bsr2div[27] = 10 ** -2
        .quad 0xA3D70A3D70A3D70B        # fpfd32_scale_bsr2div[28] = 10 ** -2
        .quad 0xA3D70A3D70A3D70B        # fpfd32_scale_bsr2div[29] = 10 ** -2
        .quad 0x83126E978D4FDF3C        # fpfd32_scale_bsr2div[30] = 10 ** -3
        .quad 0x83126E978D4FDF3C        # fpfd32_scale_bsr2div[31] = 10 ** -3
        .quad 0x83126E978D4FDF3C        # fpfd32_scale_bsr2div[32] = 10 ** -3
        .quad 0x83126E978D4FDF3C        # fpfd32_scale_bsr2div[33] = 10 ** -3
        .quad 0xD1B71758E219652C        # fpfd32_scale_bsr2div[34] = 10 ** -4
        .quad 0xD1B71758E219652C        # fpfd32_scale_bsr2div[35] = 10 ** -4
        .quad 0xD1B71758E219652C        # fpfd32_scale_bsr2div[36] = 10 ** -4
        .quad 0xA7C5AC471B478424        # fpfd32_scale_bsr2div[37] = 10 ** -5
        .quad 0xA7C5AC471B478424        # fpfd32_scale_bsr2div[38] = 10 ** -5
        .quad 0xA7C5AC471B478424        # fpfd32_scale_bsr2div[39] = 10 ** -5
        .quad 0x8637BD05AF6C69B6        # fpfd32_scale_bsr2div[40] = 10 ** -6
        .quad 0x8637BD05AF6C69B6        # fpfd32_scale_bsr2div[41] = 10 ** -6
        .quad 0x8637BD05AF6C69B6        # fpfd32_scale_bsr2div[42] = 10 ** -6
        .quad 0x8637BD05AF6C69B6        # fpfd32_scale_bsr2div[43] = 10 ** -6
        .quad 0xD6BF94D5E57A42BD        # fpfd32_scale_bsr2div[44] = 10 ** -7
        .quad 0xD6BF94D5E57A42BD        # fpfd32_scale_bsr2div[45] = 10 ** -7
        .quad 0xD6BF94D5E57A42BD        # fpfd32_scale_bsr2div[46] = 10 ** -7
        .quad 0xABCC77118461CEFD        # fpfd32_scale_bsr2div[47] = 10 ** -8
        .quad 0xABCC77118461CEFD        # fpfd32_scale_bsr2div[48] = 10 ** -8
        .quad 0xABCC77118461CEFD        # fpfd32_scale_bsr2div[49] = 10 ** -8
        .quad 0x89705F4136B4A598        # fpfd32_scale_bsr2div[50] = 10 ** -9
        .quad 0x89705F4136B4A598        # fpfd32_scale_bsr2div[51] = 10 ** -9
        .quad 0x89705F4136B4A598        # fpfd32_scale_bsr2div[52] = 10 ** -9
        .quad 0x89705F4136B4A598        # fpfd32_scale_bsr2div[53] = 10 ** -9
        .quad 0xDBE6FECEBDEDD5BF        # fpfd32_scale_bsr2div[54] = 10 ** -10
        .quad 0xDBE6FECEBDEDD5BF        # fpfd32_scale_bsr2div[55] = 10 ** -10
        .quad 0xDBE6FECEBDEDD5BF        # fpfd32_scale_bsr2div[56] = 10 ** -10
        .quad 0xAFEBFF0BCB24AAFF        # fpfd32_scale_bsr2div[57] = 10 ** -11
        .quad 0xAFEBFF0BCB24AAFF        # fpfd32_scale_bsr2div[58] = 10 ** -11
        .quad 0xAFEBFF0BCB24AAFF        # fpfd32_scale_bsr2div[59] = 10 ** -11
        .quad 0x119799812DEA111A        # fpfd32_scale_bsr2div[60] = 10 ** -12
        .quad 0x119799812DEA111A        # fpfd32_scale_bsr2div[61] = 10 ** -12
        .quad 0x119799812DEA111A        # fpfd32_scale_bsr2div[62] = 10 ** -12
        .quad 0x119799812DEA111A        # fpfd32_scale_bsr2div[63] = 10 ** -12

        .align 32
        .type fpfd32_scale_bsr2shr, @object
        .size fpfd32_scale_bsr2shr, 64
fpfd32_scale_bsr2shr:
        .zero 23        # fpfd32_scale_bsr2shr[i], i < 23, is undefined
        .byte 3         # fpfd32_scale_bsr2shr[23]
        .byte 3         # fpfd32_scale_bsr2shr[24]
        .byte 3         # fpfd32_scale_bsr2shr[25]
        .byte 3         # fpfd32_scale_bsr2shr[26]
        .byte 6         # fpfd32_scale_bsr2shr[27]
        .byte 6         # fpfd32_scale_bsr2shr[28]
        .byte 6         # fpfd32_scale_bsr2shr[29]
        .byte 9         # fpfd32_scale_bsr2shr[30]
        .byte 9         # fpfd32_scale_bsr2shr[31]
        .byte 9         # fpfd32_scale_bsr2shr[32]
        .byte 9         # fpfd32_scale_bsr2shr[33]
        .byte 13        # fpfd32_scale_bsr2shr[34]
        .byte 13        # fpfd32_scale_bsr2shr[35]
        .byte 13        # fpfd32_scale_bsr2shr[36]
        .byte 16        # fpfd32_scale_bsr2shr[37]
        .byte 16        # fpfd32_scale_bsr2shr[38]
        .byte 16        # fpfd32_scale_bsr2shr[39]
        .byte 19        # fpfd32_scale_bsr2shr[40]
        .byte 19        # fpfd32_scale_bsr2shr[41]
        .byte 19        # fpfd32_scale_bsr2shr[42]
        .byte 19        # fpfd32_scale_bsr2shr[43]
        .byte 23        # fpfd32_scale_bsr2shr[44]
        .byte 23        # fpfd32_scale_bsr2shr[45]
        .byte 23        # fpfd32_scale_bsr2shr[46]
        .byte 26        # fpfd32_scale_bsr2shr[47]
        .byte 26        # fpfd32_scale_bsr2shr[48]
        .byte 26        # fpfd32_scale_bsr2shr[49]
        .byte 29        # fpfd32_scale_bsr2shr[50]
        .byte 29        # fpfd32_scale_bsr2shr[51]
        .byte 29        # fpfd32_scale_bsr2shr[52]
        .byte 29        # fpfd32_scale_bsr2shr[53]
        .byte 33        # fpfd32_scale_bsr2shr[54]
        .byte 33        # fpfd32_scale_bsr2shr[55]
        .byte 33        # fpfd32_scale_bsr2shr[56]
        .byte 36        # fpfd32_scale_bsr2shr[57]
        .byte 36        # fpfd32_scale_bsr2shr[58]
        .byte 36        # fpfd32_scale_bsr2shr[59]
        .byte 36        # fpfd32_scale_bsr2shr[60]
        .byte 36        # fpfd32_scale_bsr2shr[61]
        .byte 36        # fpfd32_scale_bsr2shr[62]
        .byte 36        # fpfd32_scale_bsr2shr[63]

        .align 32
        .type fpfd32_scale_bsr2exp, @object
        .size fpfd32_scale_bsr2exp, 256
fpfd32_scale_bsr2exp:
        .long -6        # fpfd32_scale_bsr2exp[0]
        .long -6        # fpfd32_scale_bsr2exp[1]
        .long -6        # fpfd32_scale_bsr2exp[2]
        .long -5        # fpfd32_scale_bsr2exp[3]
        .long -5        # fpfd32_scale_bsr2exp[4]
        .long -5        # fpfd32_scale_bsr2exp[5]
        .long -4        # fpfd32_scale_bsr2exp[6]
        .long -4        # fpfd32_scale_bsr2exp[7]
        .long -4        # fpfd32_scale_bsr2exp[8]
        .long -3        # fpfd32_scale_bsr2exp[9]
        .long -3        # fpfd32_scale_bsr2exp[10]
        .long -3        # fpfd32_scale_bsr2exp[11]
        .long -3        # fpfd32_scale_bsr2exp[12]
        .long -2        # fpfd32_scale_bsr2exp[13]
        .long -2        # fpfd32_scale_bsr2exp[14]
        .long -2        # fpfd32_scale_bsr2exp[15]
        .long -1        # fpfd32_scale_bsr2exp[16]
        .long -1        # fpfd32_scale_bsr2exp[17]
        .long -1        # fpfd32_scale_bsr2exp[18]
        .long -1        # fpfd32_scale_bsr2exp[19]
        .long 0         # fpfd32_scale_bsr2exp[20]
        .long 0         # fpfd32_scale_bsr2exp[21]
        .long 0         # fpfd32_scale_bsr2exp[22]
        .long 1         # fpfd32_scale_bsr2exp[23]
        .long 1         # fpfd32_scale_bsr2exp[24]
        .long 1         # fpfd32_scale_bsr2exp[25]
        .long 1         # fpfd32_scale_bsr2exp[26]
        .long 2         # fpfd32_scale_bsr2exp[27]
        .long 2         # fpfd32_scale_bsr2exp[28]
        .long 2         # fpfd32_scale_bsr2exp[29]
        .long 3         # fpfd32_scale_bsr2exp[30]
        .long 3         # fpfd32_scale_bsr2exp[31]
        .long 3         # fpfd32_scale_bsr2exp[32]
        .long 3         # fpfd32_scale_bsr2exp[33]
        .long 4         # fpfd32_scale_bsr2exp[34]
        .long 4         # fpfd32_scale_bsr2exp[35]
        .long 4         # fpfd32_scale_bsr2exp[36]
        .long 5         # fpfd32_scale_bsr2exp[37]
        .long 5         # fpfd32_scale_bsr2exp[38]
        .long 5         # fpfd32_scale_bsr2exp[39]
        .long 6         # fpfd32_scale_bsr2exp[40]
        .long 6         # fpfd32_scale_bsr2exp[41]
        .long 6         # fpfd32_scale_bsr2exp[42]
        .long 6         # fpfd32_scale_bsr2exp[43]
        .long 7         # fpfd32_scale_bsr2exp[44]
        .long 7         # fpfd32_scale_bsr2exp[45]
        .long 7         # fpfd32_scale_bsr2exp[46]
        .long 8         # fpfd32_scale_bsr2exp[47]
        .long 8         # fpfd32_scale_bsr2exp[48]
        .long 8         # fpfd32_scale_bsr2exp[49]
        .long 9         # fpfd32_scale_bsr2exp[50]
        .long 9         # fpfd32_scale_bsr2exp[51]
        .long 9         # fpfd32_scale_bsr2exp[52]
        .long 9         # fpfd32_scale_bsr2exp[53]
        .long 10        # fpfd32_scale_bsr2exp[54]
        .long 10        # fpfd32_scale_bsr2exp[55]
        .long 10        # fpfd32_scale_bsr2exp[56]
        .long 11        # fpfd32_scale_bsr2exp[57]
        .long 11        # fpfd32_scale_bsr2exp[58]
        .long 11        # fpfd32_scale_bsr2exp[59]
        .long 12        # fpfd32_scale_bsr2exp[60]
        .long 12        # fpfd32_scale_bsr2exp[61]
        .long 12        # fpfd32_scale_bsr2exp[62]
        .long 12        # fpfd32_scale_bsr2exp[63]

        .align 32
        .type fpfd32_scale_exp2mul, @object
        .size fpfd32_scale_exp2mul, 104
fpfd32_scale_exp2mul:
        .quad 1                 # fpfd32_scale_exp2mul[0]
        .quad 10                # fpfd32_scale_exp2mul[1]
        .quad 100               # fpfd32_scale_exp2mul[2]
        .quad 1000              # fpfd32_scale_exp2mul[3]
        .quad 10000             # fpfd32_scale_exp2mul[4]
        .quad 100000            # fpfd32_scale_exp2mul[5]
        .quad 1000000           # fpfd32_scale_exp2mul[6]
        .quad 10000000          # fpfd32_scale_exp2mul[7]
        .quad 100000000         # fpfd32_scale_exp2mul[8]
        .quad 1000000000        # fpfd32_scale_exp2mul[9]
        .quad 10000000000       # fpfd32_scale_exp2mul[10]
        .quad 100000000000      # fpfd32_scale_exp2mul[11]
        .quad 1000000000000     # fpfd32_scale_exp2mul[12]

        .align 32
        .type fpfd32_scale_exp2div, @object
        .size fpfd32_scale_exp2div, 96
fpfd32_scale_exp2div:
        .quad 0                         # fpfd32_scale_exp2div[0] is undefined
        .quad 0xCCCCCCCCCCCCCCCD        # fpfd32_scale_exp2div[1]  = 10 ** -1
        .quad 0xA3D70A3D70A3D70B        # fpfd32_scale_exp2div[2]  = 10 ** -2
        .quad 0x83126E978D4FDF3C        # fpfd32_scale_exp2div[3]  = 10 ** -3
        .quad 0xD1B71758E219652C        # fpfd32_scale_exp2div[4]  = 10 ** -4
        .quad 0xA7C5AC471B478424        # fpfd32_scale_exp2div[5]  = 10 ** -5
        .quad 0x8637BD05AF6C69B6        # fpfd32_scale_exp2div[6]  = 10 ** -6
        .quad 0xD6BF94D5E57A42BD        # fpfd32_scale_exp2div[7]  = 10 ** -7
        .quad 0xABCC77118461CEFD        # fpfd32_scale_exp2div[8]  = 10 ** -8
        .quad 0x89705F4136B4A598        # fpfd32_scale_exp2div[9]  = 10 ** -9
        .quad 0xDBE6FECEBDEDD5BF        # fpfd32_scale_exp2div[10] = 10 ** -10
        .quad 0xAFEBFF0BCB24AAFF        # fpfd32_scale_exp2div[11] = 10 ** -11

        .align 32
        .type fpfd32_scale_exp2shr, @object
        .size fpfd32_scale_exp2shr, 12
fpfd32_scale_exp2shr:
        .byte 0         # fpfd32_scale_exp2shr[0] is undefined
        .byte 3         # fpfd32_scale_exp2shr[1]
        .byte 6         # fpfd32_scale_exp2shr[2]
        .byte 9         # fpfd32_scale_exp2shr[3]
        .byte 13        # fpfd32_scale_exp2shr[4]
        .byte 16        # fpfd32_scale_exp2shr[5]
        .byte 19        # fpfd32_scale_exp2shr[6]
        .byte 23        # fpfd32_scale_exp2shr[7]
        .byte 26        # fpfd32_scale_exp2shr[8]
        .byte 29        # fpfd32_scale_exp2shr[9]
        .byte 33        # fpfd32_scale_exp2shr[10]
        .byte 36        # fpfd32_scale_exp2shr[11]
