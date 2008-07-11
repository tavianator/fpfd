ACLOCAL_AMFLAGS = -I m4
SUBDIRS = src bench

bench: all-recursive
	cd bench && $(MAKE) $(AM_MAKEFLAGS) bench

.PHONY: bench
