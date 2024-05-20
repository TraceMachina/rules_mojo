{ bazel
, kubectl
, writeShellScriptBin
, ...
}:

let
  # The specific commit to use
  nativelinkCommit = "75105df746c626da76f74e412764e6755296a8ab";

  # Base URL for GitHub access
  githubBaseUrl = "github:TraceMachina/nativelink/";
in

writeShellScriptBin "lre-bazel" ''
  EXECUTOR=$(${kubectl}/bin/kubectl get gtw scheduler -o=jsonpath='{.status.addresses[0].value}')
  CACHE=$(${kubectl}/bin/kubectl get gtw cache -o=jsonpath='{.status.addresses[0].value}')

  if [[
      "$1" == "build" ||
      "$1" == "coverage" ||
      "$1" == "run" ||
      "$1" == "test"
  ]]; then
      unset TMPDIR TMP
      ${bazel}/bin/bazel $1 \
          --remote_timeout=600 \
          --remote_instance_name=main \
          --remote_cache=grpc://''${CACHE}:50051 \
          --remote_executor=grpc://''${EXECUTOR}:50052 \
          --strategy=TestRunner=local \
          ''${@:2}
  else
      ${bazel}/bin/bazel $@
  fi
''
