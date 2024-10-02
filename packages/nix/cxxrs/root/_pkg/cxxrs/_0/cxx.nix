# SPDX-License-Identifier: Apache-2.0 OR MIT
# SPDX-FileCopyrightText: NOASSERTION <https://github.com/dtolnay/cxx>
{ _dat }:
{
  cxxrs,
  fetchFromGitHub,
  lib,
}:
{
  cxxbridge-cmd = cxxrs._0.crane.buildPackage {
    inherit (_dat.cxx) cargoLock;

    src = fetchFromGitHub {
      inherit (_dat.cxx.src) hash rev;
      owner = "dtolnay";
      repo = "cxx";
    };

    cargoExtraArgs = toString [
      "--frozen"
      "--package=cxxbridge-cmd"
    ];

    meta = {
      mainProgram = "cxxbridge";

      license = [
        lib.licenses.asl20
        lib.licenses.mit
      ];
    };
  };
}
