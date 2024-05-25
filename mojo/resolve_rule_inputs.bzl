"""
---
title: //mojo:resolve_rule_inputs.bzl
description: Resolve the inputs to `mojo_library` and `mojo_binary` rules.
---

Resolve the inputs to `mojo_library` and `mojo_binary` rules.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//mojo:providers.bzl", "MojoInfo")

def expand_includes(ctx, include_string):
    """Prefix `include_string` with the path to the workspace root.

    If `include_string` starts with `$(GENERATED)`, prefixes with the`GENDIR`
    path as well.
    """

    if include_string.startswith("$(GENERATED)"):
        return include_string.replace(
            "$(GENERATED)",
            paths.join(ctx.var["GENDIR"], ctx.label.workspace_root),
        )

    return paths.join(ctx.label.workspace_root, include_string)

def resolve_rule_inputs(ctx):
    """Gather the inputs for downstream actions.

    Args:
        ctx: The rule context.

    Returns:
        A tuple `(defines, includes)`. See
        [//mojo:actions.bzl](actions.md) for usage.
    """
    defines = depset(
        ctx.attr.defines + ctx.attr.exposed_defines,
        transitive = [dep[MojoInfo].exposed_defines for dep in ctx.attr.deps],
        order = "preorder",
    )

    includes = depset(
        [
            expand_includes(ctx, suffix)
            for suffix in ctx.attr.includes + ctx.attr.exposed_includes
        ],
        transitive = [dep[MojoInfo].exposed_includes for dep in ctx.attr.deps],
        order = "preorder",
    )

    return (
        defines,
        includes,
    )
