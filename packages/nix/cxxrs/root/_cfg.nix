{
  _cfg,
  _lib,
  _pkg,
  cxxrs,
  lib,
}:
{
  opt =
    let
      defaults = {
        cmake.useLatest = false;
        ctx.linker.allowNonLld = false;
        ctx.useFullLto = false;
        ctx.withHacks = true;
        debug = false;
        native = true;
        nixpkgs = { };
        shell.sizeBracket = 0;
        test = false;
      };

      derived = cfg': cfg: {
        debug = cfg.debug || cfg'.test;
        nixpkgs = (cfg.nixpkgs // { overlays = [ _pkg.overlay ]; });
      };
    in
    lib.extends (_: lib.recursiveUpdate defaults) cxxrs.__state__ |> lib.extends derived |> lib.fix;

  if_ = lib.mapAttrsRecursive (_: _lib.cfg) _cfg.opt;
}
