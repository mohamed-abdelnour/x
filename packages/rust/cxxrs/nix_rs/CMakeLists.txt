include(cxxrs/cxxbridge)

cxxrs_cxxbridge_target(
  WITH_HACKS
  NS "cxxrs/nix"
  TARGET_PREFIX cxxrs_nix_rs
  INPUTS lib.rs
)
target_link_libraries(cxxrs_nix_rs.cxx PRIVATE cxxrs_nix.hxx)
