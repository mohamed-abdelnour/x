{
  ROOT,
  _cfg,
  _lib,
}:
{
  boost,
  cmake,
  cxxrs,
  hostPlatform,
  lib,
  llvmPackages,
  ninja,
  nix,
  pkg-config,
  pkgsBuildHost,
  writeShellScriptBin,
}:
cxxrs._0.stdenv.llvm.clang.mkDerivation {
  inherit (_lib.workspace) version;
  pname = _lib.workspace.memberPname [ "cmake" ];

  src = lib.fileset.toSource {
    root = ROOT;
    fileset = lib.fileset.unions [
      /${ROOT}/CMakeLists.txt
      /${ROOT}/CMakePresets.json
      /${ROOT}/packages/cmake
      /${ROOT}/packages/rust/cxxrs/lto_2_rs/CMakeLists.txt
      /${ROOT}/packages/rust/cxxrs/lto_2_rs/src/lib.rs
      /${ROOT}/packages/rust/cxxrs/nix_rs/CMakeLists.txt
      /${ROOT}/packages/rust/cxxrs/nix_rs/src/lib.rs

      (lib.fileset.fileFilter (
        file:
        # C++
        file.hasExt "cxx"
        || file.hasExt "hxx"
        || file.hasExt "hxx.in"
        # CMake
        || file.name == "CMakeLists.txt"
      ) /${ROOT}/packages/cxx/cxxrs)
    ];
  };

  env.CXXRS_WITH_HACKS = _cfg.opt.ctx.withHacks;

  depsBuildBuild = [ cxxrs._0.cxx.cxxbridge-cmd ];
  nativeBuildInputs = [
    cmake
    llvmPackages.clang-tools
    ninja
    pkg-config
  ];
  buildInputs = [
    boost.dev
    cxxrs._1.cargo._2
    nix.dev
  ];

  configurePhase = ''
    cmake --version
    cmake --preset=nix --install-prefix="$prefix"
    cd target/cmake
  '';

  passthru.tests.nix.driver =
    let
      bin = {
        emulator = hostPlatform.emulator pkgsBuildHost;
        nix = lib.getExe nix;
      };

      libcxxrs_nix = "${cxxrs._1.cmake}/lib/libcxxrs_nix.*";
    in
    pkgsBuildHost.writeShellScriptBin
      (_lib.workspace.concatStrings [
        cxxrs._1.cmake.pname
        "tests"
        "nix"
        "driver"
      ])
      ''
        exec ${bin.emulator} ${bin.nix} --extra-plugin-files ${libcxxrs_nix} "$@"
      '';
}
