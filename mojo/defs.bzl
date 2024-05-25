"""
---
title: //mojo:defs.bzl
description: The Bazel rules for Mojo.
---

Import these rules in your `BUILD.bazel` files.

To load for example the `mojo_binary` rule:

```python
load("@rules_mojo//mojo:defs.bzl", "mojo_binary")
```
"""

load(
    "//mojo:mojo.bzl",
    _mojo_binary = "mojo_binary",
    _mojo_library = "mojo_library",
    _mojo_test = "mojo_test",
)

mojo_binary = _mojo_binary
mojo_library = _mojo_library
mojo_test = _mojo_test
