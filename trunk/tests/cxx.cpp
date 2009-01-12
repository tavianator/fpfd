#include "test.h"

/*
 * Ensure that fpfd.h can be included in a C++ program and behave properly.
 */
int
main()
{
  fpfd_flags_t flags;
  fpfd_declare(pz); /* Positive zero */
  fpfd_declare(res); /* Result */

  /* Ensure that a pretty standard operation compiles and works */
  fpfd_set(pz, zero);
  fpfd_assert_ora2msfx(mul, res, pz, pz, FPFD_RNDN, 1, FPFD_ZERO, FPFD_NONE);

  /* fpfd_flags_t can't be an enum type for this conversion to work */
  flags |= FPFD_UNDERFLOW | FPFD_INEXACT;

  return exitstatus;
}
