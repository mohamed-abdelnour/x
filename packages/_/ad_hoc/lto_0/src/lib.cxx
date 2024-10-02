#include <cstdint>

extern "C" auto rs_fib(uint16_t n) -> uint16_t;

extern "C" auto cxx_succ(uint16_t n) -> uint16_t {
  return n + 1;
}

extern "C" auto cxx(uint16_t n) -> uint16_t {
  return cxx_succ(rs_fib(n));
}
