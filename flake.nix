{
  inputs = {
    crane.url = "github:ipetkov/crane";
    cxxrs_cfg.url = "path:packages/nix/cxxrs/cfg/";
    nixpkgs.url = "github:NixOS/nixpkgs/e5330a9a58dfae92df814013e90509dbae747ce9";
    rust-overlay.url = "github:oxalica/rust-overlay";

    cxxrs_cfg.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    _:
    let
      inherit (builtins) nixVersion;

      nixNeedsUpgrade =
        let
          x =
            builtins.compareVersions nixVersion "2.24.6"
            |> builtins.bitXor (builtins.compareVersions nixVersion "2.24");
        in
        # There should only be one valid case where `x < 0` (in which `x == -2`); still,
        # checking the weaker requirement assumes less.
        x < 0;

      nixVersionRequirementHint = ''

        unsatisfied version requirement: nix (Nix)
          required: >=2.24.6
           current: ${nixVersion}
      '';
    in
    # If I ever share this project publicly, I would _explicitly_ point out that Nix
    # `2.24+` is required. This guards against that leading to someone accidentally
    # using a vulnerable version of Nix (which can easily happen if they get Nix
    # through `nixpkgs#nixVersions.nix_2_24` and that `nixpkgs` has Nix `>=2.24.0,
    # <2.24.6`, for example).
    if nixNeedsUpgrade then
      abort nixVersionRequirementHint

    else
      import ./packages/nix/cxxrs _;
}
