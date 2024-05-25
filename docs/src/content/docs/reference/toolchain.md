---
title: //mojo:toolchain.bzl
description: This file declares the `mojo_toolchain` rule.
---

This file declares the `mojo_toolchain` rule.

<a id="mojo_toolchain"></a>

## `mojo_toolchain`

<pre><code>mojo_toolchain(<a href="#mojo_toolchain-name">name</a>, <a href="#mojo_toolchain-LD_LIBRARY_PATH">LD_LIBRARY_PATH</a>, <a href="#mojo_toolchain-MODULAR_HOME">MODULAR_HOME</a>, <a href="#mojo_toolchain-MOJO_CC_PATH">MOJO_CC_PATH</a>, <a href="#mojo_toolchain-MOJO_COMPILER">MOJO_COMPILER</a>,
               <a href="#mojo_toolchain-MOJO_PYTHON_LIBRARY">MOJO_PYTHON_LIBRARY</a>, <a href="#mojo_toolchain-symbolizer">symbolizer</a>)</code></pre>

### Attributes

| Name  | Description |
| :---- | :---------- |
| <a id="mojo_toolchain-name"></a>`name` | <code><a href="https://bazel.build/concepts/labels#target-names">Name</a></code>, required.<br><br> A unique name for this target.   |
| <a id="mojo_toolchain-LD_LIBRARY_PATH"></a>`LD_LIBRARY_PATH` | <code><a href="https://bazel.build/concepts/labels">Label</a></code>, optional, defaults to <code>None</code>.<br><br> -   |
| <a id="mojo_toolchain-MODULAR_HOME"></a>`MODULAR_HOME` | <code><a href="https://bazel.build/concepts/labels">Label</a></code>, optional, defaults to <code>None</code>.<br><br> -   |
| <a id="mojo_toolchain-MOJO_CC_PATH"></a>`MOJO_CC_PATH` | <code><a href="https://bazel.build/concepts/labels">Label</a></code>, optional, defaults to <code>None</code>.<br><br> -   |
| <a id="mojo_toolchain-MOJO_COMPILER"></a>`MOJO_COMPILER` | <code><a href="https://bazel.build/concepts/labels">Label</a></code>, optional, defaults to <code>None</code>.<br><br> The path to the mojo compiler.   |
| <a id="mojo_toolchain-MOJO_PYTHON_LIBRARY"></a>`MOJO_PYTHON_LIBRARY` | <code><a href="https://bazel.build/concepts/labels">Label</a></code>, optional, defaults to <code>None</code>.<br><br> -   |
| <a id="mojo_toolchain-symbolizer"></a>`symbolizer` | <code><a href="https://bazel.build/concepts/labels">Label</a></code>, optional, defaults to <code>"@llvm-project//llvm:llvm-symbolizer"</code>.<br><br> The `llvm-symbolizer`.   |
