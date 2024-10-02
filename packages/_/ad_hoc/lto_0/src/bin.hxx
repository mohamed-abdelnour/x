#pragma once

#include <cstdint>
#include <cstdlib>

extern "C" auto cxx(uint16_t n) -> uint16_t;
extern "C" auto rs(uint16_t n) -> uint16_t;

namespace bin {
  const uint16_t N = 9;

  template <typename F> constexpr auto main(F f, uint16_t n) -> int {
    return f(n);
  }

  template <typename F, typename A> constexpr auto main(F f, int argc, A argv) -> int {
    return argc < 2 ? 0 : main(f, strtol(argv[1], nullptr, 0));
  }
}
