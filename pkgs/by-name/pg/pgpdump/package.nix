{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  supportCompressedPackets ? true,
  zlib,
  bzip2,
}:

stdenv.mkDerivation rec {
  pname = "pgpdump";
  version = "0.36";

  src = fetchFromGitHub {
    owner = "kazu-yamamoto";
    repo = "pgpdump";
    rev = "v${version}";
    sha256 = "sha256-JKedgHCTDnvLyLR3nGl4XFAaxXDU1TgHrxPMlRFwtBo=";
  };

  patches = [
    # Fix build with gcc15
    # https://github.com/kazu-yamamoto/pgpdump/pull/45
    (fetchpatch {
      name = "pgpdump-fix-c23-compatibility.patch";
      url = "https://github.com/kazu-yamamoto/pgpdump/commit/541442dc04259bde680b46742522177be40cc065.patch";
      hash = "sha256-durJQWBBc8JNC8wFvhJOjIhGLXMk//dwOiDcOP2dQIY=";
    })
  ];

  buildInputs = lib.optionals supportCompressedPackets [
    zlib
    bzip2
  ];

  meta = {
    description = "PGP packet visualizer";
    mainProgram = "pgpdump";
    longDescription = ''
      pgpdump is a PGP packet visualizer which displays the packet format of
      OpenPGP (RFC 4880) and PGP version 2 (RFC 1991).
    '';
    homepage = "http://www.mew.org/~kazu/proj/pgpdump/en/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = [ ];
  };
}
