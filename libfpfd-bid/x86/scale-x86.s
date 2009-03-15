/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library.                                *
 *                                                                       *
 * The FPFD Library is free software; you can redistribute it and/or     *
 * modify it under the terms of the GNU Lesser General Public License as *
 * published by the Free Software Foundation; either version 3 of the    *
 * License, or (at your option) any later version.                       *
 *                                                                       *
 * The FPFD Library is distributed in the hope that it will be useful,   *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 * Lesser General Public License for more details.                       *
 *                                                                       *
 * You should have received a copy of the GNU Lesser General Public      *
 * License along with this program.  If not, see                         *
 * <http://www.gnu.org/licenses/>.                                       *
 *************************************************************************/

/* unsigned int fpfd32_impl_scale(fpfd32_impl_t *dest); */

/*
 * Scale dest, so it can be compressed.
 */

        .text
.globl fpfd32_impl_scale
        .type fpfd32_impl_scale, @function
fpfd32_impl_scale:
        pushl %ebx
        pushl %esi
        pushl %edi
        pushl %ebp
        subl $12, %esp
        movl 32(%esp), %esi     /* Put dest in esi */
        movl (%esi), %eax        
        movl 4(%esi), %edx      /* Put dest->mant in edx:eax */
        bsrl %edx, %ebx         /* Find the leading non-zero bit */
        jz .LLSW
        movl %eax, 4(%esp)
        movl %edx, 8(%esp)
        movl msw_bsr2div+4(,%ebx,8), %ecx
        mull %ecx
        movl %eax, %edi
        movl %edx, %ebp
        movl 8(%esp), %eax
        mull %ecx
        addl %eax, %ebp
        adcl $0, %edx
        movl %edx, %ecx
        movl 8(%esp), %eax
        mull msw_bsr2div(,%ebx,8)
        addl %eax, %edi
        adcl %edx, %ebp
        adcl $0, %ecx
        movl 4(%esp), %eax
        mull msw_bsr2div(,%ebx,8)
        addl %edx, %edi
        adcl $0, %ebp
        adcl $0, %ecx
        movl %ebp, %eax
        movl %ecx, %edx
        movb msw_bsr2shr(,%ebx,1), %cl
        cmpb $32, %cl
        jb .LshrdMSW
        subb $32, %cl
        shrl %cl, %edx
        movl %edx, %eax
        xorb %cl, %cl
.LshrdMSW:
        shrdl %cl, %edx, %eax
        movl msw_bsr2exp(,%ebx,4), %ebx
        movl %eax, (%esp)
        movl %eax, %edi
        mull msw_exp2mul(,%ebx,8)
        movl %eax, %ebp
        movl %edx, %ecx
        movl %edi, %eax
        mull msw_exp2mul+4(,%ebx,8)
        addl %ecx, %eax
        subl %ebp, 4(%esp)
        sbbl %eax, 8(%esp)
        movl 4(%esp), %eax
        subl $1, %ebx
        movl msw_exp2div+4(,%ebx,8), %ecx
        mull %ecx
        movl %eax, %edi
        movl %edx, %ebp
        movl 8(%esp), %eax
        mull %ecx
        addl %eax, %ebp
        adcl $0, %edx
        movl %edx, %ecx
        movl 8(%esp), %eax
        mull msw_exp2div(,%ebx,8)
        addl %eax, %edi
        adcl %edx, %ebp
        adcl $0, %ecx
        movl 4(%esp), %eax
        mull msw_exp2div(,%ebx,8)
        addl %edx, %edi
        adcl $0, %ebp
        adcl $0, %ecx
        movl %ebp, %eax
        movl %ecx, %edx
        movb msw_exp2shr(,%ebx,1), %cl
        cmpb $32, %cl
        jb .LshrdremMSW
        subb $32, %cl
        shrl %cl, %edx
        movl %edx, %eax
        xorb %cl, %cl
.LshrdremMSW:
        shrdl %cl, %edx, %eax
        movl (%esp), %edx
        testl %eax, %eax
        jz .LspecialMSW
        cmpl $5, %eax
        jne .LexpcorrectLSW
