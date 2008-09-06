#! /bin/sh

aclocal
autoconf
libtoolize --force --copy
automake --add-missing --copy
libfpfd-dpd/x86/dpdtable-x86.sh > libfpfd-dpd/x86/dpdtable-x86.s
echo You may now run ./configure
