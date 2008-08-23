#! /bin/sh

aclocal
autoconf
libtoolize --force --copy
automake --add-missing --copy
libfpfd-dpd/x86/dpdtable.sh > libfpfd-dpd/x86/dpdtable.s
echo You may now run ./configure
