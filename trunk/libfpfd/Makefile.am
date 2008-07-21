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

FPFD_VERSION = 0:0:0

C_SOURCES = add.c nan.c set.c tern.c
H_SOURCES = fpfd.h fpfd_impl.h

nobase_include_HEADERS = fpfd.h

lib_LTLIBRARIES    = libfpfd.la
libfpfd_la_SOURCES = $(C_SOURCES) $(H_SOURCES)
libfpfd_la_LDFLAGS = -version-info $(FPFD_VERSION)

if STATIC_DPD
  libfpfd_la_LIBADD  = ../libfpfd-dpd/libfpfd-dpd.la
endif

if STATIC_BID
  libfpfd_la_LIBADD  = ../libfpfd-bid/libfpfd-bid.la
endif
