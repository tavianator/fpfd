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

/* unsigned int fpfd32_impl_addsub(fpfd32_impl_t *dest, int sign,
                                   const fpfd32_impl_t *lhs,
                                   const fpfd32_impl_t *rhs); */

/*
 * Add lhs and rhs if sign == 1, or subtract lhs and rhs if sign == -1, and
 * store the result in dest.
 */

        .text
.globl fpfd32_impl_addsub
        .type fpfd32_impl_addsub, @function
fpfd32_impl_addsub:
        movq %rdx, %r10         /* Put lhs in r10 */
        movq %rcx, %r11         /* Put rhs in r11 */
        xorl 12(%r11), %esi     /* esi = sign ^ rhs->fields.sign */
        xorl $1, %esi           /* Find the effective sign of rhs
                                   (sign * rhs->fields.sign) */
        movq (%r10), %rax       /* Put lhs->mant in rax */
        movq (%r11), %rdx       /* Put rhs->mant in rdx */
        bsrq %rax, %r8
        bsrq %rdx, %r9
        leaq bsr2mul(%rip), %rcx        /* For position-independence */
        imulq (%rcx,%r8,8), %rax
        imulq (%rcx,%r9,8), %rdx        /* Scale rax and rdx to be
                                           >= 10 ** 18 */
        leaq bsr2exp(%rip), %rcx
        movl (%rcx,%r8,4), %r8d
        movl (%rcx,%r9,4), %r9d
        addl 8(%r10), %r8d
        addl 8(%r11), %r9d      /* Correct the exponents */
        movq $1000000000000000000, %rcx
        cmpq %rcx, %rax         /* See if we need one more multiplication by
                                   10 */
        jae .Lrhscmp
        shlq %rax                       /* rax *= 2 */
        leaq (%rax,%rax,4), %rax        /* rax *= 5 */
        subl $1, %r8d           /* Correct the exponent */
.Lrhscmp:
        cmpq %rcx, %rdx
        jae .Lswap
        shlq %rdx                       /* rdx *= 2 */
        leaq (%rdx,%rdx,4), %rdx        /* rdx *= 5 */
        subl $1, %r9d           /* Correct the exponent */
.Lswap:
        movl 12(%r10), %r10d
        movl %r10d, %r11d
        xorl %esi, %r11d        /* r11d = esi ^ lhs->fields.sign */
        movl %r9d, %ecx
        subl %r8d, %ecx         /* Subtract the exponents */
        jns .Lnoswap
        /* If r8d > r9d, swap rax and rdx, and put r8d in r9d */
        xchgq %rax, %rdx
        movl %r8d, %r9d
        negl %ecx               /* Re-calculate ecx */
        movl %r10d, %esi        /* r10d is the resultant sign */
.Lnoswap:
        testl %r11d, %r11d
        jnz .Lsubdiv            /* If r11d == 0, we are adding the mantissas.
                                   Otherwise, we are subtracting. */
        cmpl $19, %ecx
        jg .Ladddivtoofar       /* Test for an exponent difference > 19
                                   ( == 19 is handled by the following code) */
        testl %ecx, %ecx
        jz .Laddnodiv           /* Test for a zero exponent difference */
        movq %rax, %r10
        movq %rdx, %r11         /* Put rax and rdx in r10 and r11,
                                   respectively */
        movl %ecx, %r8d         /* Save our exponent difference in r8 */
        leaq exp2div(%rip), %rdx
        mulq (%rdx,%r8,8)
        leaq exp2shr(%rip), %rcx
        movb (%rcx,%r8,1), %cl
        shrq %cl, %rdx          /* Divide rax by the appropriate power of 10 */
        addq %rdx, %r11         /* Add the mantissas */
        jc .Laddcarry           /* Test for carry; this shouldn't happen */
        leaq exp2mul(%rip), %rax
        imulq (%rax,%r8,8), %rdx
        subq %rdx, %r10         /* Calculate the remainder */
        subl $1, %r8d
        movq %r10, %rax
        movq %r11, %rdx
        jz .Lrem                /* If r8d == 1, we are done */
        leaq exp2div(%rip), %rdx
        mulq (%rdx,%r8,8)
        leaq exp2shr(%rip), %rcx
        movb (%rcx,%r8,1), %cl
        shrq %cl, %rdx          /* Find the first digit of the remainder */
        movl %edx, %eax
        movq %r11, %rdx
        testl %eax, %eax
        jz .Laddspecial
        cmpl $5, %eax
        jne .Lrem
