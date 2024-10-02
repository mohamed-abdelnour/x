if(NOT _CXXRS_RUNNING_UNDER_NIX)
  add_library(cxxrs_lto_1_rs STATIC IMPORTED)
  set_target_properties(
    cxxrs_lto_1_rs
    PROPERTIES
      IMPORTED_LOCATION "${CXXRS_CARGO_TARGET_DIR}/libcxxrs_lto_1_rs.a"
      IMPORTED_LOCATION_DEBUG "${CXXRS_CARGO_TARGET_DIR_DEBUG}/libcxxrs_lto_1_rs.a"
  )
endif()

add_executable(cxxrs_lto_1 src/main.cxx)
target_link_libraries(cxxrs_lto_1 PRIVATE cxxrs_lto_1_rs)
install(TARGETS cxxrs_lto_1)
