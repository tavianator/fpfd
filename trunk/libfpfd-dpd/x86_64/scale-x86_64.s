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
 * Scale the value in dest, to fit in the compressed format.
 */

        .text
.globl fpfd32_impl_scale
        .type fpfd32_impl_scale, @function
fpfd32_impl_scale:
        movq (%rdi), %rdx       /* Put dest->mant in rdx */
        bsrq %rdx, %rcx         /* Find the leading non-zero bit */
        jz .Luflow
        addl $4, %ecx
        andl $0x7C, %ecx        /* Add one and round up to a multiple of 4 */
        subl $64, %ecx
        negl %ecx               /* Subtract from 64 */
        shlq %cl, %rdx          /* Shift rdx all the way to the left */
        shrl $2, %ecx
        subl $9, %ecx
        movl %ecx, %r8d
        negl %ecx
        addl 8(%rdi), %ecx      /* Add (32 + 4 - ecx)/4 to the exponent */
        cmpl $90, %ecx
        jg .Loflow
        cmpl $-108, %ecx
        jl .Luflow
        je .Lpuflow
        cmpl $-101, %ecx
        jl .Lsubnorm
        movl %ecx, 8(%rdi)      /* Set dest->exp to the adjusted exponent */
        xorq %rax, %rax
        shrdq $36, %rdx, %rax
        shrq $36, %rdx          /* Shift rdx.rax to the 28th bit */
        movq %rdx, (%rdi)       /* Set dest->mant to the scaled mantissa */
        movq %rax, %rcx
        shlq $4, %rcx           /* Slide off the most significant nibble */
        shrq $60, %rax
        testl %r8d, %r8d
        jnz .Lchanged
        movl $0x20, %eax
        ret
.Lchanged:
        testl %eax, %eax
        jz .Lspecial
        cmpl $5, %eax
        je .Lspecial
        ret
.Lsubnorm:
        negl %ecx
        subl $92, %ecx
        shll $2, %ecx
        xorq %rax, %rax
        shrdq %cl, %rdx, %rax
        shrq %cl, %rdx          /* Shift rdx.rax to the correct bit */
        movq %rdx, (%rdi)       /* Set dest->mant to the subnormal mantissa */
        movl $-101, 8(%rdi)     /* Set the exponent to the subnormal exponent */
        movq %rax, %rcx
        movq $0x0FFFFFFFFFFFFFFF, %rdx
        andq %rdx, %rcx         /* Mask off the most significant nibble */
        shrq $60, %rax
        orl $0x10, %eax
        cmpl $0x10, %eax
        je .Lspecial
        cmpl $0x15, %eax
        je .Lspecial
        ret
.Loflow:
        movq $0x9999999, (%rdi) /* Set to the highest significand possible */
        movl $90, 8(%rdi)       /* Set the exponent to the maximum exponent */
        movl $10, %eax          /* Return the special 10 value */
        ret
.Luflow:
        movl $0, 16(%rdi)       /* Set the special flag to FPFD_ZERO */
        movl $0x1A, %eax
        ret
.Lpuflow:
        movq %rdx, %rax
        movq $0, (%rdi)         /* Set dest->mant to the subnormal mantissa */
        movl $-101, 8(%rdi)     /* Set the exponent to the subnormal exponent */
        movq %rax, %rcx
        movq $0x0FFFFFFFFFFFFFFF, %rdx
        andq %rdx, %rcx         /* Mask off the most significant nibble */
        shrq $60, %rax
        orl $0x10, %eax
        cmpl $0x10, %eax
        je .Lspecial
        cmpl $0x15, %eax
        je .Lspecial
        ret
.Lspecial:
        testq %rcx, %rcx
        jz .Lspecial2
        addl $1, %eax
.Lspecial2:
        ret
        .size fpfd32_impl_scale, .-fpfd32_impl_scale
