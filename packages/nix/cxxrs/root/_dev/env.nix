rec {
  localSystem = "_.nixpkgs/localSystem='${builtins.currentSystem}'";
  installables.default = ".#${localSystem}.packages.barrel";
}
