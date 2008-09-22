#########################################################################
# Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               #
#                                                                       #
# This file is part of The FPFD Library Build Suite.                    #
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

EXTRA_LTLIBRARIES        = libfpfd-bench.la
libfpfd_bench_la_SOURCES = bench.h htable.c x.c

if X86
libfpfd_bench_la_SOURCES += x86/rdtsc-x86.s
endif

if X86_64
libfpfd_bench_la_SOURCES += x86_64/rdtsc-x86_64.s
endif

EXTRA_PROGRAMS        = benchmark-dpd benchmark-bid
benchmark_dpd_SOURCES = bench-fpfd.h impl_compress.c impl_expand.c impl_inc.c bench-fpfd.c
benchmark_dpd_LDADD   = ./libfpfd-bench.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la -lm
benchmark_bid_SOURCES = $(benchmark_dpd_SOURCES)
benchmark_bid_LDADD   = ./libfpfd-bench.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la -lm

bench: benchmark-dpd$(EXEEXT) benchmark-bid$(EXEEXT)
	(cd dpd && ../benchmark-dpd$(EXEEXT))
	(cd bid && ../benchmark-bid$(EXEEXT))