.LspecialMSW:
        movl %eax, %edi
        mull msw_exp2mul(,%ebx,8)
        movl %eax, %ebp
        movl %edx, %ecx
        movl %edi, %eax
        mull msw_exp2mul+4(,%ebx,8)
        addl %eax, %ecx
        movl %edi, %eax
        movl (%esp), %edx
        cmpl %ebp, 4(%esp)
        jne .LremcorrectMSW
        cmpl %ecx, 8(%esp)
        je .LexpcorrectLSW
.LremcorrectMSW:
        addl $1, %eax
        jmp .LexpcorrectLSW
.LLSW:
        bsrl %eax, %ebx
        jz .Luflow
        cmpl $1000000, %eax
        jb .LunderLSW           /* The mantissa is too small */
        cmpl $10000000, %eax
        jae .LoverLSW           /* The mantissa is too big */
        movl %eax, %edx
        movl $0x20, %eax
        movl 8(%esi), %ebx
        jmp .Lnorm
.LunderLSW:
        /* Scale the mantissa to within normalized range */
        imull lsw_bsr2mul(,%ebx,4), %eax
        movl lsw_bsr2exp(,%ebx,4), %ebx
        addl 8(%esi), %ebx      /* Correct the exponent */
        movl %eax, %edx
        xorl %eax, %eax
        cmpl $1000000, %edx
        jae .Lnorm
        imull $10, %edx, %edx   /* Mantissa still too small */
        subl $1, %ebx           /* Correct the exponent again */
        jmp .Lnorm
.LoverLSW:
        movl %eax, %edi
        mull lsw_bsr2div(,%ebx,4)
        movb lsw_bsr2shr(,%ebx,1), %cl
        shrl %cl, %edx
        movl lsw_bsr2exp(,%ebx,4), %ebx
        movl %edx, %ebp
        movl %edx, %eax
        mull lsw_exp2mul(,%ebx,4)
        subl %eax, %edi
        movl %edi, %eax
        movl %ebp, %edx
        subl $1, %ebx
        jz .LexpcorrectLSW
        mull lsw_exp2div(,%ebx,4)
        movb lsw_exp2shr(,%ebx,1), %cl
        shrl %cl, %edx
        movl %edx, %eax
        movl %ebp, %edx
        testl %eax, %eax
        jz .LspecialLSW
        cmpl $5, %eax
        jne .LexpcorrectLSW
.LspecialLSW:
        movl %eax, %ecx
        mull lsw_exp2mul(,%ebx,4)
        movl %ebp, %edx
        xchgl %eax, %ecx
        cmpl %ecx, %edi
        je .LexpcorrectLSW
        addl $1, %eax
.LexpcorrectLSW:
        addl $1, %ebx
        addl 8(%esi), %ebx      /* Correct the exponent */
        cmpl $10000000, %edx
        jb .Lnorm
        movl %eax, %edi         /* Mantissa still too large */
        movl %edx, %eax
        movl %edx, %ecx
        movl $0x1999999A, %edx
        mull %edx               /* Divide by 10 */
        addl $1, %ebx           /* Correct the exponent again */
        leal (%edx,%edx,4), %eax
        shll %eax
        subl %ecx, %eax
        negl %eax               /* Calculate the remainder */
        testl %eax, %eax
        jz .LspecialLSW2
        cmpl $5, %eax
        jne .Lnorm
.LspecialLSW2:
        testl %edi, %edi
        jz .Lnorm
        addl $1, %eax           /* Correct it with the last remainder */
