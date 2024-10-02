{ cxxrs_root }:
{ callPackage }:
{
  recipes = callPackage (cxxrs_root.callPackage ./stdenv/recipes.nix { }) { };

  # SPDX-SnippetBegin
  # SPDX-License-Identifier: MIT
  # SPDX-SnippetCopyrightText: © 2003 Eelco Dolstra and the Nixpkgs/NixOS contributors <https://github.com/NixOS/nixpkgs>
  # SPDX-SnippetComment:
  # <text>
  #   This was adapted from [Nixpkgs][0].
  #
  #   <!-- prettier-ignore -->
  #   [0]: https://github.com/NixOS/nixpkgs/blob/e5330a9a58dfae92df814013e90509dbae747ce9/pkgs/stdenv/adapters.nix#L11-L24
  # </text>
  overrideAttrs =
    ext: stdenv:
    stdenv.override (args: {
      mkDerivationFromStdenv =
        stdenv:
        let
          mkDerivation = args.mkDerivationFromStdenv stdenv;
        in
        drv: (mkDerivation drv).overrideAttrs ext;
    });
  # SPDX-SnippetEnd
}
