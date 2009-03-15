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
        pushl %ebx
        pushl %esi
        movl 12(%esp), %esi     /* Put dest in esi */
        movl (%esi), %eax
        movl 4(%esi), %edx      /* Put dest->mant in edx:eax */
        bsrl %edx, %ecx         /* Find the leading non-zero bit */
        jz .LzeroMSW
        addl $4, %ecx
        andl $0x3C, %ecx        /* Add one and round up to a multiple of 4 */
        subl $32, %ecx
        negl %ecx               /* Subtract from 32 */
        shldl %cl, %eax, %edx
        shll %cl, %eax          /* Shift edx:eax all the way to the left */
        shrl $2, %ecx
        subl $9, %ecx
        negl %ecx
        addl 8(%esi), %ecx      /* Add (32 + 4 - ecx)/4 to the exponent */
        cmpl $90, %ecx
        jg .Loflow              /* If ecx is > 90, we have overflowed */
        cmpl $-108, %ecx
        jl .Luflow              /* If ecx is < -108, we have underflowed */
        je .LpuflowMSW          /* If ecx is == -108, we have partially
                                   underflowed */
        cmpl $-101, %ecx
        jl .LsubnormMSW         /* If -108 < ecx < -101, we need to
                                   subnormalize */
        movl %ecx, 8(%esi)      /* Set dest->exp to the adjusted exponent */
        xorl %ecx, %ecx
        shrdl $4, %eax, %ecx
        shrdl $4, %edx, %eax
        shrl $4, %edx           /* Shift edx:eax.ecx to the 28th bit */
        movl %edx, (%esi)
        movl $0, 4(%esi)        /* Set dest->mant to the scaled mantissa */
        movl %eax, %ebx
        andl $0x0FFFFFFF, %ebx  /* Mask off the most significant nibble of the
                                   remainder */
        shrl $28, %eax
        testl %eax, %eax
        jz .LspecialMSW
        cmpl $5, %eax
        je .LspecialMSW         /* Test for the special 0 and 5 return values */
        popl %esi
        popl %ebx
        ret
.LsubnormMSW:
        negl %ecx
        subl $100, %ecx         /* Subtract ecx from 100, to give the digit
                                   shift count needed to subnormalize the
                                   mantissa */
        shll $2, %ecx
        xorl %ebx, %ebx
        shrdl %cl, %eax, %ebx
        shrdl %cl, %edx, %eax
        shrl %cl, %edx          /* Shift edx:eax.ebx to the correct bit */
        movl %ebx, %ecx
        movl %edx, (%esi)
        movl $0, 4(%esi)        /* Set dest->mant to the subnormal mantissa */
        movl $-101, 8(%esi)     /* Set the exponent to the subnormal exponent */
        movl %eax, %ebx
        andl $0x0FFFFFFF, %ebx  /* Mask off the most significant nibble */
        shrl $28, %eax
        orl $0x10, %eax         /* Indicate subnormalization */
        cmpl $0x10, %eax
        je .LspecialMSW
        cmpl $0x15, %eax
        je .LspecialMSW         /* Test for the special 0x10 and 0x15 return
                                   values */
        popl %esi
        popl %ebx
        ret
.LpuflowMSW:
        movl %eax, %ebx
        movl %ebx, %ecx
        movl %edx, %eax
        xorl %edx, %edx
        movl $0, (%esi)
        movl $0, 4(%esi)        /* Set dest->mant to zero */
        movl $-101, 8(%esi)     /* Set the exponent to the subnormal exponent */
        andl $0x0FFFFFFF, %ebx  /* Mask off the most significant nibble */
        shrl $28, %eax
        orl $0x10, %eax         /* Indicate subnormalization */
        cmpl $0x10, %eax
        je .LspecialMSW
        cmpl $0x15, %eax
        je .LspecialMSW         /* Test for the special 0x10 and 0x15 return
                                   values */
        popl %esi
        popl %ebx
        ret
.LspecialMSW:
        testl %ebx, %ebx
        jz .LspecialMSW2
        addl $1, %eax
        popl %esi
        popl %ebx
        ret