.Lnorm:
        cmpl $90, %ebx
        jg .Loflow
        cmpl $-108, %ebx
        jl .Luflow
        je .Lpuflow
        cmpl $-101, %ebx
        jl .Lsubnorm
        movl %edx, (%esi)
        movl $0, 4(%esi)
        movl %ebx, 8(%esi)
        addl $12, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lsubnorm:
        negl %ebx
        subl $101, %ebx
        movl %eax, 8(%esp)
        movl %edx, %edi
        movl %edx, %eax
        mull lsw_exp2div(,%ebx,4)
        movb lsw_exp2shr(,%ebx,1), %cl
        shrl %cl, %edx
        movl %edx, %ecx
        movl %edx, %eax
        mull lsw_exp2mul(,%ebx,4)
        subl %eax, %edi
        movl %edi, %eax
        movl %ecx, %edx
        subl $1, %ebx
        jz .Lsubnormret
        movl %edx, %ebp
        mull lsw_exp2div(,%ebx,4)
        movb lsw_exp2shr(,%ebx,1), %cl
        shrl %cl, %edx
        movl %edx, %eax
        movl %ebp, %edx
        testl %eax, %eax
        jz .Lspecial
        cmpl $5, %eax
        jne .Lsubnormret
.Lspecial:
        movl %eax, %ecx
        mull lsw_exp2mul(,%ebx,4)
        movl %ebp, %edx
        xchgl %eax, %ecx
        cmpl %ecx, %edi
        je .Lspecial2
        addl $1, %eax
.Lspecial2:
        testl %eax, %eax
        jz .Lspecial3
        cmpl $5, %eax
        jne .Lsubnormret
.Lspecial3:
        testl $0x1F, 8(%esp)
        jz .Lsubnormret
        addl $1, %eax
.Lsubnormret:
        orl $0x10, %eax
        movl %edx, (%esi)
        movl $0, 4(%esi)
        movl $-101, 8(%esi)
        addl $12, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Loflow:
        movl $9999999, (%esi)
        movl $0, 4(%esi)        /* Set to the highest significand possible */
        movl $90, 8(%esi)       /* Set the exponent to the maximum exponent */
        movl $10, %eax          /* Return the special 10 value */
        addl $12, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Luflow:
        movl $0, 16(%esi)       /* Set the special flag to FPFD_ZERO */
        movl $0x1A, %eax
        addl $12, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lpuflow:
        movl $0, (%esi)
        movl $0, 4(%esi)        /* Set the significand to zero */
        movl $-101, 8(%esi)     /* Set the exponent to the subnormal exponent */
        movl %eax, %ebp
        movl %edx, %eax
        movl %edx, %ecx
        movl $0x8637BD06, %edx
        mull %edx
        shrl $19, %edx
        movl %edx, %eax
        movl %edx, %ebx
        movl $1000000, %edx
        mull %edx
        subl %eax, %ecx
        movl %ebx, %eax
        orl $0x10, %eax
        cmpl $0x10, %eax
        je .Lspecial4
        cmpl $0x15, %eax
        je .Lspecial4
        addl $12, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lspecial4:
        testl %ebx, %ebx
        jz .Lspecial5
        addl $1, %eax           /* Correct it with the last remainder */
.Lspecial5:
        cmpl $0x10, %eax
        je .Lspecial6
        cmpl $0x15, %eax
        je .Lspecial6
        addl $12, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lspecial6:
        testl $0x1F, %ebp
        jz .Lspecial7
        addl $1, %eax
.Lspecial7:
        addl $12, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_scale, .-fpfd32_impl_scale

        .section .rodata
        .align 32
        .type msw_bsr2div, @object
        .size msw_bsr2div, 256
