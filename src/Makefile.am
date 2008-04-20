FPFD_VERSION = 0:0:0

C_SOURCES = set.c add.c tern.c try_expand.c
S_SOURCES = dpdtable.s
H_SOURCES = fpfd.h fpfd_impl.h

nobase_include_HEADERS = fpfd.h

lib_LTLIBRARIES    = libfpfd.la
libfpfd_la_SOURCES = $(C_SOURCES) $(S_SOURCES) $(H_SOURCES)
libfpfd_la_LDFLAGS = -version-info $(FPFD_VERSION)
libfpfd_la_CFLAGS  = -W -Wall -Wextra -std=c99
