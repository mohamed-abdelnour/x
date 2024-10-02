{ _dat }:
{
  cxxrs,
  fetchurl,
  stdenv,
}:
(
  cmake': _:
  let
    inherit (cmake') passthru pname version;
  in
  {
    inherit (_dat.cmake) version;
    pname = "cmake";

    src = fetchurl {
      inherit (passthru.drv.src) hash;
      url = "https://github.com/Kitware/${pname}/releases/download/v${version}/${pname}-${version}.tar.gz";
    };

    passthru.drv = {
      inherit (_dat.cmake) src;
    };
  }
)
|> (cxxrs.nixpkgs.cmake.override {
  inherit stdenv;
  isMinimalBuild = true;
  useOpenSSL = true;
}).overrideAttrs
