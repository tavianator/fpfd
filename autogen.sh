#! /bin/sh

aclocal
autoconf
libtoolize --force --copy
automake --add-missing --copy
echo Generating DPD table...
libfpfd-dpd/x86/dpdtable-x86.sh > libfpfd-dpd/x86/dpdtable-x86.s 
echo Generating BCD multiplication table...
libfpfd-dpd/x86/multable-x86.sh > libfpfd-dpd/x86/multable-x86.s 
cp libfpfd-dpd/x86/dpdtable-x86.s libfpfd-dpd/x86_64/dpdtable-x86_64.s
cp libfpfd-dpd/x86/multable-x86.s libfpfd-dpd/x86_64/multable-x86_64.s
echo You may now run ./configure
