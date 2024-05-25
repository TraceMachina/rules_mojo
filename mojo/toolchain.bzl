"""
---
title: //mojo:toolchain.bzl
description: This file declares the `mojo_toolchain` rule.
---

This file declares the `mojo_toolchain` rule.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def _mojo_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            MODULAR_HOME = ctx.attr.MODULAR_HOME[BuildSettingInfo].value,
            MOJO_COMPILER = ctx.attr.MOJO_COMPILER[BuildSettingInfo].value,
            MOJO_CC_PATH = ctx.attr.MOJO_CC_PATH[BuildSettingInfo].value,
            LD_LIBRARY_PATH = ctx.attr.LD_LIBRARY_PATH[BuildSettingInfo].value,
            MOJO_PYTHON_LIBRARY = ctx.attr.MOJO_PYTHON_LIBRARY[BuildSettingInfo].value,
            symbolizer = ctx.executable.symbolizer,
        ),
    ]

mojo_toolchain = rule(
    implementation = _mojo_toolchain_impl,
    executable = False,
    attrs = {
        # These values are intended to be set via string_flags. For instance,
        # `MOJO_COMPILER` should be set to `@rules_mojo//mojo:MOJO_COMPILER`.
        # This is done in the mojo_toolchain instantiation (`mojo/BUILD.bazel`).
        "MODULAR_HOME": attr.label(),
        "MOJO_COMPILER": attr.label(
            doc = "The path to the mojo compiler.",
        ),
        "MOJO_CC_PATH": attr.label(),
        "LD_LIBRARY_PATH": attr.label(),
        "MOJO_PYTHON_LIBRARY": attr.label(),
        "symbolizer": attr.label(
            doc = "The `llvm-symbolizer`.",
            cfg = "exec",
            default = "@llvm-project//llvm:llvm-symbolizer",
            executable = True,
        ),
        # TODO(aaronmondal): Implement toolchain transitions and bootstrap the
        #                    Mojo standard library from the open sources.
        # "_allowlist_function_transition": attr.label(
        #     default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        # ),
    },
)
