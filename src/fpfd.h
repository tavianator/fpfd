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

#ifndef FPFD_H
#define FPFD_H

#include <stdint.h>

#ifdef __cplusplus
// extern "C" {
#endif // __cplusplus

typedef enum {
  FPFD_RNDN, FPFD_RNDNA, FPFD_RNDZ, FPFD_RNDU, FPFD_RNDD
} fpfd_rnd_t;

typedef enum {
  FPFD_ENCD, FPFD_ENCB
} fpfd_enc_t;

typedef struct {
  unsigned char data[4];
  fpfd_enc_t enc;
} fpfd32_struct_t;

typedef struct {
  unsigned char data[8];
  fpfd_enc_t enc;
} fpfd64_struct_t;

typedef struct {
  unsigned char data[16];
  fpfd_enc_t enc;
} fpfd128_struct_t;

typedef fpfd32_struct_t  fpfd32_t[1];
typedef fpfd64_struct_t  fpfd64_t[1];
typedef fpfd128_struct_t fpfd128_t[1];

typedef       fpfd32_struct_t  *fpfd32_ptr;
typedef const fpfd32_struct_t  *fpfd32_srcptr;
typedef       fpfd64_struct_t  *fpfd64_ptr;
typedef const fpfd64_struct_t  *fpfd64_srcptr;
typedef       fpfd128_struct_t *fpfd128_ptr;
typedef const fpfd128_struct_t *fpfd128_srcptr;

// Assignment

int fpfd32_set32(fpfd32_ptr dest, fpfd32_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd32_set64(fpfd32_ptr dest, fpfd64_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd32_set128(fpfd32_ptr dest, fpfd128_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);

int fpfd64_set32(fpfd64_ptr dest, fpfd32_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd64_set64(fpfd64_ptr dest, fpfd64_srcptr src,
                 fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd64_set128(fpfd64_ptr dest, fpfd128_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);

int fpfd128_set32(fpfd128_ptr dest, fpfd32_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd128_set64(fpfd128_ptr dest, fpfd64_srcptr src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd128_set128(fpfd128_ptr dest, fpfd128_srcptr src,
                   fpfd_rnd_t rnd, fpfd_enc_t enc);

int fpfd32_set_ui(fpfd32_ptr dest, uint32_t src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd32_set_si(fpfd32_ptr dest, int32_t src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);

int fpfd64_set_ui(fpfd32_ptr dest, uint32_t src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd64_set_si(fpfd32_ptr dest, int32_t src,
                  fpfd_rnd_t rnd, fpfd_enc_t enc);

int fpfd128_set_ui(fpfd32_ptr dest, uint32_t src,
                   fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd128_set_si(fpfd32_ptr dest, int32_t src,
                   fpfd_rnd_t rnd, fpfd_enc_t enc);

// Addition

int fpfd32_add(fpfd32_ptr dest, fpfd32_srcptr lhs, fpfd32_srcptr rhs,
               fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd64_add(fpfd64_ptr dest, fpfd64_srcptr lhs, fpfd64_srcptr rhs,
               fpfd_rnd_t rnd, fpfd_enc_t enc);
int fpfd128_add(fpfd128_ptr dest, fpfd128_srcptr lhs, fpfd128_srcptr rhs,
                fpfd_rnd_t rnd, fpfd_enc_t enc);

#ifdef __cplusplus
// }
#endif // __cplusplus

#endif // FPFD_H
