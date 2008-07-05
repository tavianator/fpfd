C_SOURCES = bench.c htable.c main.c random.c

if X86
S_SOURCES = x86/rdtsc.s
endif

H_SOURCES = bench.h

noinst_PROGRAMS = bench
bench_SOURCES   = $(C_SOURCES) $(S_SOURCES) $(H_SOURCES)
bench_LDADD     = ../src/libfpfd.la
bench_CFLAGS    = -W -Wall -Wextra -std=gnu99 -rdynamic
