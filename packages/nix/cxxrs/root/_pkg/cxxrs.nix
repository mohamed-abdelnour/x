{ _cfg, cxxrs_root }:
nixpkgs@{
  generateSplicesForMkScope,
  llvmPackages_18,
  makeScopeWithSplicing',
  nixVersions,
  # Make these available under `nixpkgs`.
  cmake,
  stdenv,
  stdenvNoCC,
}:
makeScopeWithSplicing' {
  otherSplices = generateSplicesForMkScope "cxxrs";
  f = cxxrs: {
    inherit (cxxrs.stdenvNoCC.cfg) if_;
    inherit nixpkgs;

    ${_cfg.if_.cmake.useLatest "cmake"} = cxxrs._0.cmake;
    llvmPackages = llvmPackages_18;
    nix = nixVersions.latest;
    stdenv = cxxrs._0.stdenv.default;
    stdenvNoCC = cxxrs._0.stdenv.noCC;

    _0 = cxxrs.callPackage (cxxrs_root.callPackage ./cxxrs/_0.nix { }) { };
    _1 = cxxrs.callPackage (cxxrs_root.callPackage ./cxxrs/_1.nix { }) { };
  };
}