.Laddspecial:
        movl %eax, %ecx
        leaq exp2mul(%rip), %rdx
        imulq (%rdx,%r8,8), %rax
        subl %eax, %r10d
        jz .Laddspecial1
        addl $1, %ecx
.Laddspecial1:
        movl %ecx, %eax
        movq %r11, %rdx
        jmp .Lrem
.Ladddivtoofar:
        movl $1, %eax
        jmp .Lrem
.Laddnodiv:
        addq %rax, %rdx
        jc .Laddnodivcarry
        xorl %eax, %eax
        jmp .Lrem
.Laddcarry:
        /* This should never happen, but we test for it anyway. */
        movq %rdx, %rcx
        movq $0x199999999999999A, %rax
        mulq %r11
        movq $0x199999999999999A, %rax
        addq %rax, %rdx         /* Divide the sum by ten */
        leaq (%rdx,%rdx,4), %rax
        shlq %rax
        subq %rax, %r11
        movq %r11, %rax         /* Calculate the remainder */
        jns .Laddcarrynoadj
        subq $1, %rdx
        addl $10, %eax
.Laddcarrynoadj:
        addl $1, %r9d           /* Correct the exponent */
        testl %eax, %eax
        jz .Laddcarryspecial
        cmpl $5, %eax
        jne .Lrem
.Laddcarryspecial:
        movq %rdx, %r11
        leaq exp2mul(%rip), %rdx
        imulq (%rdx,%r8,8), %rcx
        subq %rcx, %r10         /* Calculate the remainder */
        movq %r11, %rdx
        jz .Lrem
        addl $1, %eax
        jmp .Lrem
.Laddnodivcarry:
        /* This should never happen, but we test for it anyway. */
        movq %rdx, %r11
        movq %rdx, %rax
        movq $0x199999999999999A, %rcx
        mulq %rcx
        addq %rcx, %rdx         /* Divide by ten */
        leaq (%rdx,%rdx,4), %rax
        shlq %rax
        subq %rax, %r11
        movq %r11, %rax         /* Calculate the remainder */
        jns .Laddnodivcarrynoadj
        subq $1, %rdx
        addl $10, %eax
.Laddnodivcarrynoadj:
        addl $1, %r9d           /* Correct the exponent */
        jmp .Lrem
.Lsubdiv:
        cmpl $19, %ecx
        jg .Lsubdivtoofar       /* Test for an exponent difference > 19
                                   ( == 19 is handled by the following code) */
        testl %ecx, %ecx
        jz .Lsubnodiv           /* Test for a zero exponent difference */
        movq %rax, %r10
        movq %rdx, %r11         /* Put rax and rdx in r10 and r11,
                                   respectively */
        movl %ecx, %r8d         /* Save our exponent difference in r8 */
        leaq exp2div(%rip), %rdx
        mulq (%rdx,%r8,8)
        leaq exp2shr(%rip), %rcx
        movb (%rcx,%r8,1), %cl
        shrq %cl, %rdx          /* Divide rax by the appropriate power of 10 */
        subq %rdx, %r11         /* Subtract the mantissas */
        jc .Lsubborrow
        leaq exp2mul(%rip), %rax
        movq (%rax,%r8,8), %rax
        imulq %rax, %rdx
        subq %rdx, %r10         /* Calculate the remainder */
        jz .Lsubrem
        subq $1, %r11
        jnc .Lsubnoborrow
        negl %esi
        movq %r10, %r11
        xorl %r10d, %r10d
        subl $1, %r9d           /* Correct the exponent */
        jmp .Lsubrem
