{ autoPatchelfHook
, dpkg
, fetchurl
, stdenv
, ...
}:

stdenv.mkDerivation rec {
  pname = "tinfo6-bin";
  version = "6.4+20240113-1ubuntu2";

  src = fetchurl {
    url = "http://archive.ubuntu.com/ubuntu/pool/main/n/ncurses/libtinfo6_${version}_amd64.deb";
    sha256 = "16r0r8wacf56nbhz1vq7rivbpqh6ps5fbrh5bgv4rl196xsy3qak";
  };

  buildInputs = [ dpkg ];

  nativeBuildInputs = [ autoPatchelfHook ];

  unpackPhase = ''
    dpkg-deb -x $src $TMPDIR
  '';

  installPhase = ''
    mkdir -p $out/lib
    mv $TMPDIR/usr/lib/x86_64-linux-gnu/* $out/lib
  '';
}
