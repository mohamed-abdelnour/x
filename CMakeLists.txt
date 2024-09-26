cmake_minimum_required(VERSION 3.29.6)
project("${SKBUILD_PROJECT_NAME}" VERSION "${SKBUILD_PROJECT_VERSION}" LANGUAGES CXX)

file(
  CREATE_LINK
  "${CMAKE_BINARY_DIR}/compile_commands.json"
  "${CMAKE_SOURCE_DIR}/compile_commands.json"
  SYMBOLIC
)

find_package(pybind11 CONFIG REQUIRED)

pybind11_add_module(ffi src/lifehash/ffi.cxx)
target_link_libraries(ffi PRIVATE lifehash)
install(TARGETS ffi LIBRARY DESTINATION "${PROJECT_NAME}")
