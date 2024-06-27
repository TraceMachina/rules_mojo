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
        integrity = "sha256-PqgP+ELm4FL5989EJI8vjJvSRpPhtOpv5TH86k4BZR8=",
        urls = [
            "https://github.com/modularml/mojo/archive/454974d477a44b93365181c77f20d9e1fe1aceaa.zip",
        ],
        strip_prefix = "mojo-454974d477a44b93365181c77f20d9e1fe1aceaa",
    )

rules_mojo_dependencies = module_extension(
    implementation = _rules_mojo_dependencies_impl,
)
