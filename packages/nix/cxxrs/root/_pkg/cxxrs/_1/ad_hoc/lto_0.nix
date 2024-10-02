{
  ROOT,
  _cfg,
  _lib,
}:
{ cxxrs, ninja }:
let
  stdenv = cxxrs._0.stdenv.mold.rust.llvm.clang;
in
stdenv.mkDerivation {
  inherit (_lib.workspace) version;
  pname = _lib.workspace.memberPname [
    "ad_hoc"
    "lto_0"
  ];

  src = /${ROOT}/packages/_/ad_hoc/lto_0;

  env.${_cfg.if_.ctx.useFullLto "_CXXRS_LTO"} = "full";

  nativeBuildInputs = [
    cxxrs._0.rust._2
    ninja
  ];

  installPhase = ''
    mv target/artifact "$out"
  '';
}
