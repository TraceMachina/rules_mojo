---
title: Setup
description: Get started with rules_mojo.
---

## ❄️ Prepare Nix

Install Nix and enable flake support. The new experimental nix installer does
this for you: <https://github.com/NixOS/experimental-nix-installer>

Install [`direnv`](https://direnv.net/) and add the `direnv hook` to your
`.bashrc`:

```bash
nix profile install nixpkgs#direnv

# For hooks into shells other than bash see https://direnv.net/docs/hook.html.
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

source ~/.bashrc
```

Now clone `rules_mojo`, `cd` into it and run `direnv allow`:

```bash
git clone git@github.com/TraceMachina/rules_mojo
cd rules_mojo
direnv allow
```

:::note
If you don't want to use `direnv` you can use `nix develop` manually which is
the command that `direnv` would automatically call for you.
:::

Inside the Nix environment you'll have access to the `mojo` command:

```bash
# The mojo REPL.
mojo

# Build a mojo executable.
mojo build examples/hello.mojo

# Build a mojo package.
mojo package examples/mypackage

# Invoke the nix-packaged `mojo` executable
# outside of the `rules_mojo` repository:
nix run github:TraceMachina/rules_mojo#mojo
```

To test the `mojo_toolchain` with Bazel, run the Mojo standard library test
suite:

```bash
bazel test @mojo//...
```

:::tip
Check out [`thirdparty/mojo.BUILD.bazel`](https://github.com/TraceMachina/rules_mojo/blob/main/thirdparty/mojo.BUILD.bazel)
for the build file of this target.
:::

To run the example in the `examples` directory:

```bash
bazel run examples:hello
```

## 🚢 Building in Kubernetes

You can test the remote execution capabilities of `rules_mojo` by spinning up
the builtin Kubernetes cluster with a pre-configured NativeLink setup.

![NativeLink LRE Mojo Cluster](https://raw.githubusercontent.com/TraceMachina/rules_mojo/510b54a9f9128ddab38dce0c27dc924e7d817e11/cluster-architecture.webp?raw=true)

Make sure you have a recent version of Docker installed. Then you can invoke the
following command from within the Nix flake:

```bash
lre-mojo-cluster
```

This spins up a local [kind](https://kind.sigs.k8s.io/) cluster, builds a Mojo
remote execution container and deploys it into a NativeLink remote execution
setup.

The setup may take a minute to boot up. When running the command the first time
it might take some time to build NativeLink from source inside the cluster
pipelines. Once the command finishes you can invoke the following command to run
a local dashboard:

```bash
kubectl -n kube-system port-forward svc/hubble-ui 8080:80
```

Visit <http://localhost:8080/?namespace=default> to view the cluster topology.

To now point Bazel invocations to this cluster, invoke `lre-bazel` instead of
`bazel`:

```bash
lre-bazel test @mojo//...
lre-bazel run examples:hello
```

This sends build invocations to the cluster instead of building locally on your
own machine.

:::note
At the moment you can build all artifacts remotely, but tests have to run
locally. Future versions of `rules_mojo` intend to address this issue.
:::

To delete the cluster, run:

```bash
lre-kill-the-mojo
```

## 🌱 Use in external projects

:::caution
This section is still under construction.
:::

See the `templates/default` directory for templates. To start an entirely new
project:

```bash
mkdir myproject
cd myproject
git init
nix flake init -t github:TraceMachina/rules_mojo
```
