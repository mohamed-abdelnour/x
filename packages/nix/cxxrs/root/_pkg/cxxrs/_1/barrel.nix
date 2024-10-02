{
  _cfg,
  _lib,
  inputs,
}:
{
  cxxrs,
  lib,
  mkShell,
  pkgsBuildHost,
}:
mkShell.override { stdenv = cxxrs._0.stdenv.rust.llvm.clang; } {
  name = _lib.workspace.memberName [ "barrel" ];

  env.NIX_PATH = "nixpkgs=${inputs.nixpkgs}";

  inputsFrom =
    lib.take _cfg.opt.shell.sizeBracket [
      [ cxxrs._1.cmake ]
    ]
    |> builtins.concatLists;

  packages =
    let
      _0 = cxxrs._0.sccache;
    in
    lib.take _cfg.opt.shell.sizeBracket [
      [
        _0
        cxxrs._0.buck2
        cxxrs._0.cxx.cxxbridge-cmd
        cxxrs._0.jq
        cxxrs._0.rust._1
        cxxrs._1.cargo._0
        cxxrs._1.cargo._1
        cxxrs._1.nix_derivation_env_vars
        pkgsBuildHost.asciidoctor
        pkgsBuildHost.deadnix
        pkgsBuildHost.nixfmt-rfc-style
        pkgsBuildHost.nodePackages_latest.prettier
        pkgsBuildHost.python3
        pkgsBuildHost.reindeer
        pkgsBuildHost.reuse
        pkgsBuildHost.ruff
        pkgsBuildHost.rust-analyzer
        pkgsBuildHost.shellcheck
        pkgsBuildHost.shfmt
        pkgsBuildHost.taplo
        pkgsBuildHost.watchman
      ]
      [ pkgsBuildHost.qemu ]
    ]
    |> builtins.concatLists;
}