msw_bsr2div:
        .quad 0x83126E978D4FDF3C        /* msw_bsr2div[0] = 10 ** -3 */
        .quad 0x83126E978D4FDF3C        /* msw_bsr2div[1] = 10 ** -3 */
        .quad 0xD1B71758E219652C        /* msw_bsr2div[2] = 10 ** -4 */
        .quad 0xD1B71758E219652C        /* msw_bsr2div[3] = 10 ** -4 */
        .quad 0xD1B71758E219652C        /* msw_bsr2div[4] = 10 ** -4 */
        .quad 0xA7C5AC471B478424        /* msw_bsr2div[5] = 10 ** -5 */
        .quad 0xA7C5AC471B478424        /* msw_bsr2div[6] = 10 ** -5 */
        .quad 0xA7C5AC471B478424        /* msw_bsr2div[7] = 10 ** -5 */
        .quad 0x8637BD05AF6C69B6        /* msw_bsr2div[8] = 10 ** -6 */
        .quad 0x8637BD05AF6C69B6        /* msw_bsr2div[9] = 10 ** -6 */
        .quad 0x8637BD05AF6C69B6        /* msw_bsr2div[10] = 10 ** -6 */
        .quad 0x8637BD05AF6C69B6        /* msw_bsr2div[11] = 10 ** -6 */
        .quad 0xD6BF94D5E57A42BD        /* msw_bsr2div[12] = 10 ** -7 */
        .quad 0xD6BF94D5E57A42BD        /* msw_bsr2div[13] = 10 ** -7 */
        .quad 0xD6BF94D5E57A42BD        /* msw_bsr2div[14] = 10 ** -7 */
        .quad 0xABCC77118461CEFD        /* msw_bsr2div[15] = 10 ** -8 */
        .quad 0xABCC77118461CEFD        /* msw_bsr2div[16] = 10 ** -8 */
        .quad 0xABCC77118461CEFD        /* msw_bsr2div[17] = 10 ** -8 */
        .quad 0x89705F4136B4A598        /* msw_bsr2div[18] = 10 ** -9 */
        .quad 0x89705F4136B4A598        /* msw_bsr2div[19] = 10 ** -9 */
        .quad 0x89705F4136B4A598        /* msw_bsr2div[20] = 10 ** -9 */
        .quad 0x89705F4136B4A598        /* msw_bsr2div[21] = 10 ** -9 */
        .quad 0xDBE6FECEBDEDD5BF        /* msw_bsr2div[22] = 10 ** -10 */
        .quad 0xDBE6FECEBDEDD5BF        /* msw_bsr2div[23] = 10 ** -10 */
        .quad 0xDBE6FECEBDEDD5BF        /* msw_bsr2div[24] = 10 ** -10 */
        .quad 0xAFEBFF0BCB24AAFF        /* msw_bsr2div[25] = 10 ** -11 */
        .quad 0xAFEBFF0BCB24AAFF        /* msw_bsr2div[26] = 10 ** -11 */
        .quad 0xAFEBFF0BCB24AAFF        /* msw_bsr2div[27] = 10 ** -11 */
        .quad 0x8CBCCC096F5088CC        /* msw_bsr2div[28] = 10 ** -12 */
        .quad 0x8CBCCC096F5088CC        /* msw_bsr2div[29] = 10 ** -12 */
        .quad 0x8CBCCC096F5088CC        /* msw_bsr2div[30] = 10 ** -12 */
        .quad 0x8CBCCC096F5088CC        /* msw_bsr2div[31] = 10 ** -12 */

        .align 32
        .type msw_bsr2shr, @object
        .size msw_bsr2shr, 32
msw_bsr2shr:
        .byte 9         /* msw_bsr2shr[0] */
        .byte 9         /* msw_bsr2shr[1] */
        .byte 13        /* msw_bsr2shr[2] */
        .byte 13        /* msw_bsr2shr[3] */
        .byte 13        /* msw_bsr2shr[4] */
        .byte 16        /* msw_bsr2shr[5] */
        .byte 16        /* msw_bsr2shr[6] */
        .byte 16        /* msw_bsr2shr[7] */
        .byte 19        /* msw_bsr2shr[8] */
        .byte 19        /* msw_bsr2shr[9] */
        .byte 19        /* msw_bsr2shr[10] */
        .byte 19        /* msw_bsr2shr[11] */
        .byte 23        /* msw_bsr2shr[12] */
        .byte 23        /* msw_bsr2shr[13] */
        .byte 23        /* msw_bsr2shr[14] */
        .byte 26        /* msw_bsr2shr[15] */
        .byte 26        /* msw_bsr2shr[16] */
        .byte 26        /* msw_bsr2shr[17] */
        .byte 29        /* msw_bsr2shr[18] */
        .byte 29        /* msw_bsr2shr[19] */
        .byte 29        /* msw_bsr2shr[20] */
        .byte 29        /* msw_bsr2shr[21] */
        .byte 33        /* msw_bsr2shr[22] */
        .byte 33        /* msw_bsr2shr[23] */
        .byte 33        /* msw_bsr2shr[24] */
        .byte 36        /* msw_bsr2shr[25] */
        .byte 36        /* msw_bsr2shr[26] */
        .byte 36        /* msw_bsr2shr[27] */
        .byte 39        /* msw_bsr2shr[28] */
        .byte 39        /* msw_bsr2shr[29] */
        .byte 39        /* msw_bsr2shr[30] */
        .byte 39        /* msw_bsr2shr[31] */

        .align 32
        .type msw_bsr2exp, @object
        .size msw_bsr2exp, 128
