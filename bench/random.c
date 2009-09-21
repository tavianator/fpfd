/*************************************************************************
 * Copyright (C) 2008 Tavian Barnes <tavianator@gmail.com>               *
 *                                                                       *
 * This file is part of The FPFD Library.                                *
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

#include "bench.h"
#include <limits.h> /* For UCHAR_MAX */

/* A local rand() implementation */
static const unsigned int FPFD_RAND_MAX = 32767;
static unsigned int fpfd_rand();
static void fpfd_srand(unsigned int seed);

void
fpfd_srandom(unsigned int seed)
{
  fpfd_srand(seed);
}

void
fpfd32_random(fpfd32_ptr dest)
{
  fpfd32_impl_t impl;
  long bits = 0, bits_left = 0;
  unsigned int i;

  do {
    for (i = 0; i < sizeof(dest->data); ++i) {
      if (bits_left <= UCHAR_MAX) {
        bits = fpfd_rand();
        bits_left = FPFD_RAND_MAX;
      }

      dest->data[i] = bits;
      bits >>= CHAR_BIT;
      bits_left >>= CHAR_BIT;
    }

    fpfd32_impl_expand(&impl, dest);

    /*
     * Addition and subtraction only really do stuff when the exponents are
     * close enough; otherwise, we benchmark mostly no-ops.
     */
    impl.fields.exp = fpfd_rand()%7;

    /* Ensure that fpfd_add performs an addition, and fpfd_sub a subtraction. */
    impl.fields.sign = 1;
  } while (impl.fields.special != FPFD_NUMBER);
  fpfd32_impl_compress(dest, &impl);
}

void
fpfd64_random(fpfd64_ptr dest)
{
  fpfd64_impl_t impl;
  long bits = 0, bits_left = 0;
  unsigned int i;

  do {
    for (i = 0; i < sizeof(dest->data); ++i) {
      if (bits_left <= UCHAR_MAX) {
        bits = fpfd_rand();
        bits_left = FPFD_RAND_MAX;
      }

      dest->data[i] = bits;
      bits >>= CHAR_BIT;
      bits_left >>= CHAR_BIT;
    }

    fpfd64_impl_expand(&impl, dest);
    impl.fields.exp = fpfd_rand()%16;
    impl.fields.sign = 1;
  } while (impl.fields.special != FPFD_NUMBER);
  fpfd64_impl_compress(dest, &impl);
}

void
fpfd128_random(fpfd128_ptr dest)
{
  fpfd128_impl_t impl;
  long bits = 0, bits_left = 0;
  unsigned int i;

  do {
    for (i = 0; i < sizeof(dest->data); ++i) {
      if (bits_left <= UCHAR_MAX) {
        bits = fpfd_rand();
        bits_left = FPFD_RAND_MAX;
      }

      dest->data[i] = bits;
      bits >>= CHAR_BIT;
      bits_left >>= CHAR_BIT;
    }

    fpfd128_impl_expand(&impl, dest);
    impl.fields.exp = fpfd_rand()%34;
    impl.fields.sign = 1;
  } while (impl.fields.special != FPFD_NUMBER);
  fpfd128_impl_compress(dest, &impl);
}

/* This local rand() implementation taken from POSIX.1-2001 */

static unsigned long next = 1;

/* FPFD_RAND_MAX assumed to be 32767 */
static unsigned int
fpfd_rand()
{
  next = next*1103515245 + 12345;
  return (unsigned int)(next/65536)%32768;
}

static void
fpfd_srand(unsigned int seed)
{
  next = seed;
}
