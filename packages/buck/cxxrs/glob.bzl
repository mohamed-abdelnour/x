def _wildcard(pat, **kwargs):
    # The interpreter constructs `glob::MatchOptions` with
    # [`require_literal_leading_dot: true`][0] which is why the first pattern alone is
    # not enough.
    #
    # <!-- prettier-ignore -->
    # [0]: https://github.com/facebook/buck2/blob/2024-10-01/app/buck2_interpreter_for_build/src/interpreter/globspec.rs#L157
    return glob(
        (
            f"**/{pat}",
            f".*/**/{pat}",
            f"**/.{pat}",
            f".*/**/.{pat}",
        ),
        **kwargs,
    )


def _ext(ext, **kwargs):
    return _wildcard(f"*.{ext}", **kwargs)


cxxrs_glob = struct(
    ext=_ext,
    wildcard=_wildcard,
)
