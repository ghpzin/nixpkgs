{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  perl,
  python3,

  # Enable BLAS interface with 64-bit integer width.
  blas64 ? false,

  # Target architecture. "amdzen" compiles kernels for all Zen
  # generations. To build kernels for specific Zen generations,
  # use "zen", "zen2", "zen3", "zen4", or "zen5".
  withArchitecture ? "amdzen",

  # Enable OpenMP-based threading.
  withOpenMP ? true,
}:

let
  threadingSuffix = lib.optionalString withOpenMP "-mt";
  blasIntSize = if blas64 then "64" else "32";

in
stdenv.mkDerivation (finalAttrs: {
  pname = "amd-blis";
  version = "5.1";

  src = fetchFromGitHub {
    owner = "amd";
    repo = "blis";
    rev = finalAttrs.version;
    hash = "sha256-hqb/Q1CBqtC4AXqHNd7voewGUD675hJ9IwvP3Mn9b+M=";
  };

  patches = [
    # Set the date stamp to $SOURCE_DATE_EPOCH
    ./build-date.patch
    # Fix build with gcc15, adapted from:
    # https://github.com/amd/blis/commit/30c42202d78fd5ee5e54d50ad57348e5e541a7d5
    # https://github.com/amd/blis/commit/a4db661b447f6d449c33629f3f45fee9b9888dc2
    ./amd-blis-fix-build-with-gcc15.patch
  ];

  inherit blas64;

  nativeBuildInputs = [
    perl
    python3
  ];

  # Tests currently fail with non-Zen CPUs due to a floating point
  # exception in one of the generic kernels. Try to re-enable the
  # next release.
  doCheck = false;

  enableParallelBuilding = true;

  configureFlags = [
    "--enable-cblas"
    "--blas-int-size=${blasIntSize}"
  ]
  ++ lib.optionals withOpenMP [ "--enable-threading=openmp" ]
  ++ [ withArchitecture ];

  postPatch = ''
    patchShebangs configure build/flatten-headers.py
  '';

  postInstall = ''
    ls $out/lib
    ln -s $out/lib/libblis${threadingSuffix}.so $out/lib/libblas.so.3
    ln -s $out/lib/libblis${threadingSuffix}.so $out/lib/libcblas.so.3
    ln -s $out/lib/libblas.so.3 $out/lib/libblas.so
    ln -s $out/lib/libcblas.so.3 $out/lib/libcblas.so
  '';

  meta = {
    description = "BLAS-compatible library optimized for AMD CPUs";
    homepage = "https://developer.amd.com/amd-aocl/blas-library/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
})
