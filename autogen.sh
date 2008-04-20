#! /bin/sh

aclocal
autoconf
libtoolize --force --copy
automake --add-missing --copy
