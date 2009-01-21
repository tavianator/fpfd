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
        bsrl 4(%esi), %ecx
        jz .LlhsMSWzero
        subl $31, %ecx
        negl %ecx
        jmp .Lbsrrhs
.LlhsMSWzero:
        bsrl (%esi), %ecx
        subl $63, %ecx
        negl %ecx
.Lbsrrhs:
        bsrl 4(%edi), %edx
        jz .LrhsMSWzero
        subl $31, %edx
        negl %edx
        jmp .Lresexp
.LrhsMSWzero:
        bsrl (%edi), %edx
        subl $63, %edx
        negl %edx
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
        movl %edx, %eax
        subl %ecx, %eax
        addl 8(%esi), %eax
        subl 8(%edi), %eax      /* eax = (lhs->fields.exp - leadingzeros(lhs))
                                     - (rhs->fields.exp - leadingzeros(rhs)) */
        jns .Lnoswitch          /* If eax is positive, lhs gets shifted further
                                   left to line up the digits. If it's negative,
                                   rhs needs to be shifted further. In this
                                   case, we swap lhs and rhs, so that lhs can
                                   always be the one shifted further */
        movl %ebx, -4(%esp)     /* esi will be our resultant sign */
        xchgl %esi, %edi        /* Swap our lhs and rhs pointers */
        xchgl %ecx, %edx        /* Swap our leading zero digit counts */
        negl %eax               /* Re-calculate eax */
.Lnoswitch:
        movl 8(%esi), %eax
        movl %eax, -8(%esp)     /* Store lhs->fields.exp, the resultant
                                   exponent, on the stack */
.Lrem:
        movl 20(%esp), %esi
        movl $0, (%esi)
        movl $0, 4(%esi)
        movl -8(%esp), %eax
        subl %edx, %eax
        movl %eax, 8(%esi)
        movl -4(%esp), %eax
        movl %eax, 12(%esi)
        movl $1, 16(%esi)       /* Set the special flag to FPFD_NUMBER */
        xorl %eax, %eax
        popl %ebp
        popl %edi
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
