include_guard(GLOBAL)

include(cxxrs/third_party)

function(_cxxbridge input cxx hxx with_hacks)
  if(with_hacks AND CXXRS_WITH_HACKS)
    set(sed sed)
  else()
    set(sed ":")
  endif()

  add_custom_command(
    DEPENDS "${input}"
    OUTPUT "${cxx}" "${hxx}"
    COMMAND cxxbridge --output="${cxx}" "${input}"
    COMMAND cxxbridge --header --output="${hxx}" "${input}"
    COMMAND "${sed}" --in-place -E [['s/^(.+\$$cxxbridge.+\$$.+)noexcept\s*(\{)$$/\1\2/']] "${cxx}"
  )
endfunction()

function(cxxrs_cxxbridge_target)
  cmake_parse_arguments(PARSE_ARGV 0 _ "WITH_HACKS" "NS;TARGET_PREFIX" "INPUTS")

  set(_src.cxx "cxx")
  set(_src.hxx "hxx")
  list(TRANSFORM __INPUTS REPLACE "^(.+)$" "${_src.cxx}/${__NS}/\\1.cxx" OUTPUT_VARIABLE cxxs)
  list(TRANSFORM __INPUTS REPLACE "^(.+)$" "${_src.hxx}/${__NS}/\\1.hxx" OUTPUT_VARIABLE hxxs)

  foreach(_input _cxx _hxx IN ZIP_LISTS __INPUTS cxxs hxxs)
    _cxxbridge("${CMAKE_CURRENT_SOURCE_DIR}/src/${_input}" "${_cxx}" "${_hxx}" "${__WITH_HACKS}")
  endforeach()

  # Headers and implementation sources are separated into two libraries to avoid
  # cyclic dependencies. That is: let `_0` be a target; we separate `${_target.hxx}`
  # and `${_target.cxx}` so that `_0` may depend on `${_target.hxx}` with
  # `${_target.cxx}` depending on `_0`.

  set(_target.hxx "${__TARGET_PREFIX}.hxx")
  add_library("${_target.hxx}" INTERFACE "${hxxs}")
  target_link_libraries("${_target.hxx}" INTERFACE cxxrs::_::cxx::rust)
  target_include_directories(
    "${_target.hxx}"
    SYSTEM
    INTERFACE "${CMAKE_CURRENT_BINARY_DIR}/${_src.hxx}"
  )

  set(_target.cxx "${__TARGET_PREFIX}.cxx")
  add_library("${_target.cxx}" OBJECT "${cxxs}")
  target_link_libraries("${_target.cxx}" PUBLIC "${_target.hxx}")

  # If we're running under Nix, then `-L<PATH_TO_BUILD_INPUT_DIR>` is injected into
  # the compiler's command line; thus, we want CMake to add `-l<BUILD_INPUT>`. CMake
  # does so if `<BUILD_INPUT>` is a plain library name; that's why we _don't_ define
  # a target for `<BUILD_INPUT>` if we're running under Nix.
  if(NOT _CXXRS_RUNNING_UNDER_NIX)
    add_library("${__TARGET_PREFIX}" STATIC IMPORTED GLOBAL)
    set_target_properties(
      "${__TARGET_PREFIX}"
      PROPERTIES
        IMPORTED_LOCATION "${CXXRS_CARGO_TARGET_DIR}/lib${__TARGET_PREFIX}.a"
        IMPORTED_LOCATION_DEBUG "${CXXRS_CARGO_TARGET_DIR_DEBUG}/lib${__TARGET_PREFIX}.a"
    )
  endif()
endfunction()
