#include <cstdint>

#include <cxxrs/lto_2/lib.hxx>
#include <cxxrs/lto_2/lib.rs.hxx>

namespace cxxrs::lto_2 {
  auto succ(uint16_t n) noexcept -> uint16_t {
    return n + 1;
  }

  auto add_to_fib_fst(uint16_t m, uint16_t n) noexcept -> uint16_t {
    return fib(m) + n;
  }
}

auto main() -> int {
  auto const N = 8U;
  return cxxrs::lto_2::check_fib(N);
}
