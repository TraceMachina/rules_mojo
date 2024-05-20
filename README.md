# `rules_mojo` 🔥

Hermetic, reproducible Bazel/Nix rules for Mojo 🔥.

Brings Mojo to all Linux distributions.

✨ **Features**:

- Mojo wrapped in [Nix](https://nixos.org/). No implicit `apt` installations, no
  need to use Ubuntu. You can use `rules_mojo` on any `x86_64-linux` system that
  has Nix installed.
- [Bazel](https://bazel.build/) rules for Mojo. This means that `rules_mojo`
  gives you incremental builds. In `rules_mojo`s own CI this reduces build times
  and CPU cycles spent by up to 95%.
- Integration with [NativeLink](https://github.com/TraceMachina/nativelink) and
  [Local Remote Execution (LRE)](https://github.com/TraceMachina/nativelink/tree/main/local-remote-execution)
  which lets you execute builds in arbitrarily scalable Kubernetes clusters.
  Whether you want to run a build on 1000 cores or just share your build cache
  among friends, the NativeLink+LRE infrastructure supports it.

🔮 **Coming soon™**:

- Mac support.
- GPU support.
- Python interoperability.

🔪 **Rough edges**:

- Mojo is experimental and `rules_mojo` is even more experimental. Several
  features, such as linting and Python interoperability aren't yet implemented.
  Also, the LRE framework is still actively under development (in fact,
  `rules_mojo` acts as a validation case for LRE), so expect larger scale
  refactors.
- At the moment there is no way to chose the Mojo version. `rules_mojo` uses
  a pinned `nightly` toolchain that happened to not crash because stable
  crashed.

🦋 **Known bugs**:

- While you can build tests remotely, you need to run them locally.
- The Mojo REPL doesn't work yet due to an `ncurses` linker symbol mismatch.
- All mojo invocations print `crashdb` warnings because it's unclear how to
  configure the `crashdb` output location to point outside of the nix store.

## ❄️ Setup

Install Nix and enable flake support. The new experimental nix installer does
this for you: <https://github.com/NixOS/experimental-nix-installer>

Install [`direnv`](https://direnv.net/) and add the `direnv hook` to your
`.bashrc`:

```bash
nix profile add nixpkgs#direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
# For hooks into shells other than bash see https://direnv.net/docs/hook.html.
```

Now clone `rules_mojo`, `cd` into it and run `direnv allow`:

```bash
git clone git@github.com/TraceMachina/rules_mojo
cd rules_mojo
direnv allow
```

> [!NOTE]
> If you don't want to use `direnv` you can use `nix develop` manually which is
> the command that `direnv` would automatically call for you.

The Mojo standard library is convenience test target for `rules_mojo`. To run
all tests:

```bash
bazel test @mojo//...
```

To run the example in the `examples` directory:

```bash
bazel run examples:hello
```

## 🚢 Building in Kubernetes

You can test the remote execution capabilities of `rules_mojo` by spinning up
the builtin Kubernetes cluster with a pre-configured NativeLink setup.

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

> [!NOTE]
> At the moment you can build all artifacts remotely, but tests have to run
> locally. Future versions of `rules_mojo` intend to address this issue.

To delete the cluster, run:

```bash
lre-kill-the-mojo
```

## 🌱 Use in external projects

> [!WARNING]
> This section is still under construction.

See the `templates/default` directory for templates. To start an entirely new
project:

```bash
mkdir myproject
cd myproject
git init
nix flake init -t github:TraceMachina/rules_mojo
```

## 📜 License

Licensed under the Apache 2.0 License with LLVM exceptions.

This repository wraps the Mojo SDK which is under a proprietary license, bundled
with the Mojo SDK and also available in the `licenses` directory.
