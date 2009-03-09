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
        pushl %ebx
        pushl %esi
        pushl %edi
        pushl %ebp              /* Callee-save registers */
        subl $24, %esp
        movl 52(%esp), %esi     /* Put lhs in esi */
        movl 56(%esp), %edi     /* Put rhs in edi */
        movl 48(%esp), %ebx     /* Put sign in ebx */
        xorl 12(%edi), %ebx     /* ebx = sign ^ rhs->fields.sign */
        xorl $1, %ebx           /* Find the effective sign of rhs
                                   (sign * rhs->fields.sign */
        /* We really want ecx = 63 - bsrq((%esi)). But on 32-bit, we have to
           bit-scan the high-order word first, then if that word is zero, scan
           the lower word. */
        bsrl 4(%esi), %ecx
        jz .LlhsMSWzero         /* Test for a zero high-order word */
        subl $31, %ecx
        negl %ecx               /* 63 - bsrq((%esi)) == 31 - bsrl(4(%esi)) */
        jmp .Lbsrrhs            /* Now scan rhs */
.LlhsMSWzero:
        bsrl (%esi), %ecx       /* We assume the mantissa is nonzero */
        subl $63, %ecx
        negl %ecx               /* 63 - bsr */
.Lbsrrhs:
        bsrl 4(%edi), %edx
        jz .LrhsMSWzero         /* Test for a zero high-order word */
        subl $31, %edx
        negl %edx               /* 63 - bsrq((%edi)) == 31 - bsrl(4(%edi)) */
        jmp .Lresexp            /* Now find the resultant exponent */
.LrhsMSWzero:
        bsrl (%edi), %edx       /* We assume the mantissa is nonzero */
        subl $63, %edx
        negl %edx               /* 63 - bsr */
.Lresexp:
        shrl $2, %ecx
        shrl $2, %edx           /* Divide each bit count by 4 (rounding up), and
                                   subtract from 16, to give a leading zero
                                   digit count of lhs and rhs, in ecx and edx,
                                   respectively. */
        movl 12(%esi), %eax
        movl %eax, 20(%esp)     /* Store lhs->fields.sign on the stack; this
                                   will be the resultant sign if we don't flip
                                   our operands. */
        movl %edx, %ebp
        subl %ecx, %ebp
        addl 8(%esi), %ebp
        subl 8(%edi), %ebp      /* ebp = (lhs->fields.exp - leadingzeros(lhs))
                                     - (rhs->fields.exp - leadingzeros(rhs)) */
        jns .Lnoswitch          /* If ebp is positive, lhs gets shifted further
                                   left to line up the digits. If it's negative,
                                   rhs needs to be shifted further. In this
                                   case, we swap lhs and rhs, so that lhs can
                                   always be the one shifted further */
        movl %ebx, 20(%esp)     /* esi will be our resultant sign */
        xchgl %esi, %edi        /* Swap our lhs and rhs pointers */
        xchgl %ecx, %edx        /* Swap our leading zero digit counts */
        negl %ebp               /* Re-calculate ebp */
.Lnoswitch:
        xorl %eax, %ebx         /* ebx ^= (original lhs)->fields.sign */
        movl 8(%esi), %eax
        movl %eax, 16(%esp)     /* Store lhs->fields.exp, the resultant
                                   exponent, on the stack */
        movl %ecx, 12(%esp)
        movl %edx, 8(%esp)      /* Store ecx and edx on the stack */
        movl (%esi), %eax
        movl 4(%esi), %edx      /* Put lhs->mant in edx:eax */
        leal (,%ecx,4), %ecx    /* ecx *= 4 */
        cmpb $32, %cl           /* Perform a 64-bit shift of edx:eax left by cl
                                   bits, by treating the cases of cl >= 32 and
                                   cl < 32 differently */
        jb .Llhsshld
        subb $32, %cl
        shll %cl, %eax          /* Shift eax left by cl - 32 bits */
        movl %eax, %edx
        xorl %eax, %eax         /* Move eax to edx, and zero eax */
        xorb %cl, %cl           /* Zero the shift count */
