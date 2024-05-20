"""# `//mojo:providers.bzl`

Providers for the `mojo_binary` and `mojo_library` rules.
"""

MojoInfo = provider(
    doc = "The default provider returned by a `mojo_*` target.",
    fields = {
        # "exposed_defines": "A `depset` of defines.",
        "exposed_includes": "A `depset` of includes.",
    },
)
