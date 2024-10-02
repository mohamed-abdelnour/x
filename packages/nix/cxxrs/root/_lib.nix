{ _cfg, lib }:
{
  cfg =
    let
      BOT = "bot";
      TOP = "top";

      positive = {
        __functor = self: self.${TOP};
        ${BOT} = _: null;
        ${TOP} = lib.id;
      };

      negative = positive // {
        ${BOT} = positive.${TOP};
        ${TOP} = positive.${BOT};
      };
    in
    cond: if cond then positive else negative;

  id.asserting =
    f: x:
    assert _cfg.opt.debug -> f x;
    x;

  workspace = rec {
    name = "cxxrs";
    version = "0.1.0";

    concatStrings = builtins.concatStringsSep ".";
    memberPname = components: concatStrings ([ name ] ++ components);
    memberName = components: "${memberPname components}-${version}";
  };
}
