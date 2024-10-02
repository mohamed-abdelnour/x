{
  cxxrs,
  gnused,
  lib,
  nix,
  writeShellScriptBin,
}:
let
  bin = builtins.mapAttrs (_: lib.getExe) {
    inherit (cxxrs._0) jq;
    inherit gnused nix;
  };
in
writeShellScriptBin "cxxrs_nix_derivation_env_vars" ''
  set -o pipefail

  ${bin.nix} derivation show "''${@/#/.#_."test=true".}" |
      ${bin.jq} 'import "cxxrs/nix" as _; _::derivation_env_vars' |
      ${bin.gnused} "s:''${NIX_STORE:-/nix/store}:\$NIX_STORE:g"
''