.Lsubnoborrow:
        subq %r10, %rax         /* Subtract the remainder from 1.0 */
        movq %rax, %r10
        movq $1000000000000000000, %rcx
        cmpq %rcx, %r11         /* See if we need to reclaim significant digits
                                   from the remainder */
        jae .Lsubrem
        shlq %r11                       /* r11 *= 2 */
        leaq (%r11,%r11,4), %r11        /* r11 *= 5 */
        addq %r10, %r11
        xorl %r10d, %r10d
        subl $1, %r9d           /* Correct the exponent */
.Lsubrem:
        subl $1, %r8d
        movq %r10, %rax
        movq %r11, %rdx
        jz .Lrem                /* If r8d == 0, we are done */
        leaq exp2div(%rip), %rdx
        mulq (%rdx,%r8,8)
        leaq exp2shr(%rip), %rcx
        movb (%rcx,%r8,1), %cl
        shrq %cl, %rdx          /* Find the first digit of the remainder */
        movl %edx, %eax
        movq %r11, %rdx
        testl %eax, %eax
        jz .Lsubspecial
        cmpl $5, %eax
        jne .Lrem
.Lsubspecial:
        movl %eax, %ecx
        leaq exp2mul(%rip), %rdx
        imulq (%rdx,%r8,8), %rax
        subl %eax, %r10d
        jz .Lsubspecial1
        addl $1, %ecx
.Lsubspecial1:
        movl %ecx, %eax
        movq %r11, %rdx
        jmp .Lrem
.Lsubborrow:
        negq %r11
        negl %esi
        leaq exp2mul(%rip), %rax
        imulq (%rax,%r8,8), %rdx
        subq %rdx, %r10         /* Calculate the remainder */
        jz .Lsubborrow1
        movq $1000000000000000000, %rcx
        cmpq %rcx, %r11         /* See if we need to reclaim significant digits
                                   from the remainder */
        jae .Lsubborrow1
        shlq %r11                       /* r11 *= 2 */
        leaq (%r11,%r11,4), %r11        /* r11 *= 5 */
        addq %r10, %r11
        xorl %r10d, %r10d
        subl $1, %r9d           /* Correct the exponent */
.Lsubborrow1:
        movq %r11, %rdx
        movl %r10d, %eax
        jmp .Lrem
.Lsubdivtoofar:
        subq $1, %rdx
        jmp .Lrem
.Lsubnodiv:
        subq %rax, %rdx
        movl $0, %eax
        jnc .Lrem
        negq %rdx
        negl %esi
.Lrem:
        movq %rdx, (%rdi)
        movl %r9d, 8(%rdi)
        movl %esi, 12(%rdi)
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub

        .section .rodata
        .align 64
        .type bsr2mul, @object
        .size bsr2mul, 512
