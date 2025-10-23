{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
}:

stdenv.mkDerivation rec {
  pname = "shapelib";
  version = "1.6.2";

  src = fetchurl {
    url = "https://download.osgeo.org/shapelib/shapelib-${version}.tar.gz";
    hash = "sha256-S3SjbO2U6ae+pAEVfmZK3cxb4lHn33+I1GdDYdoBLCE=";
  };

  patches = [
    # Fix build with gcc15
    # https://github.com/OSGeo/shapelib/pull/188
    (fetchpatch {
      name = "shapelib-fix-build-with-gcc15.patch";
      url = "https://github.com/OSGeo/shapelib/commit/bf455986557e88cce6a2a85448798e1dc05541f2.patch";
      hash = "sha256-ubd8L2hxSAxTDiOSToVHGLHkpGOap5bnozdVdv9VgCQ=";
    })
  ];

  doCheck = true;
  preCheck = ''
    patchShebangs tests contrib/tests
  '';

  meta = {
    description = "C Library for reading, writing and updating ESRI Shapefiles";
    homepage = "http://shapelib.maptools.org/";
    license = lib.licenses.gpl2;
    teams = [ lib.teams.geospatial ];
    changelog = "http://shapelib.maptools.org/release.html";
  };
}
