{
  inputs.nixpkgs.follows = "";
  outputs =
    { nixpkgs, self, ... }:
    let
      inherit (nixpkgs) lib;
    in
    {
      transitions = map self.tomlTransitionParser self.tomlTransitions |> builtins.listToAttrs;

      tomlTransitionParser =
        let
          # This makes the transitions easier to specify on the command line (compare
          # `a."b.c"."d.e"` to `"a.b/c.d/e"`).
          tailorForCli = builtins.replaceStrings [ "." ] [ "/" ];
        in
        tr:
        builtins.fromTOML tr
        |> (cfg': {
          name = tailorForCli tr;
          value = _: cfg: lib.recursiveUpdate cfg cfg';
        });

      tomlTransitions = [
        "cmake.useLatest=false"
        "cmake.useLatest=true"
        "ctx.linker.allowNonLld=false"
        "ctx.linker.allowNonLld=true"
        "ctx.useFullLto=false"
        "ctx.useFullLto=true"
        "ctx.withHacks=false"
        "ctx.withHacks=true"
        "debug=false"
        "debug=true"
        "native=false"
        "native=true"
        "nixpkgs.crossSystem.config='aarch64-unknown-linux-gnu'"
        "nixpkgs.localSystem='x86_64-linux'"
        "shell.sizeBracket=0"
        "shell.sizeBracket=1"
        "shell.sizeBracket=2"
        "test=false"
        "test=true"
      ];
    };
}