msw_bsr2exp:
        .long 3         /* msw_bsr2exp[0] */
        .long 3         /* msw_bsr2exp[1] */
        .long 4         /* msw_bsr2exp[2] */
        .long 4         /* msw_bsr2exp[3] */
        .long 4         /* msw_bsr2exp[4] */
        .long 5         /* msw_bsr2exp[5] */
        .long 5         /* msw_bsr2exp[6] */
        .long 5         /* msw_bsr2exp[7] */
        .long 6         /* msw_bsr2exp[8] */
        .long 6         /* msw_bsr2exp[9] */
        .long 6         /* msw_bsr2exp[10] */
        .long 6         /* msw_bsr2exp[11] */
        .long 7         /* msw_bsr2exp[12] */
        .long 7         /* msw_bsr2exp[13] */
        .long 7         /* msw_bsr2exp[14] */
        .long 8         /* msw_bsr2exp[15] */
        .long 8         /* msw_bsr2exp[16] */
        .long 8         /* msw_bsr2exp[17] */
        .long 9         /* msw_bsr2exp[18] */
        .long 9         /* msw_bsr2exp[19] */
        .long 9         /* msw_bsr2exp[20] */
        .long 9         /* msw_bsr2exp[21] */
        .long 10        /* msw_bsr2exp[22] */
        .long 10        /* msw_bsr2exp[23] */
        .long 10        /* msw_bsr2exp[24] */
        .long 11        /* msw_bsr2exp[25] */
        .long 11        /* msw_bsr2exp[26] */
        .long 11        /* msw_bsr2exp[27] */
        .long 12        /* msw_bsr2exp[28] */
        .long 12        /* msw_bsr2exp[29] */
        .long 12        /* msw_bsr2exp[30] */
        .long 12        /* msw_bsr2exp[31] */

        .align 32
        .type msw_exp2mul, @object
        .size msw_exp2mul, 104
msw_exp2mul:
        .zero 24                /* msw_exp2mul[i], i < 3, is undefined */
        .quad 1000              /* msw_exp2mul[3] */
        .quad 10000             /* msw_exp2mul[4] */
        .quad 100000            /* msw_exp2mul[5] */
        .quad 1000000           /* msw_exp2mul[6] */
        .quad 10000000          /* msw_exp2mul[7] */
        .quad 100000000         /* msw_exp2mul[8] */
        .quad 1000000000        /* msw_exp2mul[9] */
        .quad 10000000000       /* msw_exp2mul[10] */
        .quad 100000000000      /* msw_exp2mul[11] */
        .quad 1000000000000     /* msw_exp2mul[12] */

        .align 32
        .type msw_exp2div, @object
        .size msw_exp2div, 96
msw_exp2div:
        .zero 24                        /* msw_exp2div[i], i < 3 */
        .quad 0x83126E978D4FDF3C        /* msw_exp2div[3]  = 10 ** -3 */
        .quad 0xD1B71758E219652C        /* msw_exp2div[4]  = 10 ** -4 */
        .quad 0xA7C5AC471B478424        /* msw_exp2div[5]  = 10 ** -5 */
        .quad 0x8637BD05AF6C69B6        /* msw_exp2div[6]  = 10 ** -6 */
        .quad 0xD6BF94D5E57A42BD        /* msw_exp2div[7]  = 10 ** -7 */
        .quad 0xABCC77118461CEFD        /* msw_exp2div[8]  = 10 ** -8 */
        .quad 0x89705F4136B4A598        /* msw_exp2div[9]  = 10 ** -9 */
        .quad 0xDBE6FECEBDEDD5BF        /* msw_exp2div[10] = 10 ** -10 */
        .quad 0xAFEBFF0BCB24AAFF        /* msw_exp2div[11] = 10 ** -11 */

        .align 32
        .type msw_exp2shr, @object
        .size msw_exp2shr, 12
