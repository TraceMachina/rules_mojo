---
title: //mojo:args.bzl
description: Arguments for actions.
---

Arguments for actions.

<a id="mojo_action_args"></a>

## `mojo_action_args`

<pre><code>mojo_action_args(<a href="#mojo_action_args-ctx">ctx</a>, <a href="#mojo_action_args-command">command</a>, <a href="#mojo_action_args-input">input</a>, <a href="#mojo_action_args-out_file">out_file</a>, <a href="#mojo_action_args-includes">includes</a>, <a href="#mojo_action_args-defines">defines</a>)</code></pre>
Construct compile commands for a mojo invocation.

**Args:**

| Name  | Description |
| :---- | :---------- |
| <a id="mojo_action_args-ctx"></a>`ctx` | The rule context.  |
| <a id="mojo_action_args-command"></a>`command` | The command to pass to mojo. Either `"build"` or `"package"`.  |
| <a id="mojo_action_args-input"></a>`input` | The input to the command. A file for `command = "build"` and a directory for `command = "package"`.  |
| <a id="mojo_action_args-out_file"></a>`out_file` | The output file.  |
| <a id="mojo_action_args-includes"></a>`includes` | Extra include directory paths.  |
| <a id="mojo_action_args-defines"></a>`defines` | Extra defines in the form of `a=b`.  |

**Returns:**

A list `[args]` containing a single `ctx.actions.args()` argument.
