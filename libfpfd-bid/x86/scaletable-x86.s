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

        .data
.globl fpfd_lsw_bsr2mul
        .align 32
        .type fpfd_lsw_bsr2mul, @object
        .size fpfd_lsw_bsr2mul, 256
fpfd_lsw_bsr2mul:
        .long 1000000           # fpfd_lsw_bsr2mul[0]
        .long 1000000           # fpfd_lsw_bsr2mul[1]
        .long 1000000           # fpfd_lsw_bsr2mul[2]
        .long 100000            # fpfd_lsw_bsr2mul[3]
        .long 100000            # fpfd_lsw_bsr2mul[4]
        .long 100000            # fpfd_lsw_bsr2mul[5]
        .long 10000             # fpfd_lsw_bsr2mul[6]
        .long 10000             # fpfd_lsw_bsr2mul[7]
        .long 10000             # fpfd_lsw_bsr2mul[8]
        .long 1000              # fpfd_lsw_bsr2mul[9]
        .long 1000              # fpfd_lsw_bsr2mul[10]
        .long 1000              # fpfd_lsw_bsr2mul[11]
        .long 1000              # fpfd_lsw_bsr2mul[12]
        .long 100               # fpfd_lsw_bsr2mul[13]
        .long 100               # fpfd_lsw_bsr2mul[14]
        .long 100               # fpfd_lsw_bsr2mul[15]
        .long 10                # fpfd_lsw_bsr2mul[16]
        .long 10                # fpfd_lsw_bsr2mul[17]
        .long 10                # fpfd_lsw_bsr2mul[18]
        .long 1                 # fpfd_lsw_bsr2mul[19]
        .long 1                 # fpfd_lsw_bsr2mul[20]
        .long 1                 # fpfd_lsw_bsr2mul[21]
        .long 1                 # fpfd_lsw_bsr2mul[22]
        .long 0xCCCCCCCD        # fpfd_lsw_bsr2mul[23] = (10 ** -1 << 35) + 1
        .long 0xCCCCCCCD        # fpfd_lsw_bsr2mul[24] = (10 ** -1 << 35) + 1
        .long 0xCCCCCCCD        # fpfd_lsw_bsr2mul[25] = (10 ** -1 << 35) + 1
        .long 0xCCCCCCCD        # fpfd_lsw_bsr2mul[26] = (10 ** -1 << 35) + 1
        .long 0xA3D70A3E        # fpfd_lsw_bsr2mul[27] = (10 ** -2 << 38) + 1
        .long 0xA3D70A3E        # fpfd_lsw_bsr2mul[28] = (10 ** -2 << 38) + 1
        .long 0xA3D70A3E        # fpfd_lsw_bsr2mul[29] = (10 ** -2 << 38) + 1
        .long 0x83126E98        # fpfd_lsw_bsr2mul[30] = (10 ** -3 << 41) + 1
        .long 0x83126E98        # fpfd_lsw_bsr2mul[31] = (10 ** -3 << 41) + 1

.globl fpfd_lsw_bsr2shr
        .align 32
        .type fpfd_lsw_bsr2shr, @object
        .size fpfd_lsw_bsr2shr, 256
fpfd_lsw_bsr2shr:
        .zero 92        # fpfd_lsw_bsr2shr[i], i < 23, is undefined
        .long 3         # fpfd_lsw_bsr2shr[23]
        .long 3         # fpfd_lsw_bsr2shr[24]
        .long 3         # fpfd_lsw_bsr2shr[25]
        .long 3         # fpfd_lsw_bsr2shr[26]
        .long 6         # fpfd_lsw_bsr2shr[27]
        .long 6         # fpfd_lsw_bsr2shr[28]
        .long 6         # fpfd_lsw_bsr2shr[29]
        .long 9         # fpfd_lsw_bsr2shr[30]
        .long 9         # fpfd_lsw_bsr2shr[31]

