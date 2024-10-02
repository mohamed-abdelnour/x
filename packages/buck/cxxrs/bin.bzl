load(":cfg.bzl", "cxxrs_cfg")


cxxrs_bin = struct(
    _=struct(
        get=lambda bin: bin[RunInfo]
        if cxxrs_cfg.opt.bootstrap == cxxrs_cfg.const.bootstrap.BUCK
        else bin
    ),
    cxxrs_dev=attrs.default_only(
        cxxrs_cfg.if_.bootstrap(
            {
                cxxrs_cfg.const.bootstrap.NIX: lambda: attrs.string(default="cxxrs_dev"),
                cxxrs_cfg.const.bootstrap.BUCK: lambda: attrs.exec_dep(
                    providers=[RunInfo],
                    default="//packages/rust/cxxrs/dev:cxxrs_dev.bin",
                ),
            }
        )()
    ),
)
