#include <array>
#include <memory>
#include <sstream>
#include <string>
#include <string_view>

#include <nix/config.h>
#include <nix/eval-error.hh>
#include <nix/eval.hh>
#include <nix/pos-idx.hh>
#include <nix/primops.hh>
#include <nix/print-options.hh>
#include <nix/value.hh>
#include <rust/cxx.h>

#include <cxxrs/nix/gen/project.hxx>
#include <cxxrs/nix/lib.hxx>
#include <cxxrs/nix/lib.rs.hxx>

namespace cxxrs::nix {
  constexpr ::nix::PrintOptions DISPLAY_OPTIONS({
      .ansiColors = true,
      .maxDepth = 10,
      .maxAttrs = 10,
      .maxListItems = 10,
      .maxStringLength = 1024,
      .prettyIndent = 2,
  });
  auto display(::nix::EvalState &state, ::nix::Value &value) -> ::std::unique_ptr<::std::string> {
    ::std::ostringstream buf;
    value.print(state, buf, DISPLAY_OPTIONS);
    return ::std::make_unique<::std::string>(buf.str());
  }
}

namespace {
  ::std::string NAME(CXXRS_PROJECT_NAME);

  class Module {
    static constexpr ::std::string_view SEPARATOR = "::";

  public:
    ::std::string_view name;

    constexpr Module(const ::std::string_view name) {
      this->name = name;
      NAME += SEPARATOR;
      NAME += name;
    }

    constexpr ~Module() {
      NAME.erase(NAME.length() - SEPARATOR.length() - this->name.length());
    }
  };

  namespace cxxrs::fib {
    auto
    _0(::nix::EvalState &state, const ::nix::PosIdx pos, ::nix::Value **args,
       ::nix::Value &result) {
      auto n = state.forceInt(*args[0], pos, "while evaluating: [0]");
      result.mkInt(::cxxrs::nix::fib_0(n));
    }

    auto
    _1(::nix::EvalState &state, const ::nix::PosIdx pos, ::nix::Value **args,
       ::nix::Value &result) {
      try {
        ::cxxrs::nix::fib_1(state, pos, args, result);
      } catch (::rust::Error &err) {
        state.error<::nix::EvalError>(err.what()).atPos(pos).debugThrow();
      }
    }

    auto init(::nix::EvalState &state, const ::nix::PosIdx pos) -> ::nix::Bindings * {
      constexpr ::std::array SYMBOLS{
          /* 0 */ "_0",
          /* 1 */ "_1",
      };

      auto mod = state.buildBindings(SYMBOLS.size());
      {
        const Module cursor(SYMBOLS[0]);
        mod.alloc(cursor.name, pos)
            .mkPrimOp(new ::nix::PrimOp{
                .name = NAME,
                .arity = 1,
                .fun = _0,
            });
      }
      {
        const Module cursor(SYMBOLS[1]);
        mod.alloc(cursor.name, pos)
            .mkPrimOp(new ::nix::PrimOp{
                .name = NAME,
                .arity = 1,
                .fun = _1,
            });
      }
      return mod.finish();
    }
  }

  namespace cxxrs::ptr {
    auto
    eq(::nix::EvalState &state, const ::nix::PosIdx pos, ::nix::Value **args,
       ::nix::Value &result) {
      auto *a = args[0];
      state.forceValue(*a, pos);
      auto *b = args[1];
      state.forceValue(*b, pos);
      result.mkBool(::cxxrs::nix::ptr_eq(a, b));
    }

    auto init(::nix::EvalState &state, const ::nix::PosIdx pos) -> ::nix::Bindings * {
      constexpr ::std::array SYMBOLS{
          /* 0 */ "eq",
      };

      auto mod = state.buildBindings(SYMBOLS.size());
      {
        const Module cursor(SYMBOLS[0]);
        mod.alloc(cursor.name, pos)
            .mkPrimOp(new ::nix::PrimOp{
                .name = NAME,
                .arity = 2,
                .fun = eq,
            });
      }
      return mod.finish();
    }
  }

  namespace cxxrs {
    auto init(::nix::EvalState &state, const ::nix::PosIdx pos) -> ::nix::Bindings * {
      constexpr ::std::array SYMBOLS{
          /* 0 */ "VERSION",
          /* 1 */ "fib",
          /* 2 */ "ptr",
      };

      auto mod = state.buildBindings(SYMBOLS.size());
      {
        const Module cursor(SYMBOLS[0]);
        mod.alloc(cursor.name, pos).mkString(CXXRS_PROJECT_VERSION);
      }
      {
        const Module cursor(SYMBOLS[1]);
        mod.alloc(cursor.name, pos).mkAttrs(fib::init(state, pos));
      }
      {
        const Module cursor(SYMBOLS[2]);
        mod.alloc(cursor.name, pos).mkAttrs(ptr::init(state, pos));
      }
      return mod.finish();
    }
  }

  const ::nix::RegisterPrimOp $({
      .name = "__" + NAME,
      .arity = 0,
      .fun =
          [](::nix::EvalState &state, const ::nix::PosIdx pos, ::nix::Value **,
             ::nix::Value &result) {
            result.mkAttrs(cxxrs::init(state, pos));
          },
  });
}
