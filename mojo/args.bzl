"""
---
title: //mojo:args.bzl
description: Arguments for actions.
---

Arguments for actions.
"""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def mojo_action_args(
        ctx,
        command,  # "build" or "package"
        input,  # A file or directory.
        out_file,  # The output file.
        includes,  # Directories to include.
        defines):  # Defines to add during compilation.
    """Construct compile commands for a mojo invocation.

    Args:
        ctx: The rule context.
        command: The command to pass to mojo. Either `"build"` or `"package"`.
        input: The input to the command. A file for `command = "build"` and a
            directory for `command = "package"`.
        out_file: The output file.
        includes: Extra include directory paths.
        defines: Extra defines in the form of `a=b`.

    Returns:
        A list `[args]` containing a single `ctx.actions.args()` argument.
    """
    args = ctx.actions.args()

    # Add "build" or "package".
    if command not in ["build", "package"]:
        fail('Invalid command "{}". Use "build" or "package".'.format(command))
    args.add(command)

    # Manually added include paths.
    args.add_all(includes, format_each = "-I%s", uniquify = True)

    if command == "build":
        # Manually added defines.
        # Note that `-Da=b` is invalid. It has to be `-D 'a=b'`.
        args.add_all(defines, before_each = "-D", uniquify = True)

    # Other compile flags from the `compile_flags` attribute.
    args.add_all(ctx.attr.compile_flags)

    # Other compile flags from the `compile_string_flags` attribute.
    for flags in ctx.attr.compile_string_flags:
        args.add_all(flags[BuildSettingInfo].value.split(":"))

    # Dependencies.
    args.add_all(
        [file.dirname for file in ctx.files.deps],
        format_each = "-I%s",
        uniquify = True,
        omit_if_empty = True,
    )

    # Input file or directory.
    args.add(input)

    # Output file.
    args.add("-o", out_file)

    return [args]
