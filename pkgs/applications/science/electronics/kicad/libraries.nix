{ lib, stdenv
, cmake
, gettext
, libSrc
, stepreduce
, parallel
, zip
}:
let
  mkLib = name:
    stdenv.mkDerivation {
      pname = "kicad-${name}";
      version = builtins.substring 0 10 (libSrc name).rev;

      src = (libSrc name).override {
        postFetch = lib.optionalString (name == "packages3d") ''
          find $out -type f -name '*.step' | ${lib.getExe parallel} '${lib.getExe stepreduce} {} {} && ${lib.getExe zip} -9 -j {.}.stpZ {} && rm {}'
        '';
      };

      postPatch = lib.optionalString (name == "packages3d") ''
        substituteInPlace CMakeLists.txt \
          --replace-fail '"*.step"' '"*.stpZ"'
      '';

      nativeBuildInputs = [ cmake ];

      meta = {
        license = lib.licenses.cc-by-sa-40;
        platforms = lib.platforms.all;
      };
    };
in
{
  symbols = mkLib "symbols";
  templates = mkLib "templates";
  footprints = mkLib "footprints";
  packages3d = mkLib "packages3d";
}
