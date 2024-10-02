load("@prelude//rust:cargo_package.bzl", "cargo")

load(":cfg.bzl", "cxxrs_cfg")


def _bin(rust_binary):
    def _bin(**kwargs):
        if cxxrs_cfg.opt.build_profile == cxxrs_cfg.const.build_profile.RELEASE:
            rustc_flags = kwargs.setdefault("rustc_flags", [])
            rustc_flags.append("--codegen=lto=thin")

        rust_binary(**kwargs)

    return _bin


def _lib(rust_library):
    def _lib(**kwargs):
        if (
            cxxrs_cfg.opt.build_profile == cxxrs_cfg.const.build_profile.RELEASE  # $
            and not kwargs.get("proc_macro", False)
        ):
            rustc_flags = kwargs.setdefault("rustc_flags", [])
            rustc_flags.append("--codegen=linker-plugin-lto")

        rust_library(**kwargs)

    return _lib


cxxrs_rust = struct(
    bin=_bin(native.rust_binary),
    lib=_lib(native.rust_library),
    reindeer=struct(
        bin=_bin(cargo.rust_binary),
        lib=_lib(cargo.rust_library),
    ),
)
