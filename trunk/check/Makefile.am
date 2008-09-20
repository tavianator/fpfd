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

check_LTLIBRARIES = libfpfd-check.la
check_PROGRAMS    = signedzero-dpd signedzero-bid noncanonical-dpd noncanonical-bid scale-bid
TESTS             = $(check_PROGRAMS)

libfpfd_check_la_SOURCES = check.c check.h

signedzero_dpd_SOURCES = signedzero.c
signedzero_dpd_LDADD   = ./libfpfd-check.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
signedzero_bid_SOURCES = signedzero.c
signedzero_bid_LDADD   = ./libfpfd-check.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

noncanonical_dpd_SOURCES = noncanonical.c noncanonical.h noncanonical-dpd.c
noncanonical_dpd_LDADD   = ./libfpfd-check.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
noncanonical_bid_SOURCES = noncanonical.c noncanonical.h noncanonical-bid.c
noncanonical_bid_LDADD   = ./libfpfd-check.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

scale_bid_SOURCES = scale-bid.c
scale_bid_LDADD   = ./libfpfd-check.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la