.globl fpfd_lsw_bsr2exp
        .align 32
        .type fpfd_lsw_bsr2exp, @object
        .size fpfd_lsw_bsr2exp, 256
fpfd_lsw_bsr2exp:
        .long -6        # fpfd_lsw_bsr2exp[0]
        .long -6        # fpfd_lsw_bsr2exp[1]
        .long -6        # fpfd_lsw_bsr2exp[2]
        .long -5        # fpfd_lsw_bsr2exp[3]
        .long -5        # fpfd_lsw_bsr2exp[4]
        .long -5        # fpfd_lsw_bsr2exp[5]
        .long -4        # fpfd_lsw_bsr2exp[6]
        .long -4        # fpfd_lsw_bsr2exp[7]
        .long -4        # fpfd_lsw_bsr2exp[8]
        .long -3        # fpfd_lsw_bsr2exp[9]
        .long -3        # fpfd_lsw_bsr2exp[10]
        .long -3        # fpfd_lsw_bsr2exp[11]
        .long -3        # fpfd_lsw_bsr2exp[12]
        .long -2        # fpfd_lsw_bsr2exp[13]
        .long -2        # fpfd_lsw_bsr2exp[14]
        .long -2        # fpfd_lsw_bsr2exp[15]
        .long -1        # fpfd_lsw_bsr2exp[16]
        .long -1        # fpfd_lsw_bsr2exp[17]
        .long -1        # fpfd_lsw_bsr2exp[18]
        .long 0         # fpfd_lsw_bsr2exp[19]
        .long 0         # fpfd_lsw_bsr2exp[20]
        .long 0         # fpfd_lsw_bsr2exp[21]
        .long 0         # fpfd_lsw_bsr2exp[22]
        .long 1         # fpfd_lsw_bsr2exp[23]
        .long 1         # fpfd_lsw_bsr2exp[24]
        .long 1         # fpfd_lsw_bsr2exp[25]
        .long 1         # fpfd_lsw_bsr2exp[26]
        .long 2         # fpfd_lsw_bsr2exp[27]
        .long 2         # fpfd_lsw_bsr2exp[28]
        .long 2         # fpfd_lsw_bsr2exp[29]
        .long 3         # fpfd_lsw_bsr2exp[30]
        .long 3         # fpfd_lsw_bsr2exp[31]

.globl fpfd_lsw_exp2mul
        .align 32
        .type fpfd_lsw_exp2mul, @object
        .size fpfd_lsw_exp2mul, 256
fpfd_lsw_exp2mul:
        .long 1         # fpfd_lsw_exp2mul[0] is undefined
        .long 10        # fpfd_lsw_exp2mul[1]
        .long 100       # fpfd_lsw_exp2mul[2]
        .long 1000      # fpfd_lsw_exp2mul[3]

.globl fpfd_lsw_exp2div
        .align 32
        .type fpfd_lsw_exp2div, @object
        .size fpfd_lsw_exp2div, 256
fpfd_lsw_exp2div:
        .long 0                 # fpfd_lsw_exp2div[0] is undefined
        .long 0xCCCCCCCD        # fpfd_lsw_exp2div[1] = (10 ** -1 << 35) + 1
        .long 0xA3D70A3E        # fpfd_lsw_exp2div[2] = (10 ** -2 << 38) + 1
        .long 0x83126E98        # fpfd_lsw_exp2div[3] = (10 ** -3 << 41) + 1

.globl fpfd_lsw_exp2shr
        .align 32
        .type fpfd_lsw_exp2shr, @object
        .size fpfd_lsw_exp2shr, 256
fpfd_lsw_exp2shr:
        .long 0         # fpfd_lsw_exp2shr[0] is undefined
        .long 3         # fpfd_lsw_exp2shr[1]
        .long 6         # fpfd_lsw_exp2shr[2]
        .long 9         # fpfd_lsw_exp2shr[3]
