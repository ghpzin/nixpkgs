{
  lib,
  stdenv,
  fetchpatch,
  fetchurl,
  boost,
  pkg-config,
  cppunit,
  zlib,
  libwpg,
  libwpd,
  librevenge,
}:

stdenv.mkDerivation rec {
  pname = "libodfgen";
  version = "0.1.7";

  src = fetchurl {
    url = "mirror://sourceforge/project/libwpd/libodfgen/libodfgen-${version}/libodfgen-${version}.tar.xz";
    sha256 = "sha256-Mj5JH5VsjKKrsSyZjjUGcJMKMjF7+WYrBhXdSzkiuDE=";
  };

  patches = [
    # Fix build with gcc15
    (fetchpatch {
      name = "libodfgen-fix-includes-gcc15.patch";
      url = "https://src.fedoraproject.org/rpms/libodfgen/raw/728cf6e824b479902f844978e75e0c7550eae61b/f/includes.patch";
      hash = "sha256-NamJMJ0KekgOI4cD9/bcq8UlG9polMmITZ628+p+2OA=";
    })
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    boost
    cppunit
    zlib
    libwpg
    libwpd
    librevenge
  ];

  meta = with lib; {
    description = "Base library for generating ODF documents";
    license = licenses.mpl20;
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.unix;
  };
}
