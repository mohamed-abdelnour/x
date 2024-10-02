{
  ROOT,
  _cfg,
  _lib,
}:
{ cxxrs, lib }:
let
  inherit (cxxrs._0) crane;

  cargoExtensibleAttrs =
    let
      fromStatic =
        static: drv:
        static
        // {
          cargoArtifacts = crane.buildDepsOnly drv;
          ${_cfg.if_.debug "passthru"} = ({ inherit drv; });
        };
    in
    fromStatic {
      pname = _lib.workspace.memberPname [ "cargo" ];

      cargoExtraArgs = "--frozen";

      src = lib.fileset.toSource {
        root = ROOT;
        fileset = lib.fileset.unions [
          /${ROOT}/.cargo
          /${ROOT}/Cargo.lock
          /${ROOT}/Cargo.toml
          /${ROOT}/packages/rust/_0/reindeer/Cargo.toml
          /${ROOT}/packages/rust/_0/reindeer/src

          (lib.fileset.fileFilter (
            file:
            # Rust
            file.hasExt "rs"
            # Cargo
            || file.name == "Cargo.toml"
          ) /${ROOT}/packages/rust/cxxrs)
        ];
      };
    };
in
{
  _0 =
    lib.extends (_: drv: {
      pname = _lib.workspace.concatStrings [
        drv.pname
        "_0"
      ];

      cargoExtraArgs = toString [
        drv.cargoExtraArgs
        "--package=cxxrs_dev"
      ];
    }) cargoExtensibleAttrs
    |> lib.fix
    |> crane.buildPackage;

  _1 =
    lib.extends (_: drv: {
      pname = _lib.workspace.concatStrings [
        drv.pname
        "_1"
      ];

      env.CARGO_PROFILE = "release_panic_unwind";
      cargoExtraArgs = toString [
        drv.cargoExtraArgs
        "--package=cxxrs_trycmd"
      ];
    }) cargoExtensibleAttrs
    |> lib.fix
    |> crane.buildPackage;

  _2 =
    lib.extends (_: drv: {
      pname = _lib.workspace.concatStrings [
        drv.pname
        "_2"
      ];

      dontStrip = true;

      cargoExtraArgs = toString [
        drv.cargoExtraArgs
        "--config='${ROOT + /.cargo/lto.toml}'"
        "--package=cxxrs_lto_1_rs"
        "--package=cxxrs_lto_2_rs"
        "--package=cxxrs_nix_rs"
      ];
    }) cargoExtensibleAttrs
    |> lib.fix
    |> crane.buildPackage;
}
