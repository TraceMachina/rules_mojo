{ autoPatchelfHook
, fetchurl
, glibc
, icu
, libedit
, libgcc
, libxml2
, makeLibraryPath
, makeWrapper
, mold
, ncurses
, stdenv
, tinfo
, uutils-coreutils-noprefix
, zlib-ng
, zstd
, clang
, ...
}:
let

  # The zlib-ng library is a more modern implementation of Zlib and can act as drop-in replacement.
  zlib = zlib-ng.override { withZlibCompat = true; };
in

stdenv.mkDerivation rec {
  pname = "mojo";
  version = "2024.5.1905";

  src = fetchurl {
    url = "https://packages.modular.com/nightly/mojo/packages/${version}/mojo-x86_64-unknown-linux-gnu-${version}-37-0.tar.zst";
    sha256 = "sha256-k4oIv9p4DQ7E7o8Jsb7ISJ+Rbqcj32q1LQIMxSSMiBo=";

    # Stable crashes in remote execution.
    # url = "https://packages.modular.com/mojo/packages/${version}/mojo-x86_64-unknown-linux-gnu-${version}-13-0.tar.zst";
    # sha256 = "074smgp4zgl3djq4fd6jf4wf22kmz49sx5skpva9w2bs4rvbyjna";
  };

  buildInputs = [
    glibc
    icu
    libedit
    libgcc
    libxml2
    mold
    tinfo
    ncurses
    zlib
  ];

  nativeBuildInputs = [ autoPatchelfHook zstd makeWrapper ];

  unpackPhase = ''
    zstd -d $src -c | tar xvf -
  '';

  patchPhase = ''
    # Nixpkgs uses `libedit.so.0.0.72` for the version of libedit
    # that is `libedit.so.2.0.72` in Ubuntu.
    ln -s ${libedit}/lib/libedit.so.0 lib/libedit.so.2

    # The mojo command uses this config file to determine the
    # locations to bundled dependencies. Remap it to /nix/store.
    sed -i "s|\$_self.install_path|$out|g" modular.cfg

    # The nightly config has what looks like a typo, omitting the `_`.
    sed -i "s|\$self.install_path|$out|g" modular.cfg

    # Nightly builds require settings under `[mojo-nightly]`
    sed -i "s|\[mojo]|[mojo-nightly]|g" modular.cfg

    # This evil hack is a ~95% linktime speedup by using mold instead of ld.
    #
    # The mojo compiler somehow behaves differently when running in Bazel. There
    # it's necessary to have the setup below specified.
    #
    # To work around the fact that we can't resolve `-Wl,-rpath` properly
    # because of unknown wrapping logic, we use`-Xlinker,-rpath` which has
    # semantics like `-Xlinker <arg>`.
    #
    # WARNING: At the moment linking phase can't figure out how to link tinfo.
    # To work around this we allow leaving the tinfo symbols undefined and
    # unlinked. This is a risky practice and might trigger segfaults at runtime.
    sed -i "s|system_libs = -lrt,-ldl,-lpthread,-lm,-lz,-ltinfo;|system_libs = -fuse-ld=mold,-lrt,-ldl,-lpthread,-lm,-Xlinker,-rpath=${glibc}/lib,-L,${zlib}/lib,-Xlinker,-rpath=${zlib}/lib,-Xlinker,-L,${tinfo}/lib,-Xlinker,-rpath=${tinfo}/lib,-Xlinker,-rpath=${stdenv.cc.cc.lib}/lib,-Xlinker,--unresolved-symbols=ignore-in-object-files,--verbose;|g" modular.cfg
  '';

  installPhase = ''
    cp -r . $out

    # The autoPatchelfHook would run before the fixupPhase, so we need to call
    # wrapping logic in a custom postInstall phase. This way we run patchelf
    # after the wrappers have been created.
    runHook postInstall
  '';

  # These fixups are not too pretty, but at the moment the `mojo` compiler
  # doesn't respect standard environment variables like `CC` and `LD`. Instead,
  # we have to add C++ tooling to the PATH. We also wrap certain executables
  # with `MODULAR_HOME` so that they work in mkShell environemnts.
  postInstall = ''
    wrap_with_env() {
      wrapProgram $1 \
        --set MODULAR_HOME $out \
        --prefix PATH : ${clang}/bin:${mold}/bin:${uutils-coreutils-noprefix}/bin \
        --prefix LD_LIBRARY_PATH : ${makeLibraryPath [ tinfo ncurses zlib stdenv.cc.cc.lib glibc ]}
    }

    wrap_with_env $out/bin/mojo
    wrap_with_env $out/bin/mojo-lldb
    wrap_with_env $out/bin/mojo-lsp-server
    wrap_with_env $out/bin/lldb-argdumper
    wrap_with_env $out/bin/lldb-server
    wrap_with_env $out/bin/mojo-lldb-dap
  '';

  passthru = {
    # These may be passed through to Bazel invocations and can be used to
    # construct remote execution toolchains for Mojo.
    mojoBinPath = [ clang mold uutils-coreutils-noprefix ];
    mojoLibraryPath = [ tinfo ncurses zlib stdenv.cc.cc.lib ];
  };
}
