{ buildImage
, lre-cc
, mojoEnv
, ...
}:

let
  # This environment is shared between toolchain autogen images and the final
  # toolchain image.
  Env = mojoEnv;
  # [
  #   # Add all tooling here so that the generated toolchains use `/nix/store/*`
  #   # paths instead of `/bin` or `/usr/bin`. This way we're guaranteed to use
  #   # binary identical toolchains during local and remote execution.
  #   ("PATH="
  #     + (lib.strings.concatStringsSep ":" [
  #     "${gcc}/bin"
  #     "${mojo-sdk}/bin"
  #   ]))
  #   "MODULAR_HOME=${mojo-sdk}"
  #   "MOJO_COMPILER=${mojo-sdk}/bin/mojo"
  #   "MOJO_CC_PATH=${gcc}/bin:${mojo-sdk}/bin"
  #   "MOJO_LIBRARY_PATH=${zlib}/lib:${ncurses}/lib"
  #   "MOJO_PYTHON_LIBRARY=${python312}/lib"
  # ];
in
buildImage {
  name = "lre-mojo";
  maxLayers = 20;
  fromImage = lre-cc;
  config = { inherit Env; };
  # Attached for passthrough to rbe-configs-gen.
  meta = { inherit Env; };

  # Don't set a tag here so that the image is tagged by its derivation hash.
  # tag = null;
}
