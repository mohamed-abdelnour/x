add_library(cxxrs_lto_2.hxx INTERFACE include/cxxrs/lto_2/lib.hxx)
target_include_directories(cxxrs_lto_2.hxx INTERFACE include)

add_executable(cxxrs_lto_2 "$<TARGET_OBJECTS:cxxrs_lto_2_rs.cxx>" src/main.cxx)
target_link_libraries(cxxrs_lto_2 PRIVATE cxxrs_lto_2.hxx cxxrs_lto_2_rs cxxrs_lto_2_rs.hxx)
install(TARGETS cxxrs_lto_2)
