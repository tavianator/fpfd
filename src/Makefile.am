if DPD
  SUBDIRS = dpd
endif

if BIN
  SUBDIRS = bin
endif

FPFD_VERSION = 0:0:0

C_SOURCES = add.c nan.c set.c tern.c
H_SOURCES = fpfd.h fpfd_impl.h

nobase_include_HEADERS = fpfd.h

lib_LTLIBRARIES    = libfpfd.la
libfpfd_la_SOURCES = $(C_SOURCES) $(H_SOURCES)
libfpfd_la_LDFLAGS = -version-info $(FPFD_VERSION)
libfpfd_la_CFLAGS  = -W -Wall -Wextra -std=gnu99

if DPD
  libfpfd_la_LIBADD  = dpd/libdpd.la
endif

if BIN
  libfpfd_la_LIBADD  = bin/libbin.la
endif
