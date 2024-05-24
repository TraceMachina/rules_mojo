{ pkgs, mojo, ... }:

[
  "MODULAR_HOME=${mojo}"
  "MOJO_COMPILER=${mojo}/bin/mojo"
  "MOJO_CC_PATH=${pkgs.lib.makeBinPath mojo.passthru.mojoBinPath}"
  "LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath mojo.passthru.mojoLibraryPath}"

  # TODO(aaronmondal): This needs to be set during runtime.
  # "MOJO_PYTHON_LIBRARY=${pkgs.python312}/lib/libpython3.12.so.1.0"
]
