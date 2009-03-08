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

EXTRA_PROGRAMS = dpdtable multable divtable
BUILT_SOURCES  = dpdtable$(EXEEXT) multable$(EXEEXT) divtable$(EXEEXT)
CLEANFILES     = $(BUILT_SOURCES)

dpdtable_SOURCES = dpdtable.c
multable_SOURCES = multable.c
divtable_SOURCES = divtable.c

$(srcdir)/x86/dpdtable-x86.s: dpdtable.c
	./dpdtable$(EXEEXT) >$@
$(srcdir)/x86/multable-x86.s: multable.c
	./multable$(EXEEXT) >$@
$(srcdir)/x86/divtable-x86.s: divtable.c
	./divtable$(EXEEXT) >$@

$(srcdir)/x86_64/dpdtable-x86_64.s: dpdtable.c
	./dpdtable$(EXEEXT) >$@
$(srcdir)/x86_64/multable-x86_64.s: multable.c
	./multable$(EXEEXT) >$@
$(srcdir)/x86_64/divtable-x86_64.s: divtable.c
	./divtable$(EXEEXT) >$@

lib_LTLIBRARIES = libfpfd-dpd.la

libfpfd_dpd_la_SOURCES =

if X86
  libfpfd_dpd_la_SOURCES += x86/addsub-x86.s x86/compress-x86.s x86/div-x86.s x86/divtable-x86.s x86/dpdtable-x86.s x86/encoding-x86.s x86/expand-x86.s x86/inc-x86.s x86/mul-x86.s x86/multable-x86.s x86/odd-x86.s x86/scale-x86.s
endif

if X86_64
  libfpfd_dpd_la_SOURCES += x86_64/addsub-x86_64.s x86_64/compress-x86_64.s x86_64/div-x86_64.s x86_64/divtable-x86_64.s x86_64/dpdtable-x86_64.s x86_64/encoding-x86_64.s x86_64/expand-x86_64.s x86_64/mul-x86_64.s x86_64/multable-x86_64.s x86_64/inc-x86_64.s x86_64/odd-x86_64.s x86_64/scale-x86_64.s
endif

if GCC_OVERRIDE
  libfpfd_dpd_la_SOURCES += gcc.c
endif
