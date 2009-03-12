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
        bsrq (%r10), %r8
        bsrq (%r11), %r9        /* Count the leading zero bits of each
                                   mantissa (we assume mantissas are not 0) */
        subl $63, %r8d
        subl $63, %r9d
        negl %r8d
        negl %r9d
        shrl $2, %r8d
        shrl $2, %r9d           /* Divide each bit count by 4 (rounding up), and
                                   subtract from 16, to give a leading zero
                                   digit count of lhs and rhs, in r8 and r9,
                                   respectively. */
        movl 12(%r10), %eax
        movl %eax, -4(%rsp)     /* Store lhs->fields.sign on the stack; this
                                   will be the resultant sign if we don't flip
                                   our operands. */
        movl %r9d, %edx
        subl %r8d, %edx
        addl 8(%r10), %edx
        subl 8(%r11), %edx      /* edx = (lhs->fields.exp - leadingzeros(lhs))
                                     - (rhs->fields.exp - leadingzeros(rhs)) */
        jns .Lnoswitch          /* If edx is positive, lhs gets shifted further
                                   left to line up the digits. If it's negative,
                                   rhs needs to be shifted further. In this
                                   case, we swap lhs and rhs, so that lhs can
                                   always be the one shifted further */
        movl %esi, -4(%rsp)     /* esi will be our resultant sign */
        xchgq %r10, %r11        /* Swap our lhs and rhs pointers */
        xchgl %r8d, %r9d        /* Swap our leading zero digit counts */
        negl %edx               /* Re-calculate edx */
.Lnoswitch:
        xorl %eax, %esi         /* esi ^= (original lhs)->fields.sign */
        movl 8(%r10), %eax
        movl %eax, -8(%rsp)     /* Store lhs->fields.exp, the resultant
                                   exponent, on the stack */
        movq (%r10), %rax       /* Put lhs->mant in rax */
        leal (,%r8,4), %ecx     /* cl = 4*r8 */
        shlq %cl, %rax          /* Shift rax all the way to the left */
        testl %esi, %esi
        jnz .Lsubshift          /* If esi == 0, we are adding digits. If not, we
                                   are subtracting. */
        subl %edx, %r9d         /* r9d now stores the necessary digit shift
                                   count of rhs */
        movq (%r11), %rdx       /* Put rhs->mant in rdx */
        js .Laddshr             /* If r9d is negative, we shift right; otherwise
                                   we shift left */
        leal (,%r9,4), %ecx     /* cl = 4*r9 */
        shlq %cl, %rdx          /* Shift rdx to line up the digits */
        xorq %r9, %r9           /* r9 is the remainder from rhs */
        jmp .Ladd               /* Perform the addition of digits */
.Laddshr:
        negl %r9d
        leal (,%r9,4), %ecx     /* cl = -4*r9 */
        cmpl $16, %r9d          /* Check if r9 >= 16 */
        movq $0, %r9            /* r9 is the remainder from rhs (mov doesn't
                                   touch the flags) */
        jae .Laddshrtoofar      /* If r9 was >= 16, we would right-shift by more
                                   digits than are in rhs->mant, so handle this
                                   case specially. */
        shrdq %cl, %rdx, %r9
        shrq %cl, %rdx          /* Shift rdx appropriately, and capture the
                                   falloff in r9 */
        jmp .Ladd               /* Perform the addition of digits */
.Laddshrtoofar:
        xchgq %rax, %rdx        /* Swap rax and rdx. For .Lrem, rax is the
                                   remainder, and rdx is the sum. */
        je .Lrem                /* If r9 was == 16, we are done */
        movq $0x1000000000000000, %rax  /* Otherwise, treat the remainder as
                                           0.1 */
        jmp .Lrem
