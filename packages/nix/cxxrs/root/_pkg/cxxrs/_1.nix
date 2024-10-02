{ _cfg, cxxrs_root }:
{
  callPackage,
  cxxrs,
  if_,
}:
{
  ${_cfg.if_.debug "_"} = ({ inherit cxxrs cxxrs_root; });

  ${if_.isLocal "barrel"} = callPackage (cxxrs_root.callPackage ./_1/barrel.nix { }) { };
  ${if_.isLocal "nix_derivation_env_vars"} = callPackage ./_1/nix_derivation_env_vars.nix { };
  ad_hoc = callPackage (cxxrs_root.callPackage ./_1/ad_hoc.nix { }) { };
  cargo = callPackage (cxxrs_root.callPackage ./_1/cargo.nix { }) { };
  cmake = callPackage (cxxrs_root.callPackage ./_1/cmake.nix { }) { };
}
