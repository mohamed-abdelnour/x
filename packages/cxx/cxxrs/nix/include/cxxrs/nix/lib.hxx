#pragma once

#include <cstdint>
#include <memory>
#include <string>

#include <nix/config.h>
#include <nix/eval.hh>
#include <nix/value.hh>

namespace cxxrs::nix {
  auto display(::nix::EvalState &state, ::nix::Value &value) -> ::std::unique_ptr<::std::string>;

  enum ValueType : uint8_t {};
  constexpr auto value_type(const ::nix::Value &value) -> ValueType {
    return ValueType(value.type(false));
  }
}