msw_exp2shr:
        .zero 3         /* msw_exp2shr[i], i < 3, is undefined */
        .byte 9         /* msw_exp2shr[3] */
        .byte 13        /* msw_exp2shr[4] */
        .byte 16        /* msw_exp2shr[5] */
        .byte 19        /* msw_exp2shr[6] */
        .byte 23        /* msw_exp2shr[7] */
        .byte 26        /* msw_exp2shr[8] */
        .byte 29        /* msw_exp2shr[9] */
        .byte 33        /* msw_exp2shr[10] */
        .byte 36        /* msw_exp2shr[11] */

        .align 32
        .type lsw_bsr2mul, @object
        .size lsw_bsr2mul, 92
lsw_bsr2mul:
        .long 1000000           /* lsw_bsr2mul[0] */
        .long 1000000           /* lsw_bsr2mul[1] */
        .long 1000000           /* lsw_bsr2mul[2] */
        .long 100000            /* lsw_bsr2mul[3] */
        .long 100000            /* lsw_bsr2mul[4] */
        .long 100000            /* lsw_bsr2mul[5] */
        .long 10000             /* lsw_bsr2mul[6] */
        .long 10000             /* lsw_bsr2mul[7] */
        .long 10000             /* lsw_bsr2mul[8] */
        .long 1000              /* lsw_bsr2mul[9] */
        .long 1000              /* lsw_bsr2mul[10] */
        .long 1000              /* lsw_bsr2mul[11] */
        .long 1000              /* lsw_bsr2mul[12] */
        .long 100               /* lsw_bsr2mul[13] */
        .long 100               /* lsw_bsr2mul[14] */
        .long 100               /* lsw_bsr2mul[15] */
        .long 10                /* lsw_bsr2mul[16] */
        .long 10                /* lsw_bsr2mul[17] */
        .long 10                /* lsw_bsr2mul[18] */
        .long 1                 /* lsw_bsr2mul[19] */
        .long 1                 /* lsw_bsr2mul[20] */
        .long 1                 /* lsw_bsr2mul[21] */
        .long 1                 /* lsw_bsr2mul[22] */

        .align 32
        .type lsw_bsr2div, @object
        .size lsw_bsr2div, 128
lsw_bsr2div:
        .zero 92                /* lsw_bsr2div[i], i < 23, is undefined */
        .long 0xCCCCCCCD        /* lsw_bsr2div[23] = (10 ** -1 << 35) + 1 */
        .long 0xCCCCCCCD        /* lsw_bsr2div[24] */
        .long 0xCCCCCCCD        /* lsw_bsr2div[25] */
        .long 0xCCCCCCCD        /* lsw_bsr2div[26] */
        .long 0xA3D70A3E        /* lsw_bsr2div[27] = (10 ** -2 << 38) + 1 */
        .long 0xA3D70A3E        /* lsw_bsr2div[28] */
        .long 0xA3D70A3E        /* lsw_bsr2div[29] */
        .long 0x83126E98        /* lsw_bsr2div[30] = (10 ** -3 << 41) + 1 */
        .long 0x83126E98        /* lsw_bsr2div[31] */

        .align 32
        .type lsw_bsr2shr, @object
        .size lsw_bsr2shr, 32
lsw_bsr2shr:
        .zero 23        /* lsw_bsr2shr[i], i < 23, is undefined */
        .byte 3         /* lsw_bsr2shr[23] */
        .byte 3         /* lsw_bsr2shr[24] */
        .byte 3         /* lsw_bsr2shr[25] */
        .byte 3         /* lsw_bsr2shr[26] */
        .byte 6         /* lsw_bsr2shr[27] */
        .byte 6         /* lsw_bsr2shr[28] */
        .byte 6         /* lsw_bsr2shr[29] */
        .byte 9         /* lsw_bsr2shr[30] */
        .byte 9         /* lsw_bsr2shr[31] */

        .align 32
        .type lsw_bsr2exp, @object
        .size lsw_bsr2exp, 128
