#! /bin/bash

#########################################################################
# Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               #
#                                                                       #
# This file is part of The FPFD Library Build Suite                     #
#                                                                       #
# The FPFD Library Build Suite is free software; you can redistribute   #
# it and/or modify it under the terms of the GNU General Public License #
# as published by the Free Software Foundation; either version 3 of the #
# License, or (at your option) any later version.                       #
#                                                                       #
# The FPFD Library Build Suite is distributed in the hope that it will  #
# be useful, but WITHOUT ANY WARRANTY; without even the implied         #
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See #
# the GNU General Public License for more details.                      #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

function bcd2dpd() {
    bcd=$1
    m=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    k=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    j=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    i=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    h=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    g=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    f=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    e=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    d=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    c=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    b=$((bcd & 0x1))
    bcd=$((bcd >> 1))
    a=$((bcd & 0x1))

    p=$((b | (a & j) | (a & f & i)))
    q=$((c | (a & k) | (a & g & i)))
    r=$((d))
    s=$(((f & (~a | ~i)) | (~a & e & j) | (e & i)))
    t=$((g  | (~a & e & k) | (a & i)))
    u=$((h))
    v=$((a | e | i))
    w=$((a | (e & i) | (~e & j)))
    x=$((e | (a & i) | (~a & k)))
    y=$((m))

    echo "        .value 0b000000$p$q$r$s$t$u$v$w$x$y"
}

function dpd2bcd() {
    dpd=$1
    y=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    x=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    w=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    v=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    u=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    t=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    s=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    r=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    q=$((dpd & 0x1))
    dpd=$((dpd >> 1))
    p=$((dpd & 0x1))

    a=$(((v & w) & (~s | t | ~x)))
    b=$((p & (~v | ~w | (s & ~t & x))))
    c=$((q & (~v | ~w | (s & ~t & x))))
    d=$((r))
    e=$((v & ((~w & x) | (~t & x) | (s & x))))
    f=$(((s & (~v | ~x)) | (p & ~s & t & v & w & x)))
    g=$(((t & (~v | ~x)) | (q & ~s & t & w)))
    h=$((u))
    i=$((v & ((~w & ~x) | (w & x & (s | t)))))
    j=$(((~v & w) | (s & v & ~w & x) | (p & w & (~x | (~s & ~t)))))
    k=$(((~v & x) | (t & ~w & x) | (q & v & w & (~x | (~s & ~t)))))
    m=$((y))

    echo "        .value 0b0000$a$b$c$d$e$f$g$h$i$j$k$m"
}

echo "        .data"
echo ".globl fpfd_bcd2dpd"
echo "        .align 32"
echo "        .type fpfd_bcd2dpd, @object"
echo "        .size fpfd_bcd2dpd, 4914"
echo "fpfd_bcd2dpd:"

for ((num=0x000; num<=0x999; ++num))
do
    bcd2dpd $num
done

echo ""
echo ".globl fpfd_dpd2bcd"
echo "        .align 32"
echo "        .type fpfd_dpd2bcd, @object"
echo "        .size fpfd_dpd2bcd, 2046"
echo "fpfd_dpd2bcd:"

for ((num=0x000; num<=0x3FF; ++num))
do
    dpd2bcd $num
done
