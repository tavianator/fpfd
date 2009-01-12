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
        shrl $2, %r9d           /* Divide each bit count by 4, rounding up, and
                                   subtract from 16, to give a leading zero
                                   digit count of lhs and rhs, in r8 and r9,
                                   respectively. */
        movl %r9d, %edx
        subl %r8d, %edx
        movl 12(%r10), %eax
        movl %eax, -4(%rsp)     /* Store lhs->fields.sign on the stack; this
                                   will be the resultant sign if we don't flip
                                   our operands. */
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
        leal (,%r8d,4), %ecx    /* cl = 4*r9 */
        shlq %cl, %rax          /* Shift rax all the way to the left */
        testl %esi, %esi
        jnz .Lsubshift          /* If esi == 0, we are adding digits. If not, we
                                   are subtracting. */
        subl %edx, %r9d         /* r9d now stores the necessary digit shift
                                   count of rhs */
        movq (%r11), %rdx       /* Put rhs->mant in rdx */
        js .Laddshr             /* If r9d is negative, we shift right; otherwise
                                   we shift left */
        leal (,%r9d,4), %ecx    /* cl = 4*r9 */
        shlq %cl, %rdx          /* Shift rdx to line up the digits */
        movq $0, %r9            /* r9 is our remainder from rhs */
        jmp .Ladd               /* Perform the addition of digits */
.Laddshr:
        negl %r9d
        leal (,%r9d,4), %ecx    /* cl = -4*r9 */
        cmpl $16, %r9d          /* Check if r9 >= 16 */
        movq $0, %r9            /* r9 is our remainder from rhs */
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
        shrdq $4, %rax, %r9
        shrq $4, %rax           /* Otherwise, shift the remainder over one
                                   digit, and capture the falloff in r9. */
        jmp .Lrem
.Ladd:
        movq %rax, %rsi         /* Store rax in rsi */
        movq %rdx, %r11         /* Store rdx in r11 */
        movq $0, %rdx           /* rdx will hold the final sum */
        /*
         * HUGE optimization (~52 cycles, on average):
         *   If the low-order 8 digits of rsi are zero, we simply add (in
         *   binary) r11d to rsi, then do half the number of digit additions.
         */
        testl %esi, %esi
        jnz .Laddnoopt
        movl %r11d, %edx
        shlq $32, %rdx
        shrq $32, %rsi
        shrq $32, %r11
.Laddnoopt:
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al         /* al is the next digit of rsi to be added */
        andb $0x0F, %cl         /* cl is the next digit of r11 to be added.
                                   The `and' instruction clears the carry flag
                                   for adc. */
.Laddloop:
        /* This loop adds the digits of rax to rdx */
        adcb %al, %cl           /* add al to cl, with carry */
        cmpb $0x9, %cl
        ja .Laddcarry           /* Test for decimal carry */
        addb %cl, %dl           /* Store the digit in rdx */
        rorq $4, %rdx           /* Rotate rdx to take the next digit */
        shrq $4, %r11
        shrq $4, %rsi           /* Queue up the next digits to be added */
        jz .Ladddone            /* If rsi is zero, we are done */
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl         /* Otherwise, load the next digits */
        jmp .Laddloop
.Laddcarry:
        addb $0x06, %cl         /* There was a carry, so add 6 to correct the
                                   BCD sum */
        andb $0x0F, %cl         /* Mask off the excess */
        addb %cl, %dl           /* Store the digit in rdx */
        rorq $4, %rdx           /* Rotate rdx to take the next digit */
        shrq $4, %r11
        shrq $4, %rsi           /* Queue up the next digits to be added */
        jz .Ladddonecarry       /* If rsi is zero, we are done, but ended on a
                                   carry. */
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl         /* Otherwise, load the next digits */
        stc                     /* Set the carry flag */
        jmp .Laddloop
.Ladddonecarry:
        shrdq $4, %rdx, %r9
        shrq $4, %rdx           /* We finished on a carry, so shift the digits
                                   right by one, saving the falloff in r9 ... */
        movq $0x1000000000000000, %rcx
        orq %rcx, %rdx          /* ... and set the leading digit to 1. */
        subl $1, %r8d           /* Correct the exponent */
        movq %r9, %rax          /* Put the remainder in rax */
        movq $0, %r9            /* Zero the extra remainder */
        jmp .Lrem
.Ladddone:
        movq %r9, %rax          /* Put the remainder in rax */
        movq $0, %r9            /* Zero the extra remainder */
        jmp .Lrem
