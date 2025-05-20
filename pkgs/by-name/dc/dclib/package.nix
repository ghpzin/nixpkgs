{
  lib,
  stdenv,
  fetchurl,
  libxml2,
  openssl,
  bzip2,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "dclib";
  version = "0.3.23";

  src = fetchurl {
    url = "mirror://sourceforge/wxdcgui/dclib/dclib-0.3.23.tar.bz2";
    hash = "sha256-dXtnyxFYqT/YJu81jsCU9Zup3KDd6UodcyWDPyIuTdA=";
  };

  buildInputs = [
    libxml2
    openssl
    bzip2
    zlib
  ];

  meta = with lib; {
    description = "Peer-to-Peer file sharing client";
    homepage = "http://dcgui.berlios.de";
    platforms = platforms.linux;
    license = [
      licenses.openssl
      licenses.gpl2
    ];
  };
}