.Ladd:
        /*
         * We can perform a BCD addition using binary operations, as follows:
         *   - First, add 0x6666... to rhs.
         *   - Add lhs to rhs, in binary.  This will cause a binary carry
         *     wherever a decimal carry should have been, due to 6 being added
         *     to the digit.
         *   - Now the digits which produced a carry will be correct, but those
         *     that didn't will be 6 greater than the correct value.  To fix
         *     this, xor the last result with (lhs ^ rhs), or
         *     ((lhs + 0x6666...) ^ rhs), then mask off all but the lowest bit
         *     of every digit.
         *   - The last value will have a 1 after all digits that carried.
         *     One's complement this value, and multiply by 6/8, to get 6's in
         *     the right places.
         *   - Subtract these sixes from the original sum.
         */
        movq $0x6666666666666666, %rcx
        addq %rcx, %rdx
        movq %rdx, %rcx
        addq %rax, %rdx
        jc .Laddcarry
        xorq %rax, %rcx
        xorq %rdx, %rcx
        notq %rcx
        movq $0x1111111111111110, %rax
        andq %rax, %rcx
        shrq $3, %rcx
        shlq $57, %rax
        orq %rax, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rdx
        movq %r9, %rax
        jmp .Lrem
.Laddcarry:
        xorq %rax, %rcx
        xorq %rdx, %rcx
        notq %rcx
        movq $0x1111111111111110, %rax
        andq %rax, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rdx
        shrdq $4, %rdx, %r9
        shrq $4, %rdx           /* The addition carried, so shift the digits
                                   right by one, saving the falloff in r9 ... */
        movq $0x1000000000000000, %rcx
        orq %rcx, %rdx          /* ... and set the leading digit to 1. */
        subl $1, %r8d           /* Correct the exponent */
        movq %r9, %rax          /* Put the remainder in rax */
        jmp .Lrem
.Lsubshift:
        subl %edx, %r9d         /* r9d now stores the necessary digit shift
                                   count of rhs */
        movq (%r11), %rdx       /* Put rhs->mant in rdx */
        js .Lsubshr             /* If r9d is negative, we shift right; otherwise
                                   we shift left */
        leal (,%r9,4), %ecx     /* cl = 4*r9 */
        shlq %cl, %rdx          /* Shift rdx to line up the digits */
        xorq %r9, %r9           /* r9 is the remainder from rhs */
        jmp .Lsub               /* Perform the subtraction of digits */
.Lsubshr:
        negl %r9d
        leal (,%r9,4), %ecx     /* cl = -4*r9 */
        cmpl $16, %r9d          /* Check if r9 >= 16 */
        movq $0, %r9            /* r9 is the remainder from rhs (mov doesn't
                                   touch the flags) */
        je .Lsubshrjusttoofar
        ja .Lsubshrtoofar       /* If r9 was >= 16, we would right-shift by more
                                   digits than are in rhs->mant, so handle these
                                   cases specially. */
        shrdq %cl, %rdx, %r9
        shrq %cl, %rdx          /* Shift rdx appropriately, and capture the
                                   falloff in r9 */
        jmp .Lsub               /* Perform the addition of digits */
.Lsubshrjusttoofar:
        /*
         * Shift count == 16. This means we have rax - 0.rdx. So, subtract
         * 0.rdx from 1, and subtract 1 from rax.
         *
         * Subtracting 0.rdx from 1 is equivalent to subtracting the lowest non-
         * zero digit from 10, and all higher digits from 9.
         *
         * Subtracting 1 from rax is equivalent to subtracting, in hexadecimal,
         * 6 from all trailing zero nibbles (if any), and then subtracting 1.
         */
        bsfq %rdx, %rcx         /* Forward bit scan this time */
        andl $0x3C, %ecx        /* ecx = bsf/4; the trailing zero digit count */
        movq $0x999999999999999A, %r9
        shlq %cl, %r9           /* Shift ...999A left to line up with the first
                                   non-zero digit in rdx */
        subq %rdx, %r9          /* Subtract rdx from 0x...9999A000... */
        xchgq %r9, %rax         /* Swap r9 and rax */
        bsfq %r9, %rdx
        andl $0x3C, %edx        /* edx = bsf/4; */
        jz .Lsubshrjusttoofar1  /* Test for no trailing zeros */
        movl $64, %ecx
        subl %edx, %ecx
        movq $0x6666666666666666, %rdx
        shrq %cl, %rdx          /* Shift 0x666... right to line up with the
                                   trailing zeros in r9 */
        subq %rdx, %r9          /* Subtract 0x...666 from rdx */
