{
  _stdenvHook ? lib.id,
  cxxrs,
  lib,
  llvmPackages,
}:
let
  inherit (cxxrs._0.lib.stdenv) recipes;

  composeWithHook =
    adaptor:
    cxxrs._0.stdenv.override {
      _stdenvHook = stdenv: adaptor stdenv |> _stdenvHook;
    };
in
{
  cargo = composeWithHook recipes.cargo;
  crane = composeWithHook recipes.crane;
  mold = composeWithHook recipes.mold;
  rust = composeWithHook recipes.rust;

  noCC = recipes.base cxxrs.nixpkgs.stdenvNoCC |> _stdenvHook;

  default = recipes.base cxxrs.nixpkgs.stdenv |> recipes.cc |> _stdenvHook;

  llvm.clang =
    recipes.base llvmPackages.stdenv |> recipes.cc |> recipes.llvm llvmPackages |> _stdenvHook;
}
