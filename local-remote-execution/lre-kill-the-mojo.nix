{ kind
, docker
, writeShellScriptBin
, findutils
, ...
}:

writeShellScriptBin "lre-kill-the-mojo" ''
  set -xeuo pipefail

  ${kind}/bin/kind delete cluster

  ${docker}/bin/docker container stop kind-registry \
    | ${findutils}/bin/xargs docker rm

  ${docker}/bin/docker container stop kind-loadbalancer \
    | ${findutils}/bin/xargs docker rm
''
