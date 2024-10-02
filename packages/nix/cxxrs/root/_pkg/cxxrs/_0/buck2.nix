# SPDX-License-Identifier: Apache-2.0 OR MIT
# SPDX-FileCopyrightText: © Meta Platforms, Inc. and affiliates <https://github.com/facebook/buck2>
{ _dat }:
{
  autoPatchelfHook,
  fetchurl,
  hostPlatform,
  lib,
  stdenv,
  stdenvNoCC,
  zstd,
}:
assert true || stdenvNoCC;
let
  inherit (hostPlatform.rust) rustcTarget;
in
(
  buck2:
  let
    inherit (buck2) pname version passthru;
  in
  {
    inherit (_dat.buck2) version;
    pname = "buck2";

    src = fetchurl {
      inherit (passthru.drv.src) hash;
      url = "https://github.com/facebook/${pname}/releases/download/${version}/${pname}-${rustcTarget}.zst";
    };

    nativeBuildInputs = [ zstd ];
    buildInputs = [ ];

    unpackPhase = ''
      unzstd "$src" -o "$pname"
    '';

    buildPhase = ''
      chmod +x "$pname"
    '';

    checkPhase = ''
      "$pname" --version
    '';

    installPhase = ''
      mkdir --parents "$out/bin"
      mv "$pname" "$out/bin"
    '';

    meta = {
      mainProgram = pname;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

      license = [
        lib.licenses.asl20 # OR
        lib.licenses.mit
      ];
    };

    passthru.drv.src.hash =
      _dat.buck2.src.hashes.${rustcTarget} or (throw ''
        `passthru.drv.src.hash` must be externally provided

        example: `<DRV>.overrideAttrs { passthru.drv.src.hash = <HASH>; }`
      '');
  }
)
|> lib.extends (
  _: buck2:
  rec {
    aarch64-unknown-linux-gnu = buck2 // {
      nativeBuildInputs = buck2.nativeBuildInputs ++ [ autoPatchelfHook ];
      buildInputs = buck2.buildInputs ++ [ stdenv.cc.cc.lib ];
    };
    x86_64-unknown-linux-gnu = aarch64-unknown-linux-gnu;
  }
  .${rustcTarget} or { }
)
|> stdenvNoCC.mkDerivation
