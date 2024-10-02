include_guard(GLOBAL)

find_package(Boost CONFIG REQUIRED QUIET)
find_package(nlohmann_json CONFIG REQUIRED QUIET)

find_package(PkgConfig REQUIRED QUIET)
pkg_check_modules(nix-expr REQUIRED IMPORTED_TARGET QUIET nix-expr)

block(SCOPE_FOR VARIABLES)
  set(include "${CMAKE_BINARY_DIR}/include/cxx")
  set(cxx.rust.hxx "${include}/rust/cxx.h")
  add_custom_command(
    OUTPUT "${cxx.rust.hxx}"
    COMMAND cxxbridge --header --output "${cxx.rust.hxx}"
  )
  add_library(_cxx.rust INTERFACE "${cxx.rust.hxx}")
  target_include_directories(_cxx.rust INTERFACE "${include}")
endblock()

add_library(cxxrs::_::boost ALIAS Boost::boost)
add_library(cxxrs::_::cxx::rust ALIAS _cxx.rust)
add_library(cxxrs::_::nix-expr ALIAS PkgConfig::nix-expr)
add_library(cxxrs::_::nlohmann_json ALIAS nlohmann_json::nlohmann_json)
