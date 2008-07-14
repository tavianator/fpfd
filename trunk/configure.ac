#                                               -*- Autoconf -*-

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
AC_CHECK_HEADERS([arpa/inet.h fcntl.h stddef.h stdint.h stdlib.h string.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_UINT32_T
AC_TYPE_INT32_T
AC_TYPE_UINT16_T
AC_TYPE_UINT64_T
AC_TYPE_UINT8_T
AC_TYPE_SIZE_T

# Decimal or binary encoding?
AC_ARG_WITH([dpd],
            [AS_HELP_STRING([--with-dpd],
                            [use the densely-packed-decimal encoding])],
            [],
            [with_dpd=no])

AC_ARG_WITH([bin],
            [AS_HELP_STRING([--with-bin],
                            [use the binary encoding])],
            [],
            [with_bin=no])

AM_CONDITIONAL([DPD], [test "x$with_dpd" != xno])
AM_CONDITIONAL([BIN], [test "x$with_bin" != xno])

# Find out which assembly files to compile
AC_CANONICAL_HOST

case $host_cpu in
     *86)
        AM_CONDITIONAL([X86], [true])
        test "x$with_dpd" != xno &&
            src/dpd/x86/dpdtable > src/dpd/x86/dpdtable.s
        ;;
esac

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_FILES([Makefile
                 src/Makefile
                 src/dpd/Makefile
                 src/bin/Makefile
		 bench/Makefile])
AC_OUTPUT