.Lsubshift:
        subl %edx, %r9d
        movq (%r11), %rdx
        js .Lsubshr
        leal (,%r9d,4), %ecx
        shlq %cl, %rdx
        movq $0, %r9
        jmp .Lsub
.Lsubshr:
        negl %r9d
        leal (,%r9d,4), %ecx
        cmpl $16, %r9d
        movq $0, %r9
        je .Lsubshrjusttoofar
        ja .Lsubshrtoofar
        shrdq %cl, %rdx, %r9
        shrq %cl, %rdx
        jmp .Lsub
.Lsubshrjusttoofar:
        bsfq %rdx, %rcx
        addl $1, %ecx
        andl $0x3C, %ecx
        movq $0x999999999999999A, %r9
        shlq %cl, %r9
        subq %rdx, %r9
        xchgq %r9, %rax
        bsfq %r9, %rdx
        addl $1, %edx
        andl $0x3C, %edx
        jz .Lsubshrjusttoofar1
        movl $64, %ecx
        subl %edx, %ecx
        movq $0x0666666666666666, %rdx
        shrq %cl, %rdx
        subq %rdx, %r9
.Lsubshrjusttoofar1:
        subq $1, %r9
        movq %r9, %rdx
        movq $0, %r9
        jmp .Lrem
.Lsubshrtoofar:
        movq %rax, %rdx
        bsfq %rdx, %r9
        addl $1, %r9d
        andl $0x3C, %r9d
        jz .Lsubshrtoofar1
        movl $64, %ecx
        subl %r9d, %ecx
        movq $0x0666666666666666, %rax
        shrq %cl, %rax
        subq %rax, %rdx
.Lsubshrtoofar1:
        subq $1, %rdx
        movq $0x9000000000000000, %rax
        movq $0, %r9
        jmp .Lrem
.Lsub:
        testl %eax, %eax
        jnz .Lsubnoopt
        testl %edx, %edx
        jnz .Lsubnoopt
        testq %r9, %r9
        jnz .Lsubnoopt
        shrq $32, %rax
        shrq $32, %rdx
.Lsubnoopt:
        movq %rax, %rsi
        movq %rdx, %r11
        movq %rdx, %rcx
        movq $0, %rdx
        andb $0x0F, %al
        andb $0x0F, %cl
        testq %r9, %r9
        jz .Lsubloop
        stc
.Lsubloop:
        sbbb %cl, %al
        jc .Lsubborrow
        addb %al, %dl
        rorq $4, %rdx
        shrq $4, %rsi
        shrq $4, %r11
        test %rsi, %rsi
        jz .Lsubdone
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl
        jmp .Lsubloop
.Lsubborrow:
        addb $0x0A, %al
        addb %al, %dl
        rorq $4, %rdx
        shrq $4, %rsi
        shrq $4, %r11
        test %rsi, %rsi
        jz .Lsubdoneborrow
        movq %rsi, %rax
        movq %r11, %rcx
        andb $0x0F, %al
        andb $0x0F, %cl
        stc
        jmp .Lsubloop
.Lsubdoneborrow:
        bsfq %rdx, %rcx
        addl $1, %ecx
        andl $0x3C, %ecx
        movq $0x999999999999999A, %rax
        shlq %cl, %rax
        subq %rdx, %rax
        movq %rax, %rdx
        movq %r9, %rax
        movq $0, %r9
        negl -4(%rsp)
        jmp .Lrem
.Lsubdone:
        movq %r9, %rax
        bsfq %r9, %rcx
        jz .Lsubdonenorem
        addl $1, %ecx
        andl $0x3C, %ecx
        movq $0x999999999999999A, %rax
        shlq %cl, %rax
        subq %r9, %rax
.Lsubdonenorem:        
        movq $0, %r9
.Lrem:
        movq %rdx, (%rdi)       /* Save the mantissa in dest->mant */
        movl -8(%rsp), %edx
        subl %r8d, %edx         /* Adjust the exponent */
        movl %edx, 8(%rdi)      /* Save the exponent in dest->fields.exp */
        movl -4(%rsp), %edx
        movl %edx, 12(%rdi)     /* Save the sign in dest->fields.sign */
        movl $1, 16(%rdi)       /* Set the special flag to FPFD_NUMBER */
        shrdq $60, %rax, %r9
        shrq $60, %rax          /* Shift the remainder right to be left with
                                   only the leading digit, and capture the
                                   falloff in r9 */
        cmpl $0, %eax
        je .Lspecial
        cmpl $5, %eax
        je .Lspecial            /* Return values of 0 and 5 are special cases */
        ret
.Lspecial:
        cmpq $0, %r9
        je .Lspecial1
        addl $1, %eax
.Lspecial1:
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
