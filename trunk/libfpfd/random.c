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

#include "fpfd_impl.h"
#include <stdlib.h> /* For rand, rand_r, srand, RAND_MAX */
#include <limits.h> /* For UCHAR_MAX                     */

void
fpfd32_random(fpfd32_ptr dest)
{
  fpfd32_impl_t impl;
  long bits = 0, bits_left = 0;
  unsigned int i;

  do {
    for (i = 0; i < sizeof(dest->data); ++i) {
      if (bits_left <= UCHAR_MAX) {
        bits = rand();
        bits_left = RAND_MAX;
      }

      dest->data[i] = bits;
      bits >>= CHAR_BIT;
      bits_left >>= CHAR_BIT;
    }

    fpfd32_impl_expand(&impl, dest);
  } while (impl.fields.special != FPFD_ZERO
           && impl.fields.special != FPFD_NUMBER);
}

void
fpfd32_srandom(unsigned int seed)
{
  srand(seed);
}
