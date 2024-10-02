include(cxxrs/cxxbridge)

cxxrs_cxxbridge_target(
  WITH_HACKS
  NS "cxxrs/lto_2"
  TARGET_PREFIX cxxrs_lto_2_rs
  INPUTS lib.rs
)
target_link_libraries(cxxrs_lto_2_rs.cxx PRIVATE cxxrs_lto_2.hxx)
