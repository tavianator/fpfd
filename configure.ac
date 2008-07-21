#                                               -*- Autoconf -*-

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

AC_PREREQ(2.62)
AC_INIT(The FPFD Library, 0.0, tavianator@gmail.com, fpfd)
AM_INIT_AUTOMAKE(fpfd, 0.0)

# Programs
AC_PROG_CC
AM_PROG_CC_C_O
AM_PROG_AS
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL

# Checks for header files.
AC_CHECK_HEADERS([arpa/inet.h fcntl.h stddef.h stdlib.h string.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

# Static or dynamic linking of back-end?
AC_ARG_ENABLE([impl],
              [AS_HELP_STRING([--enable-impl={no, dpd, bid}],
                              [statically link either the dpd or bid back-end
                               into libfpfd.])],
              [case $enable_impl in
                   no | dpd | bid) ;;
                   *) AC_ERROR([Argument to --enable-impl should be 'no', 'dpd', or 'bid', not '$enable_impl'])
               esac],
              [enable_impl=no])

AM_CONDITIONAL([STATIC_DPD], [test "x$enable_impl" = xdpd])
AM_CONDITIONAL([STATIC_BID], [test "x$enable_impl" = xbid])

# Find out which assembly files to compile
AC_CANONICAL_HOST

AM_CONDITIONAL([X86], [echo $host_cpu | grep '.*86$' > /dev/null])

case $host_cpu in
    *86)
        libfpfd-dpd/x86/dpdtable > libfpfd-dpd/x86/dpdtable.s
        ;;
esac

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_FILES([Makefile
                 libfpfd/Makefile
                 libfpfd-dpd/Makefile
                 libfpfd-bid/Makefile
                 check/Makefile
		 bench/Makefile])
AC_OUTPUT
