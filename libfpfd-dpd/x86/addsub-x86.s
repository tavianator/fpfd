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
        movl 28(%esp), %esi     /* Put lhs in esi */
        movl 32(%esp), %edi     /* Put rhs in edi */
        movl 24(%esp), %ebx     /* Put sign in ebx */
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
        movl %eax, -4(%esp)     /* Store lhs->fields.sign on the stack; this
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
        movl %ebx, -4(%esp)     /* esi will be our resultant sign */
        xchgl %esi, %edi        /* Swap our lhs and rhs pointers */
        xchgl %ecx, %edx        /* Swap our leading zero digit counts */
        negl %ebp               /* Re-calculate ebp */
.Lnoswitch:
        xorl %eax, %ebx         /* ebx ^= (original lhs)->fields.sign */
        movl 8(%esi), %eax
        movl %eax, -8(%esp)     /* Store lhs->fields.exp, the resultant
                                   exponent, on the stack */
        movl %ecx, -12(%esp)
        movl %edx, -16(%esp)    /* Store ecx and edx on the stack */
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
        movl -16(%esp), %ecx
        subl %ebp, %ecx         /* ecx now stores the necessary digit shift
                                   count of rhs */
        movl (%edi), %ebx
        movl 4(%edi), %edi      /* Put lhs->mant in edi:ebx */
        js .Laddshr             /* If ecx is negative, we shift right; otherwise
                                   we shift left */
        movl $0, -24(%esp)
        movl $0, -20(%esp)      /* Remainder is zero */
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
        jmp .Lrem
.Laddshr:
        negl %ecx
        leal (,%ecx,4), %ecx    /* ecx *= -4 */
        cmpl $64, %ecx
        jae .Laddshrtoofar
        cmpb $32, %cl
        jb .Laddrhsshrd
        subb $32, %cl
        movl $0, %ebp
        shrdl %cl, %ebx, %ebp
        shrdl %cl, %edi, %ebx
        shrl %cl, %edi          /* Shift edi:ebx.ebp right by cl - 32 bits */
        movl %ebp, -24(%esp)
        movl %ebx, -20(%esp)    /* Store 0.ebx:ebp as the remainder */
        movl %edi, %ebx
        xorl %edi, %edi         /* Move edi to ebx, and zero edi */
        jmp .Lrem
.Laddrhsshrd:
        movl $0, %ebp
        shrdl %cl, %ebx, %ebp
        shrdl %cl, %edi, %ebx
        shrl %cl, %edi          /* Shift edi:ebx.ebp right by cl bits */
        movl %ebp, -20(%esp)
        movl $0, -24(%esp)
        jmp .Lrem
.Laddshrtoofar:
        movl %ebx, -24(%esp)
        movl %edi, -20(%esp)
        je .Lrem
        movl $0x10000000, -20(%esp)
        jmp .Lrem
.Lsubshift:
        movl -16(%esp), %ecx
        subl %ebp, %ecx         /* ecx now stores the necessary digit shift
                                   count of rhs */
        movl (%edi), %ebx
        movl 4(%edi), %edi      /* Put lhs->mant in edi:ebx */
        js .Lsubshr             /* If ecx is negative, we shift right; otherwise
                                   we shift left */
        movl $0, -24(%esp)
        movl $0, -20(%esp)      /* Remainder is zero */
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
        jmp .Lrem
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
        movl %ebp, -24(%esp)
        movl %ebx, -20(%esp)    /* Store 0.ebx:ebp as the remainder */
        movl %edi, %ebx
        xorl %edi, %edi         /* Move edi to ebx, and zero edi */
        jmp .Lrem
.Lsubrhsshrd:
        movl $0, %ebp
        shrdl %cl, %ebx, %ebp
        shrdl %cl, %edi, %ebx
        shrl %cl, %edi          /* Shift edi:ebx.ebp right by cl bits */
        movl %ebp, -20(%esp)
        movl $0, -24(%esp)
        jmp .Lrem
.Lsubshrjusttoofar:
.Lsubshrtoofar:
.Lrem:
        movl 20(%esp), %esi     /* Put dest in esi */
        movl %eax, (%esi)
        movl %edx, 4(%esi)
        movl -8(%esp), %eax
        movl -12(%esp), %edx
        subl %edx, %eax         /* Adjust the exponent */
        movl %eax, 8(%esi)      /* Save the exponent in dest->fields.exp */
        movl -4(%esp), %eax
        movl %eax, 12(%esi)     /* Save the sign in dest->fields.sign */
        movl $1, 16(%esi)       /* Set the special flag to FPFD_NUMBER */
        movl -20(%esp), %eax
        movl -24(%esp), %edx    /* Retrieve the remainder from the stack */
        movl %eax, %ecx
        shrl $28, %eax
        cmpl $0, %eax
        je .Lspecial
        cmpl $5, %eax
        je .Lspecial            /* Return values of 0 and 5 are special cases */
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lspecial:
        andl $0x0FFFFFFF, %ecx
        jz .Lspecial1
        addl $1, %eax
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
.Lspecial1:
        cmpl $0, %edx
        je .Lspecial2
        addl $1, %eax
.Lspecial2:
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
