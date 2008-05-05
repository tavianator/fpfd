#                                               -*- Autoconf -*-

AC_PREREQ(2.61)
AC_INIT(The FPFD Library, 0.0, tavianator@gmail.com, fpfd)
AM_INIT_AUTOMAKE(fpfd, 0.0)

# Programs
AC_PROG_CC
AM_PROG_AS
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL

# Find out which assembler files to compile
AC_CANONICAL_HOST

case $host_cpu in
     *86)
        AM_CONDITIONAL([X86], [true])
        src/x86/dpdtable > src/x86/dpdtable.s
        ;;
esac

AC_SUBST(path)

AC_CONFIG_FILES([Makefile
                 src/Makefile])
AC_OUTPUT
