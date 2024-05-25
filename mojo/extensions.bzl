"""
---
title: `//mojo:extensions.bzl`
description: Bazel module extensions used by `rules_mojo`.
---

Bazel module extensions used by `rules_mojo`.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _rules_mojo_dependencies_impl(_):
    http_archive(
        name = "mojo",
        build_file = "@rules_mojo//thirdparty:mojo.BUILD.bazel",
        integrity = "sha256-M4hGfPmiY3PX9otPZk38JCwWEQgL3z/YOZJ04CDAmkk=",
        urls = [
            # "https://github.com/modularml/mojo/archive/bf73717d79fbb79b4b2bf586b3a40072308b6184.zip"

            # Nightly. Stable is broken.
            "https://github.com/modularml/mojo/archive/7e8cd37ff8fe2ddbe69a3cca787e59abf6357d76.zip",
        ],
        strip_prefix = "mojo-7e8cd37ff8fe2ddbe69a3cca787e59abf6357d76",
    )

    # http_archive(
    #     name = "local-remote-execution",
    #     urls = [
    #         "https://github.com/TraceMachina/nativelink/archive/refs/tags/v0.4.0.zip",
    #     ],
    #     integrity = "sha256-yhsJQZITkWjMcaFyniWL2R4YGxYuwduHdcer6eTXbJY=",
    #     strip_prefix = "nativelink-0.4.0/local-remote-execution",
    # )

rules_mojo_dependencies = module_extension(
    implementation = _rules_mojo_dependencies_impl,
)
