{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "usrsctp";
  version = "0.9.5.0";

  src = fetchFromGitHub {
    owner = "sctplab";
    repo = "usrsctp";
    rev = finalAttrs.version;
    sha256 = "10ndzkip8blgkw572n3dicl6mgjaa7kygwn3vls80liq92vf1sa9";
  };

  patches = [
    # usrsctp fails to build with clang 15+ due to set but unused variable and missing prototype
    # errors. These issues are fixed in the master branch, but a new release with them has not
    # been made. The following patch can be dropped once a release has been made.
    ./clang-fix-build.patch

    (fetchpatch {
      name = "freebsd-14.patch";
      url = "https://github.com/sctplab/usrsctp/commit/ac559d2a95277e5e0827e9ee5a1d3b1b50e0822a.patch";
      hash = "sha256-QBlzH37Xwwnn1y8pM941Zesz18p2EazfeD0lCU8n6nI=";
    })

    (fetchpatch {
      name = "usrsctp-fix-cmake-4.patch";
      url = "https://github.com/sctplab/usrsctp/commit/7569d2ce1e8658534369ad9726ca62139211db84.patch";
      hash = "sha256-Hxp1SGwmpm6UK//KFLQoOmmI0a1QpSNaTaEEUbC8jbg=";
    })
    # Fix build with gcc16
    # https://github.com/sctplab/usrsctp/pull/729
    (fetchpatch {
      name = "usrsctp-fix-build-with-gcc16.patch";
      url = "https://github.com/sctplab/usrsctp/commit/33d7af1a207783f42f5fc2d10ed27a8de7dc495b.patch";
      hash = "sha256-24Jp7uBHy7PX/Hrrv179TdeegDFQggV0ZQqPSa/V4VU=";
    })
  ];

  nativeBuildInputs = [ cmake ];

  # https://github.com/sctplab/usrsctp/issues/662
  postPatch = ''
    substituteInPlace usrsctplib/CMakeLists.txt \
      --replace '$'{exec_prefix}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_FULL_LIBDIR} \
      --replace '$'{prefix}/'$'{CMAKE_INSTALL_INCLUDEDIR} '$'{CMAKE_INSTALL_FULL_INCLUDEDIR}
  '';

  meta = {
    homepage = "https://github.com/sctplab/usrsctp";
    description = "Portable SCTP userland stack";
    maintainers = with lib.maintainers; [ misuzu ];
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
  };
})
