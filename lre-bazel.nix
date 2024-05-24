{ bazel
, kubectl
, writeShellScriptBin
, ...
}:

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
