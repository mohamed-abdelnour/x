{
  _lib,
  _pkg,
  inputs,
}:
{ cxxrs }:
(inputs.crane.mkLib _pkg.nix).overrideScope (
  crane': crane: {
    stdenv = cxxrs._0.stdenv.cargo.crane.rust.llvm.clang;

    rustc = _lib.id.asserting (x: crane'.stdenv.cfg.opt.isCross -> x ? __spliced) cxxrs._0.rust._2;
    cargo = crane'.rustc;
    clippy = crane'.rustc;
    rustfmt = crane'.rustc;

    mkCargoDerivation =
      drv:
      let
        stdenv = drv.stdenv or crane'.stdenv;
        isSpliced = stdenv ? __spliced;

        drvExt.${_lib.cfg isSpliced "depsBuildBuild"} = drv.depsBuildBuild or [ ] ++ [
          stdenv.__spliced.buildBuild.cc
        ];
      in
      crane.mkCargoDerivation <| drv // drvExt;
  }
)