.Llhsshld:
        shldl %cl, %eax, %edx
        shll %cl, %eax          /* Shift edx:eax left by cl bits */
        testl %ebx, %ebx
        jnz .Lsubshift          /* If ebx == 0, we are adding digits. If not, we
                                   are subtracting. */
        movl 8(%esp), %ecx
        subl %ebp, %ecx         /* ecx now stores the necessary digit shift
                                   count of rhs */
        movl (%edi), %ebx
        movl 4(%edi), %edi      /* Put lhs->mant in edi:ebx */
        js .Laddshr             /* If ecx is negative, we shift right; otherwise
                                   we shift left */
        movl $0, (%esp)
        movl $0, 4(%esp)        /* Remainder is zero */
        leal (,%ecx,4), %ecx    /* ecx *= 4 */
        cmpb $32, %cl
        jb .Laddrhsshld
        subb $32, %cl
        shldl %cl, %ebx, %ebp
        shll %cl, %ebx          /* Shift ebx left by cl - 32 bits */
        movl %ebx, %edi
        xorl %ebx, %ebx         /* Move ebx to edi, and zero eax */
        xorb %cl, %cl           /* Zero the shift count */
.Laddrhsshld:
        shldl %cl, %ebx, %edi
        shll %cl, %edi          /* Shift edi:ebx left by cl bits */
        jmp .Ladd
.Laddshr:
        negl %ecx
        leal (,%ecx,4), %ecx    /* ecx *= -4 */
        cmpl $64, %ecx
        jae .Laddshrtoofar      /* Check if edi:ebx would be shifted past its
                                   width */
        cmpb $32, %cl
        jb .Laddrhsshrd
        subb $32, %cl
        movl $0, %ebp
        shrdl %cl, %ebx, %ebp
        shrdl %cl, %edi, %ebx
        shrl %cl, %edi          /* Shift edi.ebx:ebp right by cl - 32 bits */
        movl %ebp, (%esp)
        movl %ebx, 4(%esp)      /* Store 0.ebx:ebp as the remainder */
        movl %edi, %ebx
        xorl %edi, %edi         /* Move edi to ebx, and zero edi */
        jmp .Ladd
.Laddrhsshrd:
        movl $0, %ebp
        shrdl %cl, %ebx, %ebp
        shrdl %cl, %edi, %ebx
        shrl %cl, %edi          /* Shift edi:ebx.ebp right by cl bits */
        movl %ebp, 4(%esp)
        movl $0, (%esp)         /* Store 0.ebp as the remainder */
        jmp .Ladd
.Laddshrtoofar:
        movl %ebx, (%esp)
        movl %edi, 4(%esp)      /* Store 0.edi:ebx as the remainder on the
                                   stack in case ecx == 64 */
        je .Lrem
        movl $0x10000000, 4(%esp)       /* If ecx != 64, treat the remainder as
                                           0.1 */
        jmp .Lrem
.Ladd:
        addl $0x66666666, %eax
        addl $0x66666666, %edx
        movl %eax, %ebp
        movl %edx, %esi
        addl %ebx, %eax
        adcl %edi, %edx
        jc .Laddcarry
        xorl %ebx, %ebp
        xorl %edi, %esi
        xorl %eax, %ebp
        xorl %edx, %esi
        notl %ebp
        notl %esi
        andl $0x11111110, %ebp
        andl $0x11111111, %esi
        shrdl $3, %esi, %ebp
        shrl $3, %esi
        leal (%ebp,%ebp,2), %ebp
        leal (%esi,%esi,2), %esi
        subl %ebp, %eax
        subl %esi, %edx
        subl $0x60000000, %edx
        jmp .Lrem
.Laddcarry:
        /* We carried, so shift the digits right by one, saving the falloff in
           edi:ebx, and set the leading digit to 1 */
        xorl %ebx, %ebp
        xorl %edi, %esi
        xorl %eax, %ebp
        xorl %edx, %esi
        notl %ebp
        notl %esi
        andl $0x11111110, %ebp
        andl $0x11111111, %esi
        shrdl $3, %esi, %ebp
        shrl $3, %esi
        leal (%ebp,%ebp,2), %ebp
        leal (%esi,%esi,2), %esi
        subl %ebp, %eax
        subl %esi, %edx
        movl (%esp), %ebx
        movl 4(%esp), %edi      /* Get the previous remainder from the stack,
                                   and store it in edi:ebx */
        shrdl $4, %edi, %ebx
        shrdl $4, %eax, %edi
        shrdl $4, %edx, %eax
        shrl $4, %edx           /* Shift edx:eax.edi:ebx right one digit */
        orl $0x10000000, %edx   /* Set the leading digit to 1 */
        movl %ebx, (%esp)
        movl %edi, 4(%esp)      /* Store 0.edi:ebx as the remainder on the
                                   stack */
        subl $1, 12(%esp)       /* Correct the exponent */
        jmp .Lrem
