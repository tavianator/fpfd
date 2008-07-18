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

check_PROGRAMS = signedzero-dpd signedzero-bid
TESTS          = $(check_PROGRAMS)

signedzero_dpd_SOURCES = signedzero.c
signedzero_dpd_LDADD   = ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
signedzero_dpd_CFLAGS  = -W -Wall -Wextra -std=gnu99
signedzero_bid_SOURCES = $(signedzero_dpd_SOURCES)
signedzero_bid_LDADD   = ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la
signedzero_bid_CFLAGS  = $(signedzero_dpd_CFLAGS)