bsr2mul:
        .quad 1000000000000000000       /* bsr2mul[0]  = 10 ** 18 */
        .quad 1000000000000000000       /* bsr2mul[1]  = 10 ** 18 */
        .quad 1000000000000000000       /* bsr2mul[2]  = 10 ** 18 */
        .quad 100000000000000000        /* bsr2mul[3]  = 10 ** 17 */
        .quad 100000000000000000        /* bsr2mul[4]  = 10 ** 17 */
        .quad 100000000000000000        /* bsr2mul[5]  = 10 ** 17 */
        .quad 10000000000000000         /* bsr2mul[6]  = 10 ** 16 */
        .quad 10000000000000000         /* bsr2mul[7]  = 10 ** 16 */
        .quad 10000000000000000         /* bsr2mul[8]  = 10 ** 16 */
        .quad 1000000000000000          /* bsr2mul[9]  = 10 ** 15 */
        .quad 1000000000000000          /* bsr2mul[10] = 10 ** 15 */
        .quad 1000000000000000          /* bsr2mul[11] = 10 ** 15 */
        .quad 1000000000000000          /* bsr2mul[12] = 10 ** 15 */
        .quad 100000000000000           /* bsr2mul[13] = 10 ** 14 */
        .quad 100000000000000           /* bsr2mul[14] = 10 ** 14 */
        .quad 100000000000000           /* bsr2mul[15] = 10 ** 14 */
        .quad 10000000000000            /* bsr2mul[16] = 10 ** 13 */
        .quad 10000000000000            /* bsr2mul[17] = 10 ** 13 */
        .quad 10000000000000            /* bsr2mul[18] = 10 ** 13 */
        .quad 1000000000000             /* bsr2mul[19] = 10 ** 12 */
        .quad 1000000000000             /* bsr2mul[20] = 10 ** 12 */
        .quad 1000000000000             /* bsr2mul[21] = 10 ** 12 */
        .quad 1000000000000             /* bsr2mul[22] = 10 ** 12 */
        .quad 100000000000              /* bsr2mul[23] = 10 ** 11 */
        .quad 100000000000              /* bsr2mul[24] = 10 ** 11 */
        .quad 100000000000              /* bsr2mul[25] = 10 ** 11 */
        .quad 10000000000               /* bsr2mul[26] = 10 ** 10 */
        .quad 10000000000               /* bsr2mul[27] = 10 ** 10 */
        .quad 10000000000               /* bsr2mul[28] = 10 ** 10 */
        .quad 1000000000                /* bsr2mul[29] = 10 ** 9 */
        .quad 1000000000                /* bsr2mul[30] = 10 ** 9 */
        .quad 1000000000                /* bsr2mul[31] = 10 ** 9 */
        .quad 1000000000                /* bsr2mul[32] = 10 ** 9 */
        .quad 100000000                 /* bsr2mul[33] = 10 ** 8 */
        .quad 100000000                 /* bsr2mul[34] = 10 ** 8 */
        .quad 100000000                 /* bsr2mul[35] = 10 ** 8 */
        .quad 10000000                  /* bsr2mul[36] = 10 ** 7 */
        .quad 10000000                  /* bsr2mul[37] = 10 ** 7 */
        .quad 10000000                  /* bsr2mul[38] = 10 ** 7 */
        .quad 1000000                   /* bsr2mul[39] = 10 ** 6 */
        .quad 1000000                   /* bsr2mul[40] = 10 ** 6 */
        .quad 1000000                   /* bsr2mul[41] = 10 ** 6 */
        .quad 1000000                   /* bsr2mul[42] = 10 ** 6 */
        .quad 100000                    /* bsr2mul[43] = 10 ** 5 */
        .quad 100000                    /* bsr2mul[44] = 10 ** 5 */
        .quad 100000                    /* bsr2mul[45] = 10 ** 5 */
        .quad 10000                     /* bsr2mul[46] = 10 ** 4 */
        .quad 10000                     /* bsr2mul[47] = 10 ** 4 */
        .quad 10000                     /* bsr2mul[48] = 10 ** 4 */
        .quad 1000                      /* bsr2mul[49] = 10 ** 3 */
        .quad 1000                      /* bsr2mul[50] = 10 ** 3 */
        .quad 1000                      /* bsr2mul[51] = 10 ** 3 */
        .quad 1000                      /* bsr2mul[52] = 10 ** 3 */
        .quad 100                       /* bsr2mul[53] = 10 ** 2 */
        .quad 100                       /* bsr2mul[54] = 10 ** 2 */
        .quad 100                       /* bsr2mul[55] = 10 ** 2 */
        .quad 10                        /* bsr2mul[56] = 10 ** 1 */
        .quad 10                        /* bsr2mul[57] = 10 ** 1 */
        .quad 10                        /* bsr2mul[58] = 10 ** 1 */
        .quad 1                         /* bsr2mul[59] = 10 ** 0 */
        .quad 1                         /* bsr2mul[60] = 10 ** 0 */
        .quad 1                         /* bsr2mul[61] = 10 ** 0 */
        .quad 1                         /* bsr2mul[62] = 10 ** 0 */
        .quad 1                         /* bsr2mul[63] = 10 ** 0 */

        .align 32
        .type bsr2exp, @object
        .size bsr2exp, 256
