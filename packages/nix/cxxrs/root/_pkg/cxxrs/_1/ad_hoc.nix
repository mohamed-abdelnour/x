{ cxxrs_root }:
{ callPackage, if_ }:
{
  ${if_.isLocal "lto_0"} = (callPackage (cxxrs_root.callPackage ./ad_hoc/lto_0.nix { }) { });
}
