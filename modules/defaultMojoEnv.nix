{ pkgs, mojo-sdk, ... }:

[
  # "PATH=${pkgs.lib.makeBinPath mojo-sdk.passthru.mojoBinPath}"
  "MODULAR_HOME=${mojo-sdk}"
  "MOJO_COMPILER=${mojo-sdk}/bin/mojo"
  "MOJO_CC_PATH=${pkgs.lib.makeBinPath mojo-sdk.passthru.mojoBinPath}"
  "MOJO_LIBRARY_PATH=${pkgs.lib.makeLibraryPath mojo-sdk.passthru.mojoLibraryPath}"
  "LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath mojo-sdk.passthru.mojoLibraryPath}"

  # "MOJO_LIBRARY_PATH=${pkgs.zlib-ng.override{withZlibCompat=true;}}/lib:${pkgs.ncurses}/lib"

  # TODO(aaronmondal): This needs to be set during runtime. Let's just add it to
  #                    a mojo wrapper script.
  # "MOJO_PYTHON_LIBRARY=${pkgs.python312}/lib/libpython3.12.so.1.0"
]
