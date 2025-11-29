{ callPackage, stdenv, lib, ... }@args:

callPackage ./generic.nix (
  args
  // {
    version = "0.3.4";
    sha256 = "0xp8mcfyi5nmb5a2zi5ibmyshxkb1zv1dgmnyn413m7ahgdx8mfg";
    patches = lib.optionals (stdenv.hostPlatform.isMusl) [
      # Fix build on musl with gcc15
      # https://github.com/twaugh/patchutils/commit/dc88e964427c3d4a376a21dd517ab95c7b6c6ad4
      # ./patchutils-gnulib-integrate-properly.patch
    ];
  }
)
