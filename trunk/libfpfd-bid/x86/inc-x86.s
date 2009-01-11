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

/* void fpfd32_impl_inc(fpfd32_impl_t *dest); */

/*
 * Increment the mantissa, in order to round. dest must be normalized.
 */

        .text
.globl fpfd32_impl_inc
        .type fpfd32_impl_inc, @function
fpfd32_impl_inc:
        movl 4(%esp), %eax
        movl (%eax), %edx
        addl $1, %edx
        cmpl $10000000, %edx
        je .Lrollover
        movl %edx, (%eax)
        ret
.Lrollover:
        cmpl $90, 8(%eax)
        jge .Loflow             /* Test for overflow */
        addl $1, 8(%eax)        /* Increment the exponent */
        movl $1000000, (%eax)
        ret
.Loflow:
        movl $4, 16(%eax)       /* Set the special flag to FPFD_INF */
        ret
        .size fpfd32_impl_inc, .-fpfd32_impl_inc
