{
  _cfg,
  _pkg,
  cxxrs_root,
  inputs,
}:
{
  nix = import "${inputs.nixpkgs}/pkgs/top-level" _cfg.opt.nixpkgs;

  overlay = pkgs: _: {
    cxxrs = pkgs.callPackage (cxxrs_root.callPackage ./_pkg/cxxrs.nix { }) { };
  };

  cxxrs =
    let
      # If we don't know the local system, there is nothing to expose but debug
      # information (if requested).
      cxxrsNoSys.${_cfg.if_.debug "_"} = cxxrs_root;
    in
    if _cfg.opt ? nixpkgs.localSystem then _pkg.nix.cxxrs._1 else cxxrsNoSys;
}