lsw_bsr2exp:
        .long -6        /* lsw_bsr2exp[0] */
        .long -6        /* lsw_bsr2exp[1] */
        .long -6        /* lsw_bsr2exp[2] */
        .long -5        /* lsw_bsr2exp[3] */
        .long -5        /* lsw_bsr2exp[4] */
        .long -5        /* lsw_bsr2exp[5] */
        .long -4        /* lsw_bsr2exp[6] */
        .long -4        /* lsw_bsr2exp[7] */
        .long -4        /* lsw_bsr2exp[8] */
        .long -3        /* lsw_bsr2exp[9] */
        .long -3        /* lsw_bsr2exp[10] */
        .long -3        /* lsw_bsr2exp[11] */
        .long -3        /* lsw_bsr2exp[12] */
        .long -2        /* lsw_bsr2exp[13] */
        .long -2        /* lsw_bsr2exp[14] */
        .long -2        /* lsw_bsr2exp[15] */
        .long -1        /* lsw_bsr2exp[16] */
        .long -1        /* lsw_bsr2exp[17] */
        .long -1        /* lsw_bsr2exp[18] */
        .long 0         /* lsw_bsr2exp[19] */
        .long 0         /* lsw_bsr2exp[20] */
        .long 0         /* lsw_bsr2exp[21] */
        .long 0         /* lsw_bsr2exp[22] */
        .long 1         /* lsw_bsr2exp[23] */
        .long 1         /* lsw_bsr2exp[24] */
        .long 1         /* lsw_bsr2exp[25] */
        .long 1         /* lsw_bsr2exp[26] */
        .long 2         /* lsw_bsr2exp[27] */
        .long 2         /* lsw_bsr2exp[28] */
        .long 2         /* lsw_bsr2exp[29] */
        .long 3         /* lsw_bsr2exp[30] */
        .long 3         /* lsw_bsr2exp[31] */

        .align 32
        .type lsw_exp2mul, @object
        .size lsw_exp2mul, 16
lsw_exp2mul:
        .long 1         /* lsw_exp2mul[0] */
        .long 10        /* lsw_exp2mul[1] */
        .long 100       /* lsw_exp2mul[2] */
        .long 1000      /* lsw_exp2mul[3] */
        .long 10000     /* lsw_exp2mul[4] */
        .long 100000    /* lsw_exp2mul[5] */
        .long 1000000   /* lsw_exp2mul[6] */

        .align 32
        .type lsw_exp2div, @object
        .size lsw_exp2div, 16
lsw_exp2div:
        .long 0                 /* lsw_exp2div[0] is undefined */
        .long 0xCCCCCCCD        /* lsw_exp2div[1] = 10 ** -1 */
        .long 0xA3D70A3E        /* lsw_exp2div[2] = 10 ** -2 */
        .long 0x83126E98        /* lsw_exp2div[3] = 10 ** -3 */
        .long 0xD1B71759        /* lsw_exp2div[4] = 10 ** -4 */
        .long 0xA7C5AC48        /* lsw_exp2div[5] = 10 ** -5 */
        .long 0x8637BD06        /* lsw_exp2div[6] = 10 ** -6 */

        .align 32
        .type lsw_exp2shr, @object
        .size lsw_exp2shr, 4
lsw_exp2shr:
        .byte 0         /* lsw_exp2shr[0] is undefined */
        .byte 3         /* lsw_exp2shr[1] */
        .byte 6         /* lsw_exp2shr[2] */
        .byte 9         /* lsw_exp2shr[3] */
        .byte 13        /* lsw_exp2shr[4] */
        .byte 16        /* lsw_exp2shr[5] */
        .byte 19        /* lsw_exp2shr[6] */