bsr2exp:
        .long -18       /* bsr2exp[0] */
        .long -18       /* bsr2exp[1] */
        .long -18       /* bsr2exp[2] */
        .long -17       /* bsr2exp[3] */
        .long -17       /* bsr2exp[4] */
        .long -17       /* bsr2exp[5] */
        .long -16       /* bsr2exp[6] */
        .long -16       /* bsr2exp[7] */
        .long -16       /* bsr2exp[8] */
        .long -15       /* bsr2exp[9] */
        .long -15       /* bsr2exp[10] */
        .long -15       /* bsr2exp[11] */
        .long -15       /* bsr2exp[12] */
        .long -14       /* bsr2exp[13] */
        .long -14       /* bsr2exp[14] */
        .long -14       /* bsr2exp[15] */
        .long -13       /* bsr2exp[16] */
        .long -13       /* bsr2exp[17] */
        .long -13       /* bsr2exp[18] */
        .long -12       /* bsr2exp[19] */
        .long -12       /* bsr2exp[20] */
        .long -12       /* bsr2exp[21] */
        .long -12       /* bsr2exp[22] */
        .long -11       /* bsr2exp[23] */
        .long -11       /* bsr2exp[24] */
        .long -11       /* bsr2exp[25] */
        .long -10       /* bsr2exp[26] */
        .long -10       /* bsr2exp[27] */
        .long -10       /* bsr2exp[28] */
        .long -10       /* bsr2exp[29] */
        .long -9        /* bsr2exp[30] */
        .long -9        /* bsr2exp[31] */
        .long -9        /* bsr2exp[32] */
        .long -8        /* bsr2exp[33] */
        .long -8        /* bsr2exp[34] */
        .long -8        /* bsr2exp[35] */
        .long -7        /* bsr2exp[36] */
        .long -7        /* bsr2exp[37] */
        .long -7        /* bsr2exp[38] */
        .long -6        /* bsr2exp[39] */
        .long -6        /* bsr2exp[40] */
        .long -6        /* bsr2exp[41] */
        .long -6        /* bsr2exp[42] */
        .long -5        /* bsr2exp[43] */
        .long -5        /* bsr2exp[44] */
        .long -5        /* bsr2exp[45] */
        .long -4        /* bsr2exp[46] */
        .long -4        /* bsr2exp[47] */
        .long -4        /* bsr2exp[48] */
        .long -3        /* bsr2exp[49] */
        .long -3        /* bsr2exp[50] */
        .long -3        /* bsr2exp[51] */
        .long -3        /* bsr2exp[52] */
        .long -2        /* bsr2exp[53] */
        .long -2        /* bsr2exp[54] */
        .long -2        /* bsr2exp[55] */
        .long -1        /* bsr2exp[56] */
        .long -1        /* bsr2exp[57] */
        .long -1        /* bsr2exp[58] */
        .long 0         /* bsr2exp[59] */
        .long 0         /* bsr2exp[60] */
        .long 0         /* bsr2exp[61] */
        .long 0         /* bsr2exp[62] */
        .long 0         /* bsr2exp[63] */

        .align 64
        .type exp2div, @object
        .size exp2div, 160
