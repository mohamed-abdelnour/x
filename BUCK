load("//packages/buck/cxxrs:root.bzl", "cxxrs_root")
load("//packages/buck/cxxrs:tag.bzl", "cxxrs_tag")

cxxrs_tag.known(
    exclude=(
        # FIXME: `taplo` can't handle these.
        #
        # [,bash,options=nowrap]
        # ----
        # (
        #     _0='packages/nix/cxxrs/root/_dev/tests/cxxrs_nix_derivation_env_vars/barrel/_.nixpkgs%2FlocalSystem%3D%27x86_64-linux%27.trycmd.toml' &&
        #         _1="$(readlink --canonicalize-existing "$_0")" &&
        #         taplo format "$_0" && # <1>
        #         ! taplo format "$_1"  # <2>
        # )
        # ----
        # <1> `taplo` succeeds but doesn't format
        # <2> `taplo` fails
        "packages/nix/cxxrs/root/_dev/tests/**/*.trycmd.toml",
    )
)

cxxrs_root.actions(
    (
        "//",
        "//packages/cxx/cxxrs/lto_2",
        "//packages/rust/_0/reindeer",
        "//packages/rust/_0/reindeer/extern/valuable",
        "//packages/rust/cxxrs/dev",
        "//packages/rust/cxxrs/lto_2_rs",
        "toolchains//",
    )
)
