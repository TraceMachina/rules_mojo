{ bazel
, kubectl
, writeShellScriptBin
, ...
}:

writeShellScriptBin "lre-bazel" ''
  EXECUTOR=$(${kubectl}/bin/kubectl get gtw scheduler-gateway -o=jsonpath='{.status.addresses[0].value}')
  CACHE=$(${kubectl}/bin/kubectl get gtw cache-gateway -o=jsonpath='{.status.addresses[0].value}')

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
          --remote_cache=grpc://''${CACHE} \
          --remote_executor=grpc://''${EXECUTOR} \
          --strategy=TestRunner=local \
          ''${@:2}
  else
      ${bazel}/bin/bazel $@
  fi
''
