{ pkgs, mojo-sdk, ... }:

[
  "MODULAR_HOME=${mojo-sdk}"
  "MOJO_COMPILER=${mojo-sdk}/bin/mojo"
  "MOJO_CC_PATH=${pkgs.lib.makeBinPath mojo-sdk.passthru.mojoBinPath}"
  "LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath mojo-sdk.passthru.mojoLibraryPath}"

  # TODO(aaronmondal): This needs to be set during runtime.
  # "MOJO_PYTHON_LIBRARY=${pkgs.python312}/lib/libpython3.12.so.1.0"
]
