{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  outputs =
    { nixpkgs, self }:
    let
      PROJECT = "lifehash";
      SYSTEM = "x86_64-linux";
      VERSION = "0.1.0";

      pkgs = import "${nixpkgs}/pkgs/top-level" { localSystem = SYSTEM; };
    in
    {
      devShells.${SYSTEM}.default = pkgs.callPackage (
        {
          _self,
          llvmPackages,
          mkShell,
          nixfmt-rfc-style,
          openssl,
          ruff,
        }:
        mkShell.override { inherit (llvmPackages) stdenv; } {
          name = "${PROJECT}.sh-${VERSION}";
          inputsFrom = builtins.attrValues _self;
          packages = [
            _self.default
            nixfmt-rfc-style
            openssl
            ruff
          ];
        }
      ) { _self = self.packages.${SYSTEM}; };

      packages.${SYSTEM}.default = pkgs.callPackage (
        {
          cmake,
          fetchFromGitHub,
          lib,
          llvmPackages,
          ninja,
          python3Packages,
        }:
        let
          lifehash = llvmPackages.stdenv.mkDerivation {
            __structuredAttrs = true;
            strictDeps = true;

            pname = PROJECT;
            version = VERSION;

            outputs = [
              "out"
              "dev"
            ];

            src = fetchFromGitHub {
              owner = "BlockchainCommons";
              repo = "bc-lifehash";
              rev = "0.4.1";
              hash = "sha512-CCPFt7N6HJdiDSJ6D/0KQ7Ef2scJREXTVLEVeGP/uq+UX9Wj4K7nYL5veDjxum62hQQYvaN8/bfRgQ65diSo2g==";
            };

            preConfigure = ''
              . tasks.sh
            '';

            postPatch = ''
              sed --in-place '1i#include <cstring>' src/lifehash.cpp
              sed --in-place '1i#include <stdexcept>' src/hex.cpp
            '';

            # SPDX-SnippetBegin
            # SPDX-License-Identifier: LicenseRef-BSD-2-Clause-Patent.0
            meta.license = lib.licenses.bsd2Patent;
            # SPDX-SnippetEnd
          };
        in
        python3Packages.buildPythonPackage {
          inherit (llvmPackages) stdenv;
          strictDeps = true;

          pname = PROJECT;
          version = VERSION;

          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./CMakeLists.txt
              ./CMakePresets.json
              ./pyproject.toml
              ./src
            ];
          };

          pyproject = true;
          dontUseCmakeConfigure = true;

          build-system = [
            cmake
            llvmPackages.clang-tools
            ninja
            python3Packages.pybind11
            python3Packages.scikit-build-core
          ];

          buildInputs = [ lifehash.dev ];
          dependencies = [
            python3Packages.numpy
            python3Packages.pillow
          ];
        }
      ) { };
    };
}
