#! /bin/sh

aclocal
autoconf
libtoolize --force --copy
automake --add-missing --copy
libfpfd-dpd/x86/dpdtable-x86.sh > libfpfd-dpd/x86/dpdtable-x86.s 
cp libfpfd-dpd/x86/dpdtable-x86.s libfpfd-dpd/x86_64/dpdtable-x86_64.s
echo You may now run ./configure
