#########################################################################
# Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               #
#                                                                       #
# This file is part of The FPFD Library.                                #
#                                                                       #
# The FPFD Library is free software; you can redistribute it and/or     #
# modify it under the terms of the GNU Lesser General Public License as #
# published by the Free Software Foundation; either version 3 of the    #
# License, or (at your option) any later version.                       #
#                                                                       #
# The FPFD Library is distributed in the hope that it will be useful,   #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     #
# Lesser General Public License for more details.                       #
#                                                                       #
# You should have received a copy of the GNU Lesser General Public      #
# License along with this program.  If not, see                         #
# <http://www.gnu.org/licenses/>.                                       #
#########################################################################

# void fpfd32_impl_expand(fpfd32_impl_t *dest, fpfd32_srcptr src);
#
# Converts the densely-packed-decimal representation in src to the binary-
# coded-decimal form in dest.

        .text
.globl fpfd32_impl_expand
        .type fpfd32_impl_expand, @function
fpfd32_impl_expand:
        movq (%rsi), %rax
        movq %rax, %rcx
        movq %rax, %rdx
        andq $0x3FF, %rcx
        movq fpfd_dpd2bcd@GOTPCREL(%rip), %r8   # For position-independance
        movw (%r8,%rcx,2), %cx
        shrq $10, %rdx
        andq $0x3FF, %rdx
        movw (%r8,%rdx,2), %dx
        shlq $12, %rdx
        ret
        .size fpfd32_impl_expand, .-fpfd32_impl_expand
