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

fpfd_action_t
fpfd_impl_nanprop(fpfd_impl_t *lhs, fpfd_impl_t *rhs, fpfd_flags_t *flags)
{
  fpfd_action_t action = FPFD_OPERATE;

  if (flags && (lhs->special == FPFD_SNAN || rhs->special == FPFD_SNAN)) {
    *flags |= FPFD_INVALID;
  }

  if (lhs->special == FPFD_SNAN || lhs->special == FPFD_QNAN) {
    lhs->special = FPFD_QNAN;
    action = FPFD_LHS;
  } else if (rhs->special == FPFD_SNAN || rhs->special == FPFD_QNAN) {
    rhs->special = FPFD_QNAN;
    action = FPFD_RHS;
  }

  return action;
}
