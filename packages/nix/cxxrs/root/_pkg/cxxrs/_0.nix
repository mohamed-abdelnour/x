{ cxxrs_root }:
{ callPackage }:
{
  buck2 = callPackage (cxxrs_root.callPackage ./_0/buck2.nix { }) { };
  cmake = callPackage (cxxrs_root.callPackage ./_0/cmake.nix { }) { };
  crane = callPackage (cxxrs_root.callPackage ./_0/crane.nix { }) { };
  cxx = callPackage (cxxrs_root.callPackage ./_0/cxx.nix { }) { };
  jq = callPackage (cxxrs_root.callPackage ./_0/jq.nix { }) { };
  lib = callPackage (cxxrs_root.callPackage ./_0/lib.nix { }) { };
  rust = callPackage (cxxrs_root.callPackage ./_0/rust.nix { }) { };
  sccache = callPackage ./_0/sccache.nix { };
  stdenv = callPackage ./_0/stdenv.nix { };
}
