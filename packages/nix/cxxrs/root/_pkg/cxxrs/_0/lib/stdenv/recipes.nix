{ _cfg, _lib }:
{
  cxxrs,
  lib,
  stdenvAdapters,
}:
let
  inherit (cxxrs._0.lib.stdenv) overrideAttrs;
in
{
  base =
    stdenv:
    stdenv.override {
      extraAttrs = lib.fix (extraAttrs: {
        cfg = {
          opt = rec {
            isLocal = stdenv.buildPlatform == stdenv.hostPlatform;
            isCross = !isLocal;
            withNative = _cfg.opt.native && isLocal;
          };

          if_ = builtins.mapAttrs (_: _lib.cfg) extraAttrs.cfg.opt;
        };
      });
    }
    |> stdenvAdapters.addAttrsToDerivation {
      __structuredAttrs = true;
      strictDeps = true;
    };

  cc =
    stdenv:
    if stdenv.cfg.opt.withNative then stdenvAdapters.impureUseNativeOptimizations stdenv else stdenv;

  llvm =
    llvm: stdenv:
    if stdenv.cfg.opt.isLocal && stdenv.cc.libc == llvm.bintools.libc then
      stdenvAdapters.overrideCC stdenv <| stdenv.cc.override { inherit (llvm) bintools; }
    else
      stdenv;

  cargo =
    stdenv:
    let
      inherit (stdenv) hostPlatform;
      drv.env = {
        CARGO_BUILD_TARGET = hostPlatform.rust.rustcTargetSpec;

        ${stdenv.cfg.if_.isCross "CARGO_TARGET_${hostPlatform.rust.cargoEnvVarTarget}_LINKER"} = # $
          "${stdenv.cc.targetPrefix}cc";
      };
    in
    overrideAttrs (_: lib.recursiveUpdate drv) stdenv;

  crane = stdenvAdapters.addAttrsToDerivation {
    doCheck = false;
  };

  mold =
    stdenv:
    if _cfg.opt.ctx.linker.allowNonLld && stdenv.cfg.opt.isLocal && stdenv.isLinux then
      stdenvAdapters.useMoldLinker stdenv
    else
      stdenv;

  rust =
    stdenv:
    overrideAttrs (
      drv': drv:
      lib.recursiveUpdate {
        env.NIX_RUSTFLAGS =
          let
            inherit (stdenv.hostPlatform.rust) rustcTargetSpec;

            hasRustflags = drv ? env.NIX_RUSTFLAGS;
            needsTarget = !drv' ? env.CARGO_BUILD_TARGET && stdenv.cfg.opt.isCross;
          in
          builtins.attrValues {
            ${_lib.cfg hasRustflags "_0"} = drv.env.NIX_RUSTFLAGS;

            _00 = "-Zlinker-features=-lld";

            ${stdenv.cfg.if_.withNative "_1"} = "--codegen=target-cpu=native";
            ${_lib.cfg needsTarget "_2"} = "--target=${rustcTargetSpec}";
          }
          |> toString;
      } drv
    ) stdenv;
}
