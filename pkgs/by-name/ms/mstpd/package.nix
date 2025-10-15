{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "mstpd";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mstpd";
    repo = "mstpd";
    rev = version;
    hash = "sha256-m4gbVXAPIYGQvTFaSziFuOO6say5kgUsk7NSdqXgKmA=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  configureFlags = [
    "--prefix=$(out)"
    "--sysconfdir=$(out)/etc"
    "--sbindir=$(out)/sbin"
    "--libexecdir=$(out)/lib"
  ];

  meta = {
    description = "Multiple Spanning Tree Protocol daemon";
    homepage = "https://github.com/mstpd/mstpd";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
