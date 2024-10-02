{ cxxrs_root }:
{ callPackage }:
{
  stdenv = callPackage (cxxrs_root.callPackage ./lib/stdenv.nix { }) { };
}