.Lsubshrjusttoofar1:
        subq $1, %r9            /* Subtract 1 from r9 */
        movq %r9, %rdx          /* Put the mantissa in rdx */
        jmp .Lrem
.Lsubshrtoofar:
        /* Shift count > 16; just subtract one from rax as above, and treat the
           remainder as 0.9 */
        movq %rax, %rdx
        bsfq %rdx, %r9
        andl $0x3C, %r9d        /* r9d = bsf/4; trailing zero digit count */
        jz .Lsubshrtoofar1      /* Test for no trailing zeros */
        movl $64, %ecx
        subl %r9d, %ecx
        movq $0x6666666666666666, %rax
        shrq %cl, %rax          /* Shift 0x666... right to line up with the
                                   trailing zeros in rdx */
        subq %rax, %rdx         /* Subtract 0x...666 from rax */
.Lsubshrtoofar1:
        subq $1, %rdx           /* Subtract 1 from rdx */
        movq $0x9000000000000000, %rax  /* Remainder is equivalent to 0.9 */
        jmp .Lrem
.Lsub:
        testq %r9, %r9
        jz .Lsubnorem
        addq $1, %rdx
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
        movq %rax, %rcx
        subq %rdx, %rax
        jc .Lsubborrow
        xorq %rdx, %rcx
        xorq %rax, %rcx
        movq $0x1111111111111110, %rdx
        andq %rdx, %rcx
        shrq $3, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rax
        movq %rax, %rdx
        /* Negate the remainder */
        xorq %rax, %rax         /* In case r9 == 0 */
        bsfq %r9, %rcx
        jz .Lrem                /* Test for r9 == 0 */
        andl $0x3C, %ecx        /* ecx = bsf/4; trailing zero digit count */
        movq $0x999999999999999A, %rax
        shlq %cl, %rax          /* Shift ...999A left to line up with the first
                                   non-zero digit in r9 */
        subq %r9, %rax          /* Subtract r9 from 0x...9999A000... */
        jmp .Lrem
.Lsubborrow:
        xorq %rdx, %rcx
        xorq %rax, %rcx
        movq $0x1111111111111110, %rdx
        andq %rdx, %rcx
        shrq $3, %rcx
        shlq $57, %rdx
        orq %rdx, %rcx
        leaq (%rcx,%rcx,2), %rcx
        subq %rcx, %rax
        movq %rax, %rdx
        /* Negate the result */
        bsfq %rdx, %rcx
        andl $0x3C, %ecx        /* ecx = bsf/4; trailing zero digit count */
        movq $0x999999999999999A, %rax
        shlq %cl, %rax          /* Shift ...999A left to line up with the first
                                   non-zero digit in rdx */
        subq %rdx, %rax         /* Subtract rdx from 0x...9999A000... */
        movq %rax, %rdx
        xorq %rax, %rax         /* r9 must be zero, because in order for rax to
                                   be > than rdx, they must both be shifted all
                                   the way to the left */
        negl -4(%rsp)           /* Flip the resultant sign */
.Lrem:
        movq %rdx, (%rdi)       /* Save the mantissa in dest->mant */
        movl -8(%rsp), %edx
        subl %r8d, %edx         /* Adjust the exponent */
        movl %edx, 8(%rdi)      /* Save the exponent in dest->fields.exp */
        movl -4(%rsp), %edx
        movl %edx, 12(%rdi)     /* Save the sign in dest->fields.sign */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        xorq %r9, %r9
        shrdq $60, %rax, %r9
        shrq $60, %rax          /* Shift the remainder right to be left with
                                   only the leading digit, and capture the
                                   falloff in r9 */
        testl %eax, %eax
        jz .Lspecial
        cmpl $5, %eax
        je .Lspecial            /* Return values of 0 and 5 are special cases */
        ret
.Lspecial:
        testq %r9, %r9
        jz .Lspecial1
        addl $1, %eax
.Lspecial1:
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
