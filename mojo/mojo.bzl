"""
---
title: //mojo:mojo.bzl
description: Internal definition of the Mojo rules.
---

Build files should import these rules from `@rules_mojo//mojo:defs.bzl`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//mojo:args.bzl", "mojo_action_args")
load(
    "//mojo:attributes.bzl",
    "MOJO_BINARY_ATTRS",
    "MOJO_LIBRARY_ATTRS",
)
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
    defines = depset(ctx.attr.defines, order = "preorder")

    includes = depset(
        [expand_includes(ctx, suffix) for suffix in ctx.attr.includes],
        transitive = [dep[MojoInfo].exposed_includes for dep in ctx.attr.deps],
        order = "preorder",
    )

    return (
        defines,
        includes,
    )

def mojo_artifact(ctx, filename = None):
    """Return a string of the form `"{ctx.label.name}/filename"`.

    Encapsulate intermediary build artifacts to avoid name clashes for files of
    the same name built by targets in the same build invocation.

    Args:
        ctx: The build context.
        filename: An optional string representing a filename. If omitted,
            creates a path of the form `"{ctx.label.name}"`.
    """
    if filename == None:
        return "{}".format(ctx.label.name)

    return "{}/{}".format(ctx.label.name, filename)

def find_package_dir(ctx):
    """Find the directory to turn into a package.

    Each directory with an `__init__.mojo` file corresponds to a package.

    This function constructs a package from the first `__init__.mojo` file it
    finds, starting from the top level directory. If you have files like this:

    ```
    mypackage/
        __init__.mojo
        subpackage/
            __init__.mojo
    ```

    you'll get an output package `mypackage.mojopkg`.

    Args:
        ctx: The rule context.

    Returns:
        The package directory.
    """

    # TODO(aaronmondal): Blindly reading the sources isn't very robust.
    for file in ctx.files.srcs:
        if file.basename == "__init__.mojo":
            return file.dirname

    fail("Couldn't find `__init__.mojo` in: {}".format(ctx.files.srcs))

def _mojo_library_impl(ctx):
    (
        _,  # Packaging doesn's support defines.
        includes,
    ) = resolve_rule_inputs(ctx)

    toolchain = ctx.toolchains["//mojo:toolchain_type"]

    out_file = ctx.actions.declare_file(
        mojo_artifact(ctx, ctx.label.name + ".mojopkg"),
    )

    package_dir = find_package_dir(ctx)

    ctx.actions.run(
        outputs = [out_file],
        inputs = ctx.files.srcs,
        executable = toolchain.MOJO_COMPILER,
        arguments = mojo_action_args(
            ctx,
            command = "package",
            input = package_dir,
            out_file = out_file,
            includes = includes,
            defines = None,
        ),
        mnemonic = "MojoBuildPackage",
        tools = [toolchain.symbolizer],
        use_default_shell_env = False,
        env = {
            "LLVM_SYMBOLIZER_PATH": toolchain.symbolizer.path,
        },
    )

    return [
        DefaultInfo(
            files = depset([out_file]),
        ),
        MojoInfo(
            exposed_includes = depset([expand_includes(ctx, package_dir)]),
        ),
    ]

mojo_library = rule(
    implementation = _mojo_library_impl,
    executable = False,
    attrs = MOJO_LIBRARY_ATTRS,
    output_to_genfiles = True,
    toolchains = [
        "//mojo:toolchain_type",
    ],
    doc = """
Creates a Mojo package.

Example:

  ```python
  mojo_library(
      name = "mypackage",
      srcs = [
          "__init__.mojo",
          "my_package.mojo",
      ],
  )
  ```
""",
)

def _mojo_binary_impl(ctx):
    (
        defines,
        includes,
    ) = resolve_rule_inputs(ctx)

    toolchain = ctx.toolchains["//mojo:toolchain_type"]

    in_file = [src for src in ctx.files.srcs][0]  # Hack.

    file_out = ctx.actions.declare_file(mojo_artifact(ctx, ctx.label.name))

    ctx.actions.run(
        outputs = [file_out],
        inputs = depset(
            [in_file] + ctx.files.deps,
        ),
        executable = toolchain.MOJO_COMPILER,
        arguments = mojo_action_args(
            ctx,
            command = "build",
            input = in_file,
            out_file = file_out,
            includes = includes,
            defines = defines,
        ),
        mnemonic = "MojoCompileExecutable",
        tools = [toolchain.symbolizer],
        use_default_shell_env = False,
        env = {
            "LLVM_SYMBOLIZER_PATH": toolchain.symbolizer.path,
        },
    )

    return [
        DefaultInfo(
            files = depset([file_out]),
            executable = file_out,
            runfiles = ctx.runfiles(files = ctx.files.runtime_data),
        ),
    ]

mojo_binary = rule(
    implementation = _mojo_binary_impl,
    executable = True,
    attrs = MOJO_BINARY_ATTRS,
    toolchains = [
        "//mojo:toolchain_type",
    ],
    doc = """
Creates an executable.

Example:

  ```python
  mojo_binary(
      name = "hello",
      srcs = ["hello.mojo"],
  )
  ```
""",
)

mojo_test = rule(
    implementation = _mojo_binary_impl,
    test = True,
    attrs = MOJO_BINARY_ATTRS,
    toolchains = [
        "//mojo:toolchain_type",
    ],
    doc = """
Testable wrapper around `mojo_binary`.

Consider using this rule over Skylib's `native_test` targets to propagate shared
libraries to the test invocations.

Example:

  ```python
  mojo_test(
      name = "hello_test",
      srcs = ["my_test.mojo"],
  )
  ```
""",
)
