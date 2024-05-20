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
  nativelinkCommit = "75105df746c626da76f74e412764e6755296a8ab";

  # Base URL for GitHub access
  githubBaseUrl = "github:TraceMachina/nativelink/";
in

writeShellScriptBin "lre-mojo-cluster" ''
  set -xeuo pipefail

  # Start the native service
  ${native-cli}/bin/native up

  # Wait for the gateway to be ready
  ${kubectl}/bin/kubectl wait --for=condition=Programmed --timeout=60s \
    gateway eventlistener

  # Allow an additional grace period for potential routes to set themselves up.
  # TODO(aaronmondal): Find a better solution.
  sleep 10

  # Retrieve the event listener address
  EVENTLISTENER=''$(${kubectl}/bin/kubectl get gtw eventlistener \
    -o=jsonpath='{.status.addresses[0].value}')

  # POST requests to the event listener
  ${curl}/bin/curl -v \
    -H 'Content-Type: application/json' \
    -d '{"flakeOutput": "${githubBaseUrl}${nativelinkCommit}#image"}' \
    http://"''${EVENTLISTENER}":8080

  ${curl}/bin/curl -v \
    -H 'Content-Type: application/json' \
    -d '{"flakeOutput": "./src_root#nativelink-worker-lre-mojo"}' \
    http://"''${EVENTLISTENER}":8080

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
    nativelink-worker-lre-mojo=localhost:5001/nativelink-worker-lre-mojo:"''$(${nix}/bin/nix eval .#nativelink-worker-lre-mojo.imageTag --raw)"

  # Apply the configuration
  ${kubectl}/bin/kubectl apply -k "''${KUSTOMIZE_DIR}"

  # Monitor the deployment rollout
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-cas
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-scheduler
  ${kubectl}/bin/kubectl rollout status deploy/nativelink-worker-lre-mojo
''
