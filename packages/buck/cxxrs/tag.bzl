load(":glob.bzl", "cxxrs_glob")


_tag = struct(
    by_type=lambda ty: f"cxxrs_tag.by_type.{ty}",
)


def _Ft():
    by_type = _tag.by_type
    ext = cxxrs_glob.ext

    # TODO: Using `filegroup` for this is not ideal; we don't actually want the group
    # (whether copied or symlinked), all we care about is the `ArtifactGroupInfo` the
    # rule provides.
    filegroup = native.filegroup

    def cxx(**kwargs):
        filegroup(
            name=by_type("cxx"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=ext("cxx", **kwargs) + ext("hxx", **kwargs),
        )

    def json(**kwargs):
        filegroup(
            name=by_type("json"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=ext("json", **kwargs),
        )

    def nix(**kwargs):
        filegroup(
            name=by_type("nix"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=ext("nix", **kwargs),
        )

    def rust(**kwargs):
        filegroup(
            name=by_type("rust"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=ext("rs", **kwargs),
        )

    def shell(**kwargs):
        filegroup(
            name=by_type("shell"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=glob(("**/.envrc",)) + ext("sh", **kwargs),
        )

    def starlark(**kwargs):
        filegroup(
            name=by_type("starlark"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=glob(("**/BUCK",), **kwargs) + ext("bzl", **kwargs),
        )

    def toml(**kwargs):
        filegroup(
            name=by_type("toml"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=ext("toml", **kwargs),
        )

    def yaml(**kwargs):
        filegroup(
            name=by_type("yaml"),
            visibility=["PUBLIC"],
            copy=False,
            srcs=glob(("**/*.clang-format", "**/*.clang-tidy"), **kwargs),
        )

    return struct(
        cxx=cxx,
        json=json,
        nix=nix,
        rust=rust,
        shell=shell,
        starlark=starlark,
        toml=toml,
        yaml=yaml,
    )


_ft = _Ft()


def _known(**kwargs):
    _ft.cxx(**kwargs)
    _ft.json(**kwargs)
    _ft.nix(**kwargs)
    _ft.rust(**kwargs)
    _ft.shell(**kwargs)
    _ft.starlark(**kwargs)
    _ft.toml(**kwargs)
    _ft.yaml(**kwargs)


cxxrs_tag = struct(
    ft=_ft,
    known=_known,
    tag=_tag,
)
