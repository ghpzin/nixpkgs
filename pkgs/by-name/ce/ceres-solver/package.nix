{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  eigen,
  gflags,
  abseil-cpp,
  suitesparse,
  metis,
  runTests ? false,
  enableStatic ? stdenv.hostPlatform.isStatic,
  withBlas ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ceres-solver";
  version = "2.2.0-unstable-2026-06-09";

  src = fetchFromGitHub {
    owner = "ceres-solver";
    repo = "ceres-solver";
    rev = "8a566fcc156322160b96f8ca5f0ff755241c2d33";
    hash = "sha256-mEl7gvlR4a4I3ncdVCoVEp+SyfyD3tFIQOpNnDPQQeg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = lib.optional runTests gflags;
  propagatedBuildInputs = [
    eigen
    abseil-cpp
  ]
  ++ lib.optionals withBlas [
    blas
    suitesparse
    metis
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=${if enableStatic then "OFF" else "ON"}"
  ];

  # The Basel BUILD file conflicts with the cmake build directory on
  # case-insensitive filesystems, eg. darwin.
  preConfigure = ''
    rm BUILD
  '';

  doCheck = runTests;

  checkTarget = "test";

  meta = {
    description = "C++ library for modeling and solving large, complicated optimization problems";
    license = lib.licenses.bsd3;
    homepage = "http://ceres-solver.org";
    maintainers = with lib.maintainers; [ giogadi ];
    platforms = lib.platforms.unix;
  };
})