exp2div:
        .quad 0                         /* exp2div[0] is undefined */
        .quad 0xCCCCCCCCCCCCCCCD        /* exp2div[1]  = 10 ** -1 */
        .quad 0xA3D70A3D70A3D70B        /* exp2div[2]  = 10 ** -2 */
        .quad 0x83126E978D4FDF3C        /* exp2div[3]  = 10 ** -3 */
        .quad 0xD1B71758E219652C        /* exp2div[4]  = 10 ** -4 */
        .quad 0xA7C5AC471B478424        /* exp2div[5]  = 10 ** -5 */
        .quad 0x8637BD05AF6C69B6        /* exp2div[6]  = 10 ** -6 */
        .quad 0xD6BF94D5E57A42BD        /* exp2div[7]  = 10 ** -7 */
        .quad 0xABCC77118461CEFD        /* exp2div[8]  = 10 ** -8 */
        .quad 0x89705F4136B4A598        /* exp2div[9]  = 10 ** -9 */
        .quad 0xDBE6FECEBDEDD5BF        /* exp2div[10] = 10 ** -10 */
        .quad 0xAFEBFF0BCB24AAFF        /* exp2div[11] = 10 ** -11 */
        .quad 0x8CBCCC096F5088CC        /* exp2div[12] = 10 ** -12 */
        .quad 0xE12E13424BB40E14        /* exp2div[13] = 10 ** -13 */
        .quad 0xB424DC35095CD810        /* exp2div[14] = 10 ** -14 */
        .quad 0x901D7CF73AB0ACDA        /* exp2div[15] = 10 ** -15 */
        .quad 0xE69594BEC44DE15C        /* exp2div[16] = 10 ** -16 */
        .quad 0xB877AA3236A4B44A        /* exp2div[17] = 10 ** -17 */
        .quad 0x9392EE8E921D5D07        /* exp2div[18] = 10 ** -18 */
        .quad 0xEC1E4A7DB69561A5        /* exp2div[19] = 10 ** -19 */

        .align 32
        .type exp2shr, @object
        .size exp2shr, 20
exp2shr:
        .byte 0         /* exp2shr[0] is undefined */
        .byte 3         /* exp2shr[1] */
        .byte 6         /* exp2shr[2] */
        .byte 9         /* exp2shr[3] */
        .byte 13        /* exp2shr[4] */
        .byte 16        /* exp2shr[5] */
        .byte 19        /* exp2shr[6] */
        .byte 23        /* exp2shr[7] */
        .byte 26        /* exp2shr[8] */
        .byte 29        /* exp2shr[9] */
        .byte 33        /* exp2shr[10] */
        .byte 36        /* exp2shr[11] */
        .byte 39        /* exp2shr[12] */
        .byte 43        /* exp2shr[13] */
        .byte 46        /* exp2shr[14] */
        .byte 49        /* exp2shr[15] */
        .byte 53        /* exp2shr[16] */
        .byte 56        /* exp2shr[17] */
        .byte 59        /* exp2shr[18] */
        .byte 63        /* exp2shr[19] */

        .align 64
        .type exp2mul, @object
        .size exp2mul, 160
exp2mul:
        .quad 1                         /* esp2mul[0] */
        .quad 10                        /* esp2mul[1] */
        .quad 100                       /* esp2mul[2] */
        .quad 1000                      /* esp2mul[3] */
        .quad 10000                     /* esp2mul[4] */
        .quad 100000                    /* esp2mul[5] */
        .quad 1000000                   /* esp2mul[6] */
        .quad 10000000                  /* esp2mul[7] */
        .quad 100000000                 /* esp2mul[8] */
        .quad 1000000000                /* esp2mul[9] */
        .quad 10000000000               /* esp2mul[10] */
        .quad 100000000000              /* esp2mul[11] */
        .quad 1000000000000             /* esp2mul[12] */
        .quad 10000000000000            /* esp2mul[13] */
        .quad 100000000000000           /* esp2mul[14] */
        .quad 1000000000000000          /* esp2mul[15] */
        .quad 10000000000000000         /* esp2mul[16] */
        .quad 100000000000000000        /* esp2mul[17] */
        .quad 1000000000000000000       /* esp2mul[18] */
        .quad 10000000000000000000      /* esp2mul[19] */