.Lsubshift:
        movl 8(%esp), %ecx
        subl %ebp, %ecx         /* ecx now stores the necessary digit shift
                                   count of rhs */
        movl (%edi), %ebx
        movl 4(%edi), %edi      /* Put lhs->mant in edi:ebx */
        js .Lsubshr             /* If ecx is negative, we shift right; otherwise
                                   we shift left */
        movl $0, (%esp)
        movl $0, 4(%esp)        /* Remainder is zero */
        leal (,%ecx,4), %ecx    /* ecx *= 4 */
        cmpb $32, %cl
        jb .Lsubrhsshld
        subb $32, %cl
        shldl %cl, %ebx, %ebp
        shll %cl, %ebx          /* Shift ebx left by cl - 32 bits */
        movl %ebx, %edi
        xorl %ebx, %ebx         /* Move ebx to edi, and zero eax */
        xorb %cl, %cl           /* Zero the shift count */
.Lsubrhsshld:
        shldl %cl, %ebx, %edi
        shll %cl, %edi          /* Shift edi:ebx left by cl bits */
        jmp .Lsub
.Lsubshr:
        negl %ecx
        leal (,%ecx,4), %ecx    /* ecx *= -4 */
        cmpl $64, %ecx
        je .Lsubshrjusttoofar
        ja .Lsubshrtoofar
        cmpb $32, %cl
        jb .Lsubrhsshrd
        subb $32, %cl
        movl $0, %ebp
        shrdl %cl, %ebx, %ebp
        shrdl %cl, %edi, %ebx
        shrl %cl, %edi          /* Shift edi:ebx.ebp right by cl - 32 bits */
        movl %ebp, (%esp)
        movl %ebx, 4(%esp)      /* Store 0.ebx:ebp as the remainder */
        movl %edi, %ebx
        xorl %edi, %edi         /* Move edi to ebx, and zero edi */
        jmp .Lsub
.Lsubrhsshrd:
        movl $0, %ebp
        shrdl %cl, %ebx, %ebp
        shrdl %cl, %edi, %ebx
        shrl %cl, %edi          /* Shift edi:ebx.ebp right by cl bits */
        movl $0, (%esp)
        movl %ebp, 4(%esp)
        jmp .Lsub
.Lsubshrjusttoofar:
        /*
         * Shift count == 16. This means we have edx:eax - 0.edi:ebx. So,
         * subtract 0.edi:ebx from 1, and subtract 1 from edx:eax.
         *
         * Subtracting 0.edi:ebx from 1 is equivalent to subtracting the lowest
         * non-zero digit from 10, and all higher digits from 9.
         *
         * Subtracting 1 from edx:eax is equivalent to subtracting, in
         * hexadecimal, 6 from all trailing zero nibbles (if any), and then
         * subtracting 1.
         */
        movl $0x99999999, %esi
        movl $0x9999999A, %ebp  /* Move 0x999999999999999A into esi:ebp */
        bsfl %ebx, %ecx         /* Forward bit scan this time */
        jz .Lsubshrjusttoofar1
        andl $0x1C, %ecx        /* ecx = bsf/4; the trailing zero digit count */
        shldl %cl, %ebp, %esi
        shll %cl, %ebp          /* Shift ...999A left to line up with the first
                                   non-zero digit in edi:ebx */
        jmp .Lsubshrjusttoofar2
.Lsubshrjusttoofar1:
        bsfl %edi, %ecx
        andl $0x1C, %ecx        /* ecx = bsf/4; the trailing zero digit count */
        movl %ebp, %esi
        xorl %ebp, %ebp
        shll %cl, %esi          /* Shift ...999A left to line up with the first
                                   non-zero digit in edi:ebx */
