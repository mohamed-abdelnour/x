#include <cstdint>

extern "C" auto fib(uint16_t n) -> uint16_t;
extern "C" auto check_fib(uint16_t n) -> uint16_t;

extern "C" auto succ(uint16_t n) -> uint16_t {
  return n + 1;
}

extern "C" auto add_to_fib_fst(uint16_t m, uint16_t n) -> uint16_t {
  return fib(m) + n;
}

auto main() -> int {
  auto const N = 8U;
  return check_fib(N);
}
