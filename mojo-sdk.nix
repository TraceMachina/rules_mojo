{ autoPatchelfHook
, fetchurl
, glibc
, icu
, libedit
, libgcc
, libxml2
, ncurses
, stdenv
, zlib
, zstd
, ...
}:

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
    libxml2
    ncurses
    libedit
    icu
    zlib
    glibc
    libgcc
  ];

  nativeBuildInputs = [ autoPatchelfHook zstd ];

  unpackPhase = ''
    zstd -d $src -c | tar xvf -
  '';

  installPhase = ''
    cp -r . $out

    # Nixpkgs uses `libedit.so.0.0.72` for the version of libedit
    # that is `libedit.so.2.0.72` in Ubuntu.
    ln -s ${libedit}/lib/libedit.so.0 $out/lib/libedit.so.2

    # The mojo command uses this config file to determine the
    # locations to bundled dependencies. Remap it to /nix/store.
    sed -i "s|\$_self.install_path|$out|g" $out/modular.cfg

    # The nightly config has what looks like a typo, omitting the `_`.
    sed -i "s|\$self.install_path|$out|g" $out/modular.cfg

    # Nightly builds require settings under `[mojo-nightly]`
    sed -i "s|\[mojo]|[mojo-nightly]|g" $out/modular.cfg

  '';
}
