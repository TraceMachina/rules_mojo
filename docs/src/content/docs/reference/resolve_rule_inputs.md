---
title: //mojo:resolve_rule_inputs.bzl
description: Resolve the inputs to `mojo_library` and `mojo_binary` rules.
---

Resolve the inputs to `mojo_library` and `mojo_binary` rules.

<a id="expand_includes"></a>

## `expand_includes`

<pre><code>expand_includes(<a href="#expand_includes-ctx">ctx</a>, <a href="#expand_includes-include_string">include_string</a>)</code></pre>
Prefix `include_string` with the path to the workspace root.

If `include_string` starts with `$(GENERATED)`, prefixes with the`GENDIR`
path as well.

**Args:**

| Name  | Description |
| :---- | :---------- |
| <a id="expand_includes-ctx"></a>`ctx` |  |
| <a id="expand_includes-include_string"></a>`include_string` |  |


<a id="resolve_rule_inputs"></a>

## `resolve_rule_inputs`

<pre><code>resolve_rule_inputs(<a href="#resolve_rule_inputs-ctx">ctx</a>)</code></pre>
Gather the inputs for downstream actions.

**Args:**

| Name  | Description |
| :---- | :---------- |
| <a id="resolve_rule_inputs-ctx"></a>`ctx` | The rule context.  |

**Returns:**

A tuple `(defines, includes)`. See
  [//mojo:actions.bzl](actions.md) for usage.
