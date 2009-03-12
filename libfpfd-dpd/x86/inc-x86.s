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

/*
 * Increment the mantissa, in case we need to round. dest must be normalized.
 * See impl_addsub for an explanation of the bit tricks involved.
 */

        .text
/* void fpfd32_impl_inc(fpfd32_impl_t *dest); */
.globl fpfd32_impl_inc
        .type fpfd32_impl_inc, @function
fpfd32_impl_inc:
        movl 4(%esp), %ecx
        movl (%ecx), %eax
        addl $0x06666666, %eax
        movl %eax, %edx
        addl $0x1, %eax
        xorl %eax, %edx
        notl %edx
        andl $0x11111110, %edx
        shrl $3, %edx
        leal (%edx,%edx,2), %edx
        subl %edx, %eax
        testl $0x10000000, %eax
        jnz .Lrollover
        movl %eax, (%ecx)
        ret
.Lrollover:
        cmpl $90, 8(%ecx)
        jge .Loflow             /* Test for overflow */
        addl $1, 8(%ecx)        /* Increment the exponent */
        movl $0x01000000, (%ecx)
        ret
.Loflow:
        movl $4, 16(%ecx)       /* Set the special flag to FPFD_INF */
        ret
        .size fpfd32_impl_inc, .-fpfd32_impl_inc
