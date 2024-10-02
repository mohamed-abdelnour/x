{
  inputs = {
    cxxrs_cfg_transitions.url = "path:toml_transitions/";
    nixpkgs.follows = "";

    cxxrs_cfg_transitions.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs: {
    inherit (inputs.cxxrs_cfg_transitions) transitions;
    keys.TRANSITION = "_";
    options = { };
  };
}
