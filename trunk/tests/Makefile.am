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

check_LTLIBRARIES = libfpfd-test.la
check_PROGRAMS    = impl_expand-dpd impl_expand-bid impl_addsub-dpd impl_addsub-bid impl_mul-dpd impl_mul-bid impl_div-dpd impl_div-bid impl_inc-dpd impl_inc-bid impl_scale-dpd impl_scale-bid impl_compress-dpd impl_compress-bid signedzero-dpd signedzero-bid C++-dpd C++-bid
TESTS             = $(check_PROGRAMS)

libfpfd_test_la_SOURCES = test.c test.h

impl_expand_dpd_SOURCES = impl_expand-dpd.c
impl_expand_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
impl_expand_bid_SOURCES = impl_expand-bid.c
impl_expand_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

impl_addsub_dpd_SOURCES = impl_addsub-dpd.c
impl_addsub_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
impl_addsub_bid_SOURCES = impl_addsub-bid.c
impl_addsub_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

impl_mul_dpd_SOURCES = impl_mul-dpd.c
impl_mul_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
impl_mul_bid_SOURCES = impl_mul-bid.c
impl_mul_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

impl_div_dpd_SOURCES = impl_div-dpd.c
impl_div_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
impl_div_bid_SOURCES = impl_div-bid.c
impl_div_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

impl_inc_dpd_SOURCES = impl_inc-dpd.c
impl_inc_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
impl_inc_bid_SOURCES = impl_inc-bid.c
impl_inc_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

impl_scale_dpd_SOURCES = impl_scale-dpd.c
impl_scale_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
impl_scale_bid_SOURCES = impl_scale-bid.c
impl_scale_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

impl_compress_dpd_SOURCES = impl_compress-dpd.c
impl_compress_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
impl_compress_bid_SOURCES = impl_compress-bid.c
impl_compress_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

signedzero_dpd_SOURCES = signedzero.c
signedzero_dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
signedzero_bid_SOURCES = signedzero.c
signedzero_bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la

C___dpd_SOURCES = cxx.cpp
C___dpd_LDADD   = ./libfpfd-test.la ../libfpfd-dpd/libfpfd-dpd.la ../libfpfd/libfpfd.la
C___bid_SOURCES = cxx.cpp
C___bid_LDADD   = ./libfpfd-test.la ../libfpfd-bid/libfpfd-bid.la ../libfpfd/libfpfd.la
