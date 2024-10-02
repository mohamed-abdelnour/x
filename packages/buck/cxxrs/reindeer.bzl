load(":tag.bzl", "cxxrs_tag")


def _affect():
    cxxrs_tag.known(
        exclude=(
            ".cargo/**",
            ".cargo/**/.*",
            "BUCK",
            "vendor/**",
            "vendor/**/.*",
        )
    )


cxxrs_reindeer = struct(affect=_affect)
