/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library                                 *
 *                                                                       *
 * The FPFD Library is free software; you can redistribute it and/or     *
 * modify it under the terms of the GNU Lesser General Public License as *
 * published by the Free Software Foundation; either version 3 of the    *
 * License, or (at your option) any later version.                       *
 *                                                                       *
 * The FPFD Library is distributed in the hope that it will be useful,   *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 * Lesser General Public License for more details.                       *
 *                                                                       *
 * You should have received a copy of the GNU Lesser General Public      *
 * License along with this program.  If not, see                         *
 * <http://www.gnu.org/licenses/>.                                       *
 *************************************************************************/

#include "fpfd_impl.h"
#include <stdlib.h>
#include <stdio.h>

#ifdef __GNUC__
#include <execinfo.h>
#define BTBUFSIZE 100
#endif /* __GNUC__ */

void fpfd_panic(const char *error) {
#ifdef __GNUC__
  void *buffer[BTBUFSIZE];
  int nptrs;

  nptrs = backtrace(buffer, BTBUFSIZE);
  backtrace_symbols_fd(buffer, nptrs, fileno(stderr));
#endif /* __GNUC__ */

  fprintf(stderr, "\n%s\n\n", error);
  exit(EXIT_FAILURE);
}
