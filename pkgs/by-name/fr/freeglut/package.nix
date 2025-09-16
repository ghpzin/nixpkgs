{
  lib,
  stdenv,
  fetchpatch,
  fetchurl,
  libICE,
  libXext,
  libXi,
  libXrandr,
  libXxf86vm,
  libGLX,
  libGLU,
  cmake,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freeglut";
  version = "3.6.0";

  src = fetchurl {
    url = "mirror://sourceforge/freeglut/freeglut-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-nD1NZRb7+gKA7ck8d2mPtzA+RDwaqvN9Jp4yiKbD6lI=";
  };

  patches = [
    # fix build with gcc15
    (fetchpatch {
      url = "https://src.fedoraproject.org/rpms/freeglut/raw/c29323d05df3a8b080541741b0fb247b97a3eb68/f/0001-egl-fix-fgPlatformDestroyContext-prototype-for-C23.patch";
      hash = "sha256-agXw3JHq81tx5514kkorvuU5mX4E3AV930hy1OJl4L0=";
    })
  ];

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    libICE
    libXext
    libXi
    libXrandr
    libXxf86vm
    libGLU
  ];

  cmakeFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "-DOPENGL_INCLUDE_DIR=${lib.getInclude libGLX}/include"
    "-DOPENGL_gl_LIBRARY:FILEPATH=${lib.getLib libGLX}/lib/libGL.dylib"
    "-DFREEGLUT_BUILD_DEMOS:BOOL=OFF"
  ];

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = with lib; {
    description = "Create and manage windows containing OpenGL contexts";
    longDescription = ''
      FreeGLUT is an open source alternative to the OpenGL Utility Toolkit
      (GLUT) library. GLUT (and hence FreeGLUT) allows the user to create and
      manage windows containing OpenGL contexts on a wide range of platforms
      and also read the mouse, keyboard and joystick functions. FreeGLUT is
      intended to be a full replacement for GLUT, and has only a few
      differences.
    '';
    homepage = "https://freeglut.sourceforge.net/";
    license = licenses.mit;
    pkgConfigModules = [ "glut" ];
    platforms = platforms.all;
    maintainers = [ maintainers.bjornfor ];
  };
})
