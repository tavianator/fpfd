dnl Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>
dnl
dnl This file is part of The FPFD Library Build Suite.
dnl
dnl The FPFD Library Build Suite is free software; you can redistribute
dnl it and/or modify it under the terms of the GNU General Public License
dnl as published by the Free Software Foundation; either version 3 of the
dnl License, or (at your option) any later version.
dnl
dnl The FPFD Library Build Suite is distributed in the hope that it will
dnl be useful, but WITHOUT ANY WARRANTY; without even the implied
dnl warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
dnl the GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program.  If not, see <http://www.gnu.org/licenses/>.

AC_PREREQ(2.68)
AC_INIT(The FPFD Library, 0.1.1, tavianator@gmail.com, fpfd)
AM_INIT_AUTOMAKE([subdir-objects parallel-tests])
AM_SILENT_RULES([yes])

dnl Programs
AC_PROG_CC
AC_PROG_CXX
AM_PROG_CC_C_O
AM_PROG_AS
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL

dnl Checks for header files.
AC_CHECK_HEADERS([arpa/inet.h stddef.h stdio.h stdlib.h string.h unistd.h])

dnl Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

dnl Find out which assembly files to compile
AC_CANONICAL_HOST

AM_CONDITIONAL([X86], [echo $host_cpu | grep '.*86$' >/dev/null])
AM_CONDITIONAL([X86_64], [echo $host_cpu | grep 'x86_64$' >/dev/null])

dnl Use FPFD for _Decimal* types?
AC_ARG_ENABLE([gcc-override],
              [AS_HELP_STRING([--enable-gcc-override],
                              [Use FPFD for _Decimal* types])],
              [],
              [enable_gcc_override=no])

AM_CONDITIONAL([GCC_OVERRIDE], [test "$enable_gcc_override" != "no"])

dnl Detect which (if any) encoding is currently used by gcc's _Decimal* types
AC_LANG([C])

bench_gcc=no

if test "$enable_gcc_override" = "no"; then
  AC_MSG_CHECKING([for the DPD encoding for _Decimal* types])
  AC_LINK_IFELSE([AC_LANG_PROGRAM(
    [ _Decimal32 __dpd_addsd3(_Decimal32 lhs, _Decimal32 rhs); ],
    [ _Decimal32 res = __dpd_addsd3(1.0df, 2.0df); ])],
                 [bench_gcc=dpd
                  AC_DEFINE([GCC_DPD], [1])
                  AC_MSG_RESULT([yes])],
                 [AC_DEFINE([GCC_DPD], [0])
                  AC_MSG_RESULT([no])])

  AC_MSG_CHECKING([for the BID encoding for _Decimal* types])
  AC_LINK_IFELSE([AC_LANG_PROGRAM(
    [ _Decimal32 __bid_addsd3(_Decimal32 lhs, _Decimal32 rhs); ],
    [ _Decimal32 res = __bid_addsd3(1.0df, 2.0df); ])],
                 [bench_gcc=bid
                  AC_DEFINE([GCC_BID], [1])
                  AC_MSG_RESULT([yes])],
                 [AC_DEFINE([GCC_BID], [0])
                  AC_MSG_RESULT([no])])
fi

AM_CONDITIONAL([BENCH_GCC], [test "$bench_gcc" != "no"])
AM_CONDITIONAL([GCC_DPD], [test "$bench_gcc" = "dpd"])
AM_CONDITIONAL([GCC_BID], [test "$bench_gcc" = "bid"])

dnl Timing library for benchmarks
PKG_CHECK_MODULES([libsandglass], [libsandglass >= 0.2],
                  [],
                  [AC_MSG_WARN([libsandglass not found - benchmarking suite will not work])])
AC_SUBST(libsandglass_CFLAGS)
AC_SUBST(libsandglass_LIBS)

dnl Generate Makefiles
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_FILES([Makefile
                 libfpfd-dpd/Makefile
                 libfpfd-bid/Makefile
                 libfpfd/Makefile
                 tests/Makefile
		 bench/Makefile
                 doc/Makefile])
AC_OUTPUT
