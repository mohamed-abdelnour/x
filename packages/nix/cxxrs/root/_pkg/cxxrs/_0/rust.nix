{ ROOT, inputs }:
{
  gnused,
  lib,
  pkgsBuildHost,
  symlinkJoin,
  wrapRustc,
  writeShellScriptBin,
}:
let
  # `rust-overlay` expects build tools to run under `hostPlatform` and build for
  # `targetPlatform`, and the documented cross-compilation workflow relies on
  # emulation. This constructs `rustBin` with `pkgsBuildHost` instead to run build
  # tools under `buildPlatform` (with access to the target's `rust-std`) and build
  # for `hostPlatform`.
  rustBin = inputs.rust-overlay.lib.mkRustBin { } pkgsBuildHost;
  rustToolchain = rustBin.fromRustupToolchainFile /${ROOT}/rust-toolchain.toml;
in
rec {
  _0 = rustToolchain;

  _1 = (wrapRustc rustToolchain).overrideAttrs {
    meta = { };
    passthru.unwrapped = _0;
  };

  _2 =
    let
      bin = {
        gnused = lib.getExe gnused;
        rustc = lib.getExe' _1 "rustc";
      };

      sedScript =
        let
          llvmGold = "${lib.getLib pkgsBuildHost.cxxrs.llvmPackages.libllvm}/lib/LLVMgold.so";
        in
        ''''\'s:(-C\s*|--codegen(=|\s+))(linker-plugin-lto):\1\3=${llvmGold}:g''\''';
    in
    symlinkJoin {
      inherit (_1) name;
      paths = [
        (writeShellScriptBin "rustc" ''
          if [[ "$("$LD" --version)" == LLD* ]]; then
              exec ${bin.rustc} "$@"
          else
              _rustc() { exec ${bin.rustc} "@$1"; }
              _rustc <(${bin.gnused} -E ${sedScript} < <(printf '%s\n' "$@"))
          fi
        '')
        _1
      ];
    };
}
