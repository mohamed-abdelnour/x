include(cxxrs/third_party)

block(SCOPE_FOR VARIABLES)
  add_library(cxxrs_nix.hxx INTERFACE include/cxxrs/nix/lib.hxx)

  configure_file(src/gen/project.hxx.in cxxrs/nix/gen/project.hxx @ONLY)
  target_include_directories(cxxrs_nix.hxx INTERFACE "${CMAKE_CURRENT_BINARY_DIR}" include)

  # This is a workaround for the include flags of `nix-expr` being inconsistent.
  #
  # Compare:
  #
  # - `         pkg-config`: `$NIX_STORE/<DRV>/include/nix`; and
  # - `$NIX_CFLAGS_COMPILE`: `$NIX_STORE/<DRV>/include`.
  #
  # We _want_ the latter (to refer to the headers as `<nix/...>` in our code); but
  # we _need_ the former, too. This is also why we can't rely on the value injected
  # through `$NIX_CFLAGS_COMPILE` elsewhere; notice that the [(optional) build
  # script on the Rust side][0] adds the `pkg-config` flags.
  #
  # [0]: ../../../rust/cxxrs/nix_rs/build.rs
  set(nix-expr.I "$<TARGET_PROPERTY:cxxrs::_::nix-expr,INTERFACE_INCLUDE_DIRECTORIES>")
  target_include_directories(
    cxxrs_nix.hxx
    SYSTEM
    INTERFACE "$<LIST:TRANSFORM,${nix-expr.I},REPLACE,^(.+)(/nix)$,\\1;\\1\\2>"
  )
endblock()

add_library(cxxrs_nix SHARED "$<TARGET_OBJECTS:cxxrs_nix_rs.cxx>" src/lib.cxx)
target_link_libraries(
  cxxrs_nix
  PRIVATE
    cxxrs::_::boost
    cxxrs::_::nix-expr
    cxxrs::_::nlohmann_json

    cxxrs_nix.hxx
    cxxrs_nix_rs
    cxxrs_nix_rs.hxx
)
install(TARGETS cxxrs_nix)
