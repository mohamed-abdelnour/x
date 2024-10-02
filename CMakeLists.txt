cmake_minimum_required(VERSION 3.29)
project(cxxrs VERSION 0.1.0 LANGUAGES CXX)

add_subdirectory(packages/cxx/cxxrs/lto_1)
add_subdirectory(packages/cxx/cxxrs/lto_2)
add_subdirectory(packages/cxx/cxxrs/nix)
add_subdirectory(packages/rust/cxxrs/lto_2_rs)
add_subdirectory(packages/rust/cxxrs/nix_rs)

file(
  CREATE_LINK
  "${CMAKE_BINARY_DIR}/compile_commands.json"
  "${CMAKE_SOURCE_DIR}/compile_commands.json"
  SYMBOLIC
)

file(
  GENERATE
  OUTPUT .clang-tidy
  CONTENT "Checks: []"
)