.Lsubshrjusttoofar2:
        subl %ebx, %ebp
        sbbl %edi, %esi         /* Subtract edi:ebx from 0x...9999A000... */
        movl %ebp, (%esp)
        movl %esi, 4(%esp)      /* Store the remainder on the stack */
        movl $0x66666666, %esi
        movl $0x66666666, %ebp  /* Move 0x6666666666666666 into esi:ebp */
        bsfl %eax, %ecx
        jz .Lsubshrjusttoofar3
        andl $0x1C, %ecx        /* ecx = bsf/4; */
        jz .Lsubshrjusttoofar5  /* Test for no trailing zeros */
        subl $64, %ecx
        negl %ecx               /* ecx = 64 - ecx */
        shrdl %cl, %esi, %ebp
        shrl %cl, %esi          /* Shift 0x666... right to line up with the
                                   trailing zeros in edx:eax */
        jmp .Lsubshrjusttoofar4
.Lsubshrjusttoofar3:
        bsfl %edx, %ecx
        andl $0x1C, %ecx        /* ecx = bsf/4; */
        subl $32, %ecx
        negl %ecx               /* ecx = 64 - (ecx + 32) */
        xorl %esi, %esi
        shrl %cl, %ebp          /* Shift 0x666... right to line up with the
                                   trailing zeros in edx:eax */
.Lsubshrjusttoofar4:
        subl %ebp, %eax
        sbbl %esi, %edx         /* Subtract 0x...666 from edx:eax */
.Lsubshrjusttoofar5:
        subl $1, %eax
        sbbl $0, %edx           /* Subtract 1 from edx:eax */
        jmp .Lrem
.Lsubshrtoofar:
        /* Shift count > 16; just subtract one from edx:eax as above, and treat
           the remainder as 0.9 */
        movl $0x66666666, %esi
        movl $0x66666666, %ebp  /* Move 0x6666666666666666 into esi:ebp */
        bsfl %eax, %ecx
        jz .Lsubshrtoofar1
        andl $0x1C, %ecx        /* ecx = bsf/4; */
        jz .Lsubshrtoofar3  /* Test for no trailing zeros */
        subl $64, %ecx
        negl %ecx               /* ecx = 64 - ecx */
        shrdl %cl, %esi, %ebp
        shrl %cl, %esi          /* Shift 0x666... right to line up with the
                                   trailing zeros in edx:eax */
        jmp .Lsubshrtoofar2
.Lsubshrtoofar1:
        bsfl %edx, %ecx
        andl $0x1C, %ecx        /* ecx = bsf/4; */
        subl $32, %ecx
        negl %ecx               /* ecx = 64 - (ecx + 32) */
        xorl %esi, %esi
        shrl %cl, %ebp          /* Shift 0x666... right to line up with the
                                   trailing zeros in edx:eax */
.Lsubshrtoofar2:
        subl %ebp, %eax
        sbbl %esi, %edx         /* Subtract 0x...666 from edx:eax */
.Lsubshrtoofar3:
        subl $1, %eax
        sbbl $0, %edx           /* Subtract 1 from edx:eax */
        movl $0x90000000, 4(%esp)
        jmp .Lrem
.Lsub:
        movl (%esp), %ebp
        movl 4(%esp), %esi
        testl %ebp, %ebp
        jnz .Lsubrem
        testl %esi, %esi
        jz .Lsubnorem
.Lsubrem:
        addl $1, %ebx
.Lsubnorem:
        /*
         * We can perform a BCD subtraction using binary operations, as follows:
         *   - Subtract rhs from lhs, in binary.  This will cause a binary
         *     borrow wherever a decimal carry should have been.
         *   - Now the digits which didn't produce a carry will be correct, but
         *     those that did will be 6 greater than the correct value.  To fix
         *     this, xor the last result with (lhs ^ rhs), or
         *     ((lhs + 0x6666...) ^ rhs), then mask off all but the lowest bit
         *     of every digit.
         *   - The last value will have a 1 after all digits that carried.
         *     Multiply by 6/8, to get 6's in the right places.
         *   - Subtract these sixes from the original sum.
         */
        movl %eax, %ebp
        movl %edx, %esi
        subl %ebx, %eax
        sbbl %edi, %edx
        jc .Lsubborrow
        xorl %ebx, %ebp
        xorl %edi, %esi
        xorl %eax, %ebp
        xorl %edx, %esi
        andl $0x11111110, %ebp
        andl $0x11111111, %esi
        shrdl $3, %esi, %ebp
        shrl $3, %esi
        leal (%ebp,%ebp,2), %ebp
        leal (%esi,%esi,2), %esi
        subl %ebp, %eax
        subl %esi, %edx
        /* We must now subtract the remainder from 1, as in
           .Lsubshrjusttoofar. */
        movl 4(%esp), %esi      /* Get the high-order remainder word (the low-
                                   order word remains in ebp) */
        movl $0x99999999, %edi
        movl $0x9999999A, %ebx  /* Move 0x999999999999999A into edi:ebx */
        bsfl %ebp, %ecx
        jz .Lsub1
        andl $0x1C, %ecx        /* ecx = bsf/4; the trailing zero digit count */
        shldl %cl, %ebx, %edi
        shll %cl, %ebx          /* Shift ...999A left to line up with the first
                                   non-zero digit in edi:ebx */
        jmp .Lsub2
