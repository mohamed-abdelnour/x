# `jq` looks for modules under `$ORIGIN/../lib/jq` (among other places) where
# `$ORIGIN` is the directory in which the `jq` executable is located. That
# detection is likely based on `arg[0]` (the name of the executable); thus, for
# `jq` to find our modules it must be referred to by a path as opposed to `jq`.
{ ROOT }:
{
  jq,
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  inherit (jq) pname version;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir --parents "$out/bin" "$out/lib"
    ln --symbolic ${lib.getExe jq} "$out/bin"
    ln --symbolic '${ROOT + /packages/jq}' "$out/lib/jq"
  '';

  meta = {
    inherit (jq.meta) mainProgram;
  };
}
