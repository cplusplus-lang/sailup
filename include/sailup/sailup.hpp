#ifndef SAILUP_HPP
#define SAILUP_HPP

#include <sailup/sailup_api.hpp>

[[nodiscard]] SAILUP_API int factorial(int) noexcept;

[[nodiscard]] constexpr int factorial_constexpr(int input) noexcept
{
  if (input == 0) { return 1; }

  return input * factorial_constexpr(input - 1);
}

#endif
