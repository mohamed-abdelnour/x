load(":cfg.bzl", "cxxrs_cfg")
load(":dev.bzl", "cxxrs_dev")
load(":tag.bzl", "cxxrs_tag")


def _actions(leaves):
    inputs = lambda ty: [f"{leaf}:" + cxxrs_tag.tag.by_type(ty) for leaf in leaves]

    cxx = inputs("cxx")
    json = inputs("json")
    nix = inputs("nix")
    rust = inputs("rust")
    shell = inputs("shell")
    starlark = inputs("starlark")
    toml = inputs("toml")
    yaml = inputs("yaml")

    commands = {
        "clang-format": {
            "args": ["-i"],
            "inputs": cxx,
        },
        "deadnix": {
            "args": ["--fail"],
            "inputs": nix,
        },
        "nixfmt": {
            "inputs": nix,
        },
        "prettier.json": {
            "program": "prettier",
            "args": ["--ignore-path=", "--write", "--parser=json"],
            "inputs": json,
        },
        "prettier.yaml": {
            "program": "prettier",
            "args": ["--ignore-path=", "--write", "--parser=yaml"],
            "inputs": yaml,
        },
        "ruff": {
            "args": ["format"],
            "inputs": starlark,
        },
        "rustfmt": {
            "inputs": rust,
        },
        "shellcheck": {
            "inputs": shell,
        },
        "shfmt": {
            "args": ["--case-indent", "--indent=4", "--write"],
            "inputs": shell,
        },
        "taplo": {
            "args": ["format"],
            "inputs": toml,
        },
    }

    if cxxrs_cfg.opt.dev_action["clang-tidy"]:
        commands["clang-tidy"] = {
            "args": ["--warnings-as-errors=*"],
            "inputs": cxx,
        }

    for key, command in commands.items():
        command.setdefault("program", key)
        cxxrs_dev.buck_incremental_command(name=f"action.{key}", **command)


cxxrs_root = struct(actions=_actions)
