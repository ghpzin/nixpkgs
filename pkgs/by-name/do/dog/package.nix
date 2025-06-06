{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "dog";
  version = "1.7";

  src = fetchurl {
    url = "http://archive.debian.org/debian/pool/main/d/dog/dog_${version}.orig.tar.gz";
    sha256 = "3ef25907ec5d1dfb0df94c9388c020b593fbe162d7aaa9bd08f35d2a125af056";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "gcc" "$CC"
    sed -i '40i #include <time.h>' dog.c
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/man/man1
    cp dog.1 $out/man/man1
    cp dog $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://lwn.net/Articles/421072/";
    description = "cat replacement";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ qknight ];
    platforms = platforms.all;
    mainProgram = "dog";
  };
}
