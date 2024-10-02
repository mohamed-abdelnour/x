# WARN: An observation: `sccache` seems to behave strangely when it is called
# under a name that it can't find in `$PATH`. That is, suppose `_0` isn't in
# `$PATH`, explicitly running `sccache _0` fails; but running `sccache` as `_0`
# (e.g., `cp "$(command -v sccache)" _0 && ./_0`) hangs and seems to block the
# `sccache` server.
{ sccache, stdenvNoCC }:
stdenvNoCC.mkDerivation {
  inherit (sccache) pname version;

  nativeBuildInputs = [ sccache ];
  sccacheLinks = [
    "c++"
    "cc"
    "clang"
    "clang++"
    "g++"
    "gcc"
    "rustc"
  ];

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir --parents "$out/bin"
    cp "$(command -v sccache)" "$out/bin"
    printf '%s\0' "''${sccacheLinks[@]}" |
        xargs --max-procs="$NIX_BUILD_CORES" --null -I{} ln "$out/bin/sccache" "$out/bin/{}"
  '';
}
