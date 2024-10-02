load("@prelude//:artifacts.bzl", "ArtifactGroupInfo")

load(":bin.bzl", "cxxrs_bin")
load(":cfg.bzl", "cxxrs_cfg")


def _buck_incremental_command_impl(ctx: AnalysisContext) -> list[Provider]:
    inputs = [
        artifact for input in ctx.attrs.inputs for artifact in input[ArtifactGroupInfo].artifacts
    ]

    state = ctx.actions.declare_output("state.json")
    other_outputs = []

    arg = {
        "action": {
            "buck_incremental_command": {
                "program": ctx.attrs.program,
                "args": ctx.attrs.args,
                "inputs": inputs,
                "state": state.as_output(),
            }
        },
    }

    env = {}

    if cxxrs_cfg.opt.log_level != cxxrs_cfg.const.log_level.OFF:
        log = ctx.actions.declare_output("log.json")
        other_outputs.append(log)
        arg["log"] = log.as_output()
        env["CXXRS_LOG"] = cxxrs_cfg.opt.log_level

    cmd = [
        cxxrs_bin._.get(ctx.attrs._cxxrs_dev),
        ctx.actions.write_json("arg", arg, with_inputs=True),
    ]

    ctx.actions.run(
        cmd,
        category="cxxrs_dev_action_buck_incremental_command",
        env=env,
        local_only=True,
        metadata_env_var="CXXRS_METADATA",
        metadata_path="metadata.json",
        no_outputs_cleanup=True,
    )

    return [DefaultInfo(default_output=state, other_outputs=other_outputs)]


_buck_incremental_command = rule(
    impl=_buck_incremental_command_impl,
    attrs={
        "_cxxrs_dev": cxxrs_bin.cxxrs_dev,
        "program": attrs.string(),
        "args": attrs.list(attrs.string(), default=[]),
        "inputs": attrs.list(attrs.dep(providers=[ArtifactGroupInfo])),
    },
)


def _cxxbridge_impl(ctx: AnalysisContext):
    cxxs = [ctx.actions.declare_output(src.basename + ".cxx") for src in ctx.attrs.srcs]
    hxxs = [ctx.actions.declare_output(src.basename + ".hxx") for src in ctx.attrs.srcs]

    arg = {
        "action": {
            "buck_cxxbridge": {
                "srcs": ctx.attrs.srcs,
                "cxxs": [cxx.as_output() for cxx in cxxs],
                "hxxs": [hxx.as_output() for hxx in hxxs],
                "with_hacks": ctx.attrs.with_hacks,
            }
        },
    }

    ctx.actions.run(
        [
            cxxrs_bin._.get(ctx.attrs._cxxrs_dev),
            ctx.actions.write_json("arg", arg, with_inputs=True),
        ],
        category="cxxrs_dev_action_buck_cxxbridge",
    )

    return [
        DefaultInfo(
            default_outputs=cxxs,
            sub_targets={"hxx": [DefaultInfo(default_outputs=hxxs)]},
        )
    ]


_cxxbridge = rule(
    impl=_cxxbridge_impl,
    attrs={
        "_cxxrs_dev": cxxrs_bin.cxxrs_dev,
        "srcs": attrs.list(attrs.source()),
        "with_hacks": attrs.bool(default=False),
    },
)

cxxrs_dev = struct(
    buck_incremental_command=_buck_incremental_command,
    cxxbridge=_cxxbridge,
)
