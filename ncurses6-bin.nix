{ dpkg
, fetchurl
, stdenv
, ...
}:

stdenv.mkDerivation rec {
  pname = "ncurses6-bin";
  version = "6.4+20240113-1ubuntu2";

  src = fetchurl {
    url = "http://archive.ubuntu.com/ubuntu/pool/main/n/ncurses/libncurses6_${version}_amd64.deb";
    sha256 = "0dvm14nqrjw54v0fpfyjhlc481l30h0i6nkd4v2j5xp2lgiyzf7j";
  };

  buildInputs = [ dpkg ];

  unpackPhase = ''
    dpkg-deb -x $src $TMPDIR
  '';

  installPhase = ''
    mkdir -p $out/lib
    mv $TMPDIR/usr/lib/x86_64-linux-gnu/* $out/lib
  '';
}
