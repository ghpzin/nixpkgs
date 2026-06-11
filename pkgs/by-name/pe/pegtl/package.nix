{
  cmake,
  fetchFromGitHub,
  fetchpatch,
  gitUpdater,
  lib,
  ninja,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pegtl";
  version = "3.2.8";

  src = fetchFromGitHub {
    owner = "taocpp";
    repo = "PEGTL";
    rev = finalAttrs.version;
    hash = "sha256-nPWSO2wPl/qenUQgvQDQu7Oy1dKa/PnNFSclmkaoM8A=";
  };

  patches = [
    # Fix build with gcc16
    # https://github.com/taocpp/PEGTL/issues/382
    # rebase of: https://github.com/taocpp/PEGTL/commit/0176e87da3a02d0ab40ce39f03e0e4108d1bbba5
    ./pegtl-fix-build-with-gcc16.patch
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    homepage = "https://github.com/taocpp/pegtl";
    description = "Parsing Expression Grammar Template Library";
    longDescription = ''
      Zero-dependency C++ header-only parser combinator library
      for creating parsers according to a Parsing Expression Grammar (PEG).
    '';
    license = lib.licenses.boost;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
