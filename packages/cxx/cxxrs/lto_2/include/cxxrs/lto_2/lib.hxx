#pragma once

#include <cstdint>

namespace cxxrs::lto_2 {
  auto succ(uint16_t n) noexcept -> uint16_t;
  auto add_to_fib_fst(uint16_t m, uint16_t n) noexcept -> uint16_t;
}