.Lsub1:
        bsfl %esi, %ecx
        jz .Lrem
        andl $0x1C, %ecx        /* ecx = bsf/4; the trailing zero digit count */
        movl %ebx, %edi
        xorl %ebx, %ebx
        shll %cl, %edi          /* Shift ...999A left to line up with the first
                                   non-zero digit in edi:ebx */
.Lsub2:
        subl %ebp, %ebx
        sbbl %esi, %edi         /* Subtract esi:ebp from 0x...9999A000... */
        movl %ebx, (%esp)
        movl %edi, 4(%esp)      /* Store the remainder on the stack */
        jmp .Lrem
.Lsubborrow:
        xorl %ebx, %ebp
        xorl %edi, %esi
        xorl %eax, %ebp
        xorl %edx, %esi
        andl $0x11111110, %ebp
        andl $0x11111111, %esi
        shrdl $3, %esi, %ebp
        shrl $3, %esi
        leal (%ebp,%ebp,2), %ebp
        leal (%esi,%esi,2), %esi
        subl %ebp, %eax
        subl %esi, %edx
        subl $0x60000000, %edx
        /* Negate the result */
        movl $0x99999999, %esi
        movl $0x9999999A, %ebp  /* Move 0x999999999999999A into esi:ebp */
        bsfl %eax, %ecx
        jz .Lsubborrow1
        andl $0x1C, %ecx        /* ecx = bsf/4; the trailing zero digit count */
        shldl %cl, %ebp, %esi
        shll %cl, %ebp          /* Shift ...999A left to line up with the first
                                   non-zero digit in edx:eax */
        jmp .Lsubborrow2
.Lsubborrow1:
        bsfl %edx, %ecx
        andl $0x1C, %ecx        /* ecx = bsf/4; the trailing zero digit count */
        movl %ebp, %esi
        xorl %ebp, %ebp
        shll %cl, %esi          /* Shift ...999A left to line up with the first
                                   non-zero digit in edx:eax */
.Lsubborrow2:
        subl %eax, %ebp
        sbbl %edx, %esi         /* Subtract edx:eax from 0x...9999A000... */
        movl %ebp, %eax
        movl %esi, %edx
        negl 20(%esp)           /* Flip the resultant sign */
        /* Remainder must be zero, because in order for edi:ebx to be > than
           edx:eax, they must both be shifted all the way to the left. */
.Lrem:
        movl 44(%esp), %esi     /* Put dest in esi */
        movl %eax, (%esi)
        movl %edx, 4(%esi)
        movl 16(%esp), %eax
        movl 12(%esp), %edx
        subl %edx, %eax         /* Adjust the exponent */
        movl %eax, 8(%esi)      /* Save the exponent in dest->fields.exp */
        movl 20(%esp), %eax
        movl %eax, 12(%esi)     /* Save the sign in dest->fields.sign */
        movl $1, 16(%esi)       /* Set the special flag to FPFD_NUMBER */
        movl 4(%esp), %eax
        movl (%esp), %edx       /* Retrieve the remainder from the stack */
        movl %eax, %ecx
        shrl $28, %eax
        testl %eax, %eax
        jz .Lspecial
        cmpl $5, %eax
        je .Lspecial            /* Return values of 0 and 5 are special cases */
        addl $24, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lspecial:
        andl $0x0FFFFFFF, %ecx
        jz .Lspecial1
        addl $1, %eax
        addl $24, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lspecial1:
        testl %edx, %edx
        jz .Lspecial2
        addl $1, %eax
.Lspecial2:
        addl $24, %esp
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
