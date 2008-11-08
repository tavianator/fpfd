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

# unsigned int fpfd32_impl_addsub(fpfd32_impl_t *dest, int sign,
#                                 const fpfd32_impl_t *lhs,
#                                 const fpfd32_impl_t *rhs);
#
# Add lhs and rhs if sign == 1, or subtract lhs and rhs if sign == -1, and store
# the result in dest.

        .text
.globl fpfd32_impl_addsub
        .type fpfd32_impl_addsub, @function
fpfd32_impl_addsub:
        pushl %ebx
        movl 12(%esp), %ecx     # Put sign in ecx
        movl 16(%esp), %eax     # Put lhs in eax
        movl 20(%esp), %edx     # Put rhs in edx
        xorl 12(%eax), %ecx
        xorl 12(%edx), %ecx     # Calculate
                                # (sign ^ lhs->fields.sign ^ rhs->fields.sign)
        js .Lsub                # If the result is -1, we are subtracting
        movl 8(%eax), %ecx
        subl 8(%edx), %ecx      # lhs->fields.exp - rhs->fields.sign
        popl %ebx
        ret
.Lsub:
        popl %ebx
        ret
        .size fpfd32_impl_addsub, .-fpfd32_impl_addsub
