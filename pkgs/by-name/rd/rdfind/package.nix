{
  lib,
  stdenv,
  fetchurl,
  nettle,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rdfind";
  version = "1.7.0";

  src = fetchurl {
    url = "https://rdfind.pauldreik.se/rdfind-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-eMRjFS4dnk/Rv+uDuckt9ef8TF+Tx9Qm+x9++ivk3yk=";
  };

  # Fix build with gcc16
  env.NIX_CFLAGS_COMPILE = "-std=gnu++17";

  buildInputs = [ nettle ];

  meta = {
    homepage = "https://rdfind.pauldreik.se/";
    description = "Removes or hardlinks duplicate files very swiftly";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.wmertens ];
    platforms = lib.platforms.all;
    mainProgram = "rdfind";
  };
})
