{ pkgs, mojo-sdk, ... }:

[
  "MODULAR_HOME=${mojo-sdk}"
  "MOJO_COMPILER=${mojo-sdk}/bin/mojo"
  "MOJO_CC_PATH=${pkgs.gcc}/bin:${mojo-sdk}/bin"
  "MOJO_LIBRARY_PATH=${pkgs.zlib}/lib:${pkgs.ncurses}/lib"

  # TODO(aaronmondal): This needs to be set during runtime. Let's just add it to
  #                    a mojo wrapper script.
  # "MOJO_PYTHON_LIBRARY=${pkgs.python312}/lib/libpython3.12.so.1.0"
]
