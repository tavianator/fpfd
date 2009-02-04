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
        shlq %rcx                       /* rax *= 2 */
        leaq (%rax,%rax,4), %rax        /* rax *= 5 */
        subl $1, %r8d
.Lrhscmp:
        cmpq %rcx, %rdx
        jae .Lswap
        shlq %rcx                       /* rax *= 2 */
        leaq (%rdx,%rdx,4), %rdx        /* rdx *= 5 */
        subl $1, %r9d
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
        addq %rax, %rdx
        jmp .Lrem
.Lsubdiv:
        subq %rax, %rdx
.Lrem:
        movq %rdx, (%rdi)
        movl %r9d, 8(%rdi)
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
        .quad 1                         /* bsr2mul[62] = 10 ** 0 */

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
