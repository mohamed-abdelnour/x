inputs:
let
  inherit (inputs) cxxrs_cfg;
  inherit (inputs.nixpkgs) lib;

  cxxrs =
    cxxrs:
    let
      cxxrs_root = lib.makeScope lib.callPackageWith (cxxrs_root: {
        inherit inputs lib;
        inherit cxxrs cxxrs_root;

        ROOT = ../../..;

        _cfg = cxxrs_root.callPackage ./root/_cfg.nix { };
        _dat = import ./root/_dat.nix;
        _lib = cxxrs_root.callPackage ./root/_lib.nix { };
        _pkg = cxxrs_root.callPackage ./root/_pkg.nix { };

        _.packages = cxxrs_root._pkg.cxxrs;
      });
    in
    {
      # Ensure `cxxrs_root` is _only_ evaluated for these fields to keep applying
      # configuration transitions inexpensive. That is, the goal is to not evaluate
      # `cxxrs_root` at all while we're building up the configuration, then evaluate it
      # once when any of these fields is accessed.
      inherit (cxxrs_root._) packages;

      __state__ = _: cxxrs_cfg.options;

      ${cxxrs_cfg.keys.TRANSITION} = builtins.mapAttrs (
        _: tr:
        (_: cxxrs: { __state__ = lib.extends tr cxxrs.__state__; })
        |> (ext: lib.extends ext cxxrs.__unfix__ |> lib.fix')
      ) cxxrs_cfg.transitions;
    };
in
# Sanitise the "top-level" for a cleaner `nix flake show` (and others).
builtins.removeAttrs (lib.fix' cxxrs) [
  "__state__"
  "__unfix__"
]
