{ curl
, git
, kubectl
, kustomize
, native-cli
, nix
, writeShellScriptBin
, ...
}:

let
  # The specific commit to use
  nativelinkCommit = "9ba43236cf61737cd9561a1657ee50686b459966";

  # Base URL for GitHub access
  githubBaseUrl = "github:TraceMachina/nativelink/";
in

writeShellScriptBin "lre-mojo-cluster" ''
  set -xeuo pipefail

  # Start the native service
  ${native-cli}/bin/native up

  # Wait for the gateway to be ready
  ${kubectl}/bin/kubectl wait --for=condition=Programmed --timeout=60s \
    gateway el-gateway

  # Allow an additional grace period for potential routes to set themselves up.
  # TODO(aaronmondal): Find a better solution.
  sleep 10

  # POST requests to the event listener
  ${curl}/bin/curl -v \
    -H 'Content-Type: application/json' \
    -d '{"flakeOutput": "${githubBaseUrl}${nativelinkCommit}#image"}' \
    localhost:8082/eventlistener

  ${curl}/bin/curl -v \
    -H 'Content-Type: application/json' \
    -d '{"flakeOutput": "${githubBaseUrl}${nativelinkCommit}#nativelink-worker-init"}' \
    localhost:8082/eventlistener

  ${curl}/bin/curl -v \
    -H 'Content-Type: application/json' \
    -d '{"flakeOutput": "./src_root#nativelink-worker-lre-mojo"}' \
    localhost:8082/eventlistener

  # Wait for PipelineRuns to start
  until ${kubectl}/bin/kubectl get pipelinerun \
      -l tekton.dev/pipeline=rebuild-nativelink | grep -q 'NAME'; do
    echo "Waiting for PipelineRuns to start..."
    sleep 0.1
  done

  # Wait for the pipeline to succeed
  ${kubectl}/bin/kubectl wait \
    --for=condition=Succeeded \
    --timeout=60m \
    pipelinerun \
        -l tekton.dev/pipeline=rebuild-nativelink

  # Define kustomize directory and setup
  KUSTOMIZE_DIR=''$(${git}/bin/git rev-parse --show-toplevel)

  cat <<EOF > "''${KUSTOMIZE_DIR}"/kustomization.yaml
  ---
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization
  bases:
  resources:
    - https://github.com/TraceMachina/nativelink//deployment-examples/kubernetes/base
    - local-remote-execution/worker-lre-mojo.yaml
  EOF

  # Use kustomize to set images
  cd "''${KUSTOMIZE_DIR}" && ${kustomize}/bin/kustomize edit set image \
    nativelink=localhost:5001/nativelink:"''$(${nix}/bin/nix eval ${githubBaseUrl}${nativelinkCommit}#image.imageTag --raw)" \
    nativelink-worker-init=localhost:5001/nativelink-worker-init:"''$(${nix}/bin/nix eval ${githubBaseUrl}${nativelinkCommit}#nativelink-worker-init.imageTag --raw)" \
    nativelink-worker-lre-mojo=localhost:5001/nativelink-worker-lre-mojo:"''$(${nix}/bin/nix eval .#nativelink-worker-lre-mojo.imageTag --raw)"

  # Apply the configuration
  ${kubectl}/bin/kubectl apply -k "''${KUSTOMIZE_DIR}"

  # Monitor the deployment rollout
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-cas
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-scheduler
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-worker-lre-mojo
''
