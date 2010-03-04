###########################################################################
## Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               ##
##                                                                       ##
## This file is part of The FPFD Library Build Suite.                    ##
##                                                                       ##
## The FPFD Library Build Suite is free software; you can redistribute   ##
## it and/or modify it under the terms of the GNU General Public License ##
## as published by the Free Software Foundation; either version 3 of the ##
## License, or (at your option) any later version.                       ##
##                                                                       ##
## The FPFD Library Build Suite is distributed in the hope that it will  ##
## be useful, but WITHOUT ANY WARRANTY; without even the implied         ##
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See ##
## the GNU General Public License for more details.                      ##
##                                                                       ##
## You should have received a copy of the GNU General Public License     ##
## along with this program.  If not, see <http://www.gnu.org/licenses/>. ##
###########################################################################

AM_CFLAGS = $(libsandglass_CFLAGS)

EXTRA_LTLIBRARIES        = libfpfd-bench.la
libfpfd_bench_la_SOURCES = bench.h htable.c random.c x.c
libfpfd_bench_la_LDFLAGS = $(libsandglass_LIBS)

EXTRA_PROGRAMS = benchmark-arch benchmark-dpd benchmark-bid

if BENCH_GCC
  EXTRA_PROGRAMS += benchmark-gcc
endif

benchmark_arch_LDADD = ./libfpfd-bench.la -lm

if X86
  benchmark_arch_SOURCES = x86/bench-x86.h x86/bench-x86.c x86/div-x86.c x86/mul-x86.c x86/uncertainty-x86.c
endif
if X86_64
  benchmark_arch_SOURCES = x86_64/bench-x86_64.h x86_64/bench-x86_64.c x86_64/div-x86_64.c x86_64/mul-x86_64.c x86_64/uncertainty-x86_64.c
endif

benchmark_dpd_SOURCES = bench-fpfd.h bench-fpfd.c impl_expand.c impl_addsub.c impl_mul.c impl_div.c impl_inc.c impl_scale.c impl_compress.c add.c sub.c mul.c div.c fma.c
benchmark_dpd_LDADD   = ./libfpfd-bench.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la -lm
benchmark_bid_SOURCES = $(benchmark_dpd_SOURCES)
benchmark_bid_LDADD   = ./libfpfd-bench.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la -lm

if BENCH_GCC
  benchmark_gcc_SOURCES = bench-gcc.h bench-gcc.c add-gcc.c sub-gcc.c mul-gcc.c div-gcc.c

if   GCC_DPD
    benchmark_gcc_LDADD   = ./libfpfd-bench.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la -lm
endif
if   GCC_BID
    benchmark_gcc_LDADD   = ./libfpfd-bench.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la -lm
endif
endif

EXTRA_DIST = plot.sh

TRIALS = 1000

if BENCH_GCC
bench: benchmark-arch$(EXEEXT) benchmark-dpd$(EXEEXT) benchmark-bid$(EXEEXT) benchmark-gcc$(EXEEXT)
	mkdir -p arch dpd bid gcc
	(cd arch && ../benchmark-arch$(EXEEXT) $(TRIALS))
	(cd dpd && ../benchmark-dpd$(EXEEXT) $(TRIALS))
	(cd bid && ../benchmark-bid$(EXEEXT) $(TRIALS))
	(cd gcc && ../benchmark-gcc$(EXEEXT) $(TRIALS))
else
bench: benchmark-arch$(EXEEXT) benchmark-dpd$(EXEEXT) benchmark-bid$(EXEEXT)
	mkdir -p arch dpd bid
	(cd arch && ../benchmark-arch$(EXEEXT) $(TRIALS))
	(cd dpd && ../benchmark-dpd$(EXEEXT) $(TRIALS))
	(cd bid && ../benchmark-bid$(EXEEXT) $(TRIALS))
endif
