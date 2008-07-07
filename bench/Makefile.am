C_SOURCES = bench.c htable.c main.c random.c uticks.c

H_SOURCES = bench.h

noinst_PROGRAMS   = benchmark
benchmark_SOURCES = $(C_SOURCES) $(S_SOURCES) $(H_SOURCES)
benchmark_LDADD   = ../src/libfpfd.la
benchmark_CFLAGS  = -W -Wall -Wextra -std=gnu99 -rdynamic

bench: benchmark
	./benchmark /dev/urandom ./rngsave