.LspecialMSW2:
        testl %ecx, %ecx
        jz .LspecialMSW3
        addl $1, %eax
.LspecialMSW3:
        popl %esi
        popl %ebx
        ret
.LzeroMSW:
        bsrl %eax, %ecx
        jz .Luflow
        /* MSW is zero and LSW is nonzero; this is unlikely */
        addl $4, %ecx
        andl $0x3C, %ecx        /* Add one and round up to a multiple of 4 */
        subl $32, %ecx
        negl %ecx               /* Subtract from 32 */
        shll %cl, %eax          /* Shift eax all the way to the left */
        shrl $2, %ecx
        subl $1, %ecx
        movl %ecx, %ebx
        negl %ecx
        addl 8(%esi), %ecx      /* Add (4 - ecx)/4 to the exponent */
        cmpl $90, %ecx
        jg .Loflow              /* If ecx is > 90, we have overflowed */
        cmpl $-108, %ecx
        jl .Luflow              /* If ecx is < -108, we have underflowed */
        je .LpuflowLSW          /* If ecx is == -108, we have partially
                                   underflowed */
        cmpl $-101, %ecx
        jl .LsubnormLSW         /* If -108 < ecx < -101, we need to
                                   subnormalize */
        movl %ecx, 8(%esi)      /* Set dest->exp to the adjusted exponent */
        shrdl $4, %eax, %edx
        shrl $4, %eax           /* Shift eax.edx to the 28th bit */
        movl %eax, (%esi)
        movl $0, 4(%esi)        /* Set dest->mant to the scaled mantissa */
        movl %edx, %eax
        shrl $28, %eax
        testl %ebx, %ebx
        jnz .LchangedLSW
        movl $0x20, %eax
        popl %esi
        popl %ebx
        ret
.LchangedLSW:
        popl %esi
        popl %ebx
        ret
.LsubnormLSW:
        negl %ecx
        subl $100, %ecx         /* Subtract ecx from 100, to give the digit
                                   shift count needed to subnormalize the
                                   mantissa */
        shll $2, %ecx
        shrdl %cl, %eax, %edx
        shrl %cl, %eax          /* Shift eax.edx to the correct bit */
        movl %eax, (%esi)
        movl $0, 4(%esi)        /* Set dest->mant to the subnormal mantissa */
        movl $-101, 8(%esi)     /* Set the exponent to the subnormal exponent */
        movl %edx, %eax
        andl $0x0FFFFFFF, %edx
        shrl $28, %eax
        orl $0x10, %eax
        cmpl $0x10, %eax
        je .LspecialLSW
        cmpl $0x15, %eax
        je .LspecialLSW
        popl %esi
        popl %ebx
        ret
.LpuflowLSW:
        movl %eax, %edx
        movl $0, (%esi)
        movl $0, 4(%esi)        /* Set dest->mant to zero */
        movl $-101, 8(%esi)     /* Set the exponent to the subnormal exponent */
        andl $0x0FFFFFFF, %edx
        shrl $28, %eax
        orl $0x10, %eax         /* Indicate subnormalization */
        cmpl $0x10, %eax
        je .LspecialLSW
        cmpl $0x15, %eax
        je .LspecialLSW         /* Test for the special 0x10 and 0x15 return
                                   values */
        popl %esi
        popl %ebx
        ret
.LspecialLSW:
        testl %edx, %edx
        jz .LspecialLSW2
        addl $1, %eax
.LspecialLSW2:
        popl %esi
        popl %ebx
        ret
.Loflow:
        movl $0x9999999, (%esi)
        movl $0, 4(%esi)        /* Set to the highest possible significand */
        movl $90, 8(%esi)       /* Set the exponent to the maximum exponent */
        movl $10, %eax          /* Return the special 10 value */
        popl %esi
        popl %ebx
        ret
.Luflow:
        movl $0, 16(%esi)       /* Set the special flag to FPFD_ZERO */
        movl $0x1A, %eax        /* Return the special 0x1A value */
        popl %esi
        popl %ebx
        ret
        .size fpfd32_impl_scale, .-fpfd32_impl_scale
