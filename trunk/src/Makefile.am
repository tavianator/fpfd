FPFD_VERSION = 0:0:0

C_SOURCES = expand.c nan.c ops.c panic.c set.c tern.c

if X86
S_SOURCES = x86/dpdtable.s x86/to_bcd.s x86/to_bin.s x86/from_bcd.s x86/from_bin.s x86/bcd_inc.s x86/bin_inc.s x86/bcd_normalize.s x86/bin_mul.s
endif

H_SOURCES = fpfd.h fpfd_impl.h

nobase_include_HEADERS = fpfd.h

lib_LTLIBRARIES    = libfpfd.la
libfpfd_la_SOURCES = $(C_SOURCES) $(S_SOURCES) $(H_SOURCES)
libfpfd_la_LDFLAGS = -version-info $(FPFD_VERSION)
libfpfd_la_CFLAGS  = -W -Wall -Wextra -std=gnu99 -rdynamic
