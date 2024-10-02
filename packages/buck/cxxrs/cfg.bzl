_const = struct(
    _FALSE="false",
    _TRUE="true",
    bootstrap=struct(
        BUCK="buck",
        NIX="nix",
    ),
    build_profile=struct(
        DEBUG="debug",
        RELEASE="release",
    ),
    log_level=struct(
        DEBUG="debug",
        OFF="off",
    ),
)

_opt = struct(
    allow_slow=read_root_config("cxxrs", "allow_slow", _const._FALSE) == _const._TRUE,
    bootstrap=read_root_config("cxxrs", "bootstrap", _const.bootstrap.NIX),
    build_profile=read_root_config("cxxrs", "build_profile", _const.build_profile.RELEASE),
    log_level=read_root_config("cxxrs", "log_level", _const.log_level.OFF),
    dev_action={
        "clang-tidy": read_root_config("cxxrs", "dev_action.clang-tidy", _const._FALSE)
        == _const._TRUE,
    },
)

_opt.dev_action["clang-tidy"] = _opt.allow_slow or _opt.dev_action["clang-tidy"]


def _If_():
    def if_(key):
        def _selector(dict, *args):
            return dict[key] if len(args) == 0 else dict.get(key, *args)

        return _selector

    return struct(
        bootstrap=if_(_opt.bootstrap),
        build_profile=if_(_opt.build_profile),
    )


_if_ = _If_()

cxxrs_cfg = struct(
    const=_const,
    if_=_if_,
    opt=_opt,
)
