{
  #clangStdenv,
  stdenv,
  lib,
  binutils,
  fetchFromGitHub,
  cmake,
  pkg-config,
  wrapGAppsHook3,
  boost189,
  cereal,
  cgal,
  curl,
  dbus,
  eigen,
  expat,
  glew,
  glib,
  glib-networking,
  gmp,
  gtk3,
  hicolor-icon-theme,
  libpng,
  mpfr,
  nanosvg,
  nlopt,
  nlohmann_json,
  opencascade-occt,
  openvdb,
  qhull,
  onetbb,
  wxwidgets_3_2,
  libx11,
  libbgcode,
  heatshrink,
  catch2_3,
  webkitgtk_4_1,
  ctestCheckHook,
  #withSystemd ? lib.meta.availableOn clangStdenv.hostPlatform systemd,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  systemd,
  udevCheckHook,
  z3,
  nix-update-script,
  wxGTK-override ? null,
  opencascade-override ? null,

  # Probably new actual new deps?
  c-blosc,
  imath,
  libjpeg_turbo, # doesn't get picked up?
  pcre2,
  python3,
  libsecret,

  # idk
  libsysprof-capture,
  libdatrie,
  libsepol,
  libthai,
  util-linux,
  libselinux,
  libxdmcp,
  fetchpatch,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      pybind11
    ]
  );
  nanosvg-fltk = nanosvg.overrideAttrs (old: {
    pname = "nanosvg-fltk";
    version = "unstable-2022-12-22";

    src = fetchFromGitHub {
      owner = "fltk";
      repo = "nanosvg";
      rev = "abcd277ea45e9098bed752cf9c6875b533c0892f";
      hash = "sha256-WNdAYu66ggpSYJ8Kt57yEA4mSTv+Rvzj9Rm1q765HpY=";
    };
  });
  wxGTK' =
    (wxwidgets_3_2.override {
      # Not available in wxwidgets_3_2?
      #withCurl = true;
      #withPrivateFonts = true;
      #withEGL = false;
      withWebKit = true;
    }).overrideAttrs
      (old: {
        buildInputs = old.buildInputs ++ [ libsecret ];
        configureFlags = old.configureFlags ++ [
          # Disable noisy debug dialogs
          "--enable-debug=no"
          "--enable-secretstore"
        ];
      });
  wxGTK-override' = if wxGTK-override == null then wxGTK' else wxGTK-override;
  opencascade-override' =
    if opencascade-override == null then opencascade-occt else opencascade-override;
in
#clangStdenv.mkDerivation (finalAttrs: {
stdenv.mkDerivation (finalAttrs: {
  pname = "preflight";
  version = "1.0.0";
  # Build with clang even on Linux, because GCC uses absolutely obscene amounts of memory
  # on this particular code base (OOM with 32GB memory and --cores 16 on GCC, succeeds
  # with --cores 32 on clang).
  src = fetchFromGitHub {
    owner = "oozebot";
    repo = "preFlight";
    hash = "sha256-/kJ+ayW3k4lgFUdR4205BfBfx7jK2lAjUgbX/Auw0zM=";
    tag = "v${finalAttrs.version}";
  };

  # only applies to prusa slicer because super-slicer overrides *all* patches
  patches = [
    # Fix for webkitgtk linking
    ./patches/0001-not-for-upstream-CMakeLists-Link-against-webkit2gtk-.patch
    # https://github.com/NixOS/nixpkgs/issues/415703
    # https://gitlab.archlinux.org/archlinux/packaging/packages/prusa-slicer/-/merge_requests/5
    #./allow_wayland.patch
    # Pick https://github.com/prusa3d/PrusaSlicer/pull/14207 to remove unused and insecure ilmbase dependency
    ./patches/no-ilmbase.patch
    (fetchpatch {
      url = "https://aur.archlinux.org/cgit/aur.git/plain/0001-fix-building-for-arch.patch?h=preflight&id=89d39730c0f33f3b47c7eb20f2a9307bfe80ce5d";
      hash = "sha256-3l0fhU+Ry6U1myJh27sTG2eznC3Giq3vwXmqrsmT7QU=";
    })
  ];

  postPatch = ''
    substituteInPlace cmake/modules/FindOpenVDB.cmake \
      --replace "IlmBase::Half" "" \
      --replace "Boost::system" ""
    substituteInPlace CMakeLists.txt \
      --replace 'elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUXX OR "''${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")' 'elseif(FALSE)'
  '';

  # (not applicable to super-slicer fork)
  #  postPatch = lib.optionalString (finalAttrs.pname == "prusa-slicer") (
  #    # Patch required for GCC 14, but breaks on clang
  #    lib.optionalString clangStdenv.cc.isGNU ''
  #      substituteInPlace src/slic3r-arrange/include/arrange/DataStoreTraits.hpp \
  #        --replace-fail \
  #        "WritableDataStoreTraits<ArrItem>::template set" \
  #        "WritableDataStoreTraits<ArrItem>::set"
  #    ''
  #    # Make Gcode viewer open newer bgcode files.
  #    + ''
  #      substituteInPlace src/platform/unix/PrusaGcodeviewer.desktop \
  #        --replace-fail 'MimeType=text/x.gcode;' 'MimeType=application/x-bgcode;text/x.gcode;'
  #    ''
  #    # Make PrusaSlicer handle the url "prusaslicer://"
  #    + ''
  #      substituteInPlace src/platform/unix/PrusaSlicer.desktop \
  #        --replace-fail \
  #        'Exec=prusa-slicer %F' \
  #        'Exec=prusa-slicer %U'
  #
  #      substituteInPlace src/platform/unix/PrusaSlicer.desktop \
  #        --replace-fail \
  #        'MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;' \
  #        'MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;x-scheme-handler/prusaslicer;'
  #    ''
  #  );

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    wxGTK-override'
  ];

  buildInputs = [
    binutils
    boost189
    cereal
    cgal
    curl
    dbus
    eigen
    expat
    glew
    glib
    glib-networking
    gmp
    gtk3
    hicolor-icon-theme
    libpng
    mpfr
    nanosvg-fltk
    nlopt
    opencascade-override'
    openvdb
    qhull
    onetbb
    wxGTK-override'
    libx11
    libbgcode
    heatshrink
    catch2_3
    webkitgtk_4_1
    z3
    nlohmann_json
    libjpeg_turbo
    pythonEnv
  ]
  ++ lib.optionals withSystemd [
    systemd
  ];

  #strictDeps = true;
  strictDeps = true;

  separateDebugInfo = true;

  doInstallCheck = true;

  env = {
    # The build system uses custom logic - defined in
    # cmake/modules/FindNLopt.cmake in the package source - for finding the nlopt
    # library, which doesn't pick up the package in the nix store.  We
    # additionally need to set the path via the NLOPT environment variable.
    NLOPT = nlopt;
  }
  // lib.optionalAttrs withSystemd {
    # prusa-slicer uses dlopen on `libudev.so` at runtime
    NIX_LDFLAGS = "-ludev";
  };

  prePatch = ''
    # Since version 2.5.0 of nlopt we need to link to libnlopt, as libnlopt_cxx
    # now seems to be integrated into the main lib.
    sed -i 's|nlopt_cxx|nlopt|g' cmake/modules/FindNLopt.cmake

    # Disable slic3r_jobs_tests.cpp as the test fails sometimes
    # sed -i 's|slic3r_jobs_tests.cpp||g' tests/slic3rutils/CMakeLists.txt

    # prusa-slicer expects the OCCTWrapper shared library in the same folder as
    # the executable when loading STEP files. We force the loader to find it in
    # the usual locations (i.e. LD_LIBRARY_PATH) instead. See the manpage
    # dlopen(3) for context.
    if [ -f "src/libslic3r/Format/STEP.cpp" ]; then
      substituteInPlace src/libslic3r/Format/STEP.cpp \
        --replace-fail 'libpath /= "OCCTWrapper.so";' 'libpath = "OCCTWrapper.so";'
    fi
    # https://github.com/prusa3d/PrusaSlicer/issues/9581
    if [ -f "cmake/modules/FindEXPAT.cmake" ]; then
      rm cmake/modules/FindEXPAT.cmake
    fi

    # Fix resources folder location on macOS
    substituteInPlace src/${
      if finalAttrs.pname == "preflight" then "CLI/Setup.cpp" else "preFlight.cpp"
    } \
      --replace-fail "#ifdef __APPLE__" "#if 0"


    substituteInPlace cmake/modules/FindOpenVDB.cmake \
      --replace-fail "set(OpenVDB_USES_BLOSC \''${USE_BLOSC})" "set(OpenVDB_USES_BLOSC FALSE)" \
      --replace-fail "if(OpenVDB_USES_BLOSC)" "if(FALSE)"
  '';

  cmakeFlags = [
    "-DSLIC3R_STATIC=0"
    "-DSLIC3R_FHS=1"
    "-DSLIC3R_GTK=3"
    "-DCMAKE_CXX_FLAGS=-DBOOST_LOG_DYN_LINK"
    # there is many different min versions set accross different
    # Find*.cmake files, substituting them all is not viable
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
    # ''-DpreFlight_deps_PACKAGE_EXCLUDES="Blosc;Boost;Catch2;Cereal;CGAL;CURL;Eigen;EXPAT;GLEW;GMP;JPEG;json;MPFR;NanoSVG;NLopt;OCCT;OpenCSG;OpenEXR;OpenSSL;OpenVDB;PNG;pybind11;PythonRuntime;Qhull;TBB;TIFF;wxWidgets;z3;ZLIB''

    # "-Wno-dev"
    # "--debug-find"

    # "-DSLIC3R_DESKTOP_INTEGRATION=0"
    # Idk none of these work
    #"-DUSE_BLOSC=FALSE"
    #"-DUSE_BLOSC=0"
    #"-DOpenVDB_USES_BLOSC=0"
    # "-DSLIC3R_PYTHON_PREPROCESSOR=0"
    (lib.cmakeFeature "Python3_EXECUTABLE" (lib.getExe pythonEnv))
  ];

  postInstall = ''
    mkdir -p "$out/lib"
    mv -v $out/bin/*.* $out/lib/

    mkdir -p "$out"/share/mime/packages
    cat << EOF > "$out"/share/mime/packages/prusa-gcode-viewer.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/x-bgcode">
        <comment xml:lang="en">Binary G-code file</comment>
        <glob pattern="*.bgcode"/>
      </mime-type>
    </mime-info>
    EOF
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/lib"
    )
  '';

  doCheck = true;
  nativeCheckInputs = [ ctestCheckHook ];
  checkFlags = [
    "--force-new-ctest-process"
    "-E"
    "libslic3r_tests|sla_print_tests"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v(.+)$"
    ];
  };

  meta = {
    description = "G-code generator for 3D printer";
    homepage = "preflight3d.com";
    changelog = "https://github.com/oozebot/preFlight/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [
      gigahawk
    ];
    platforms = lib.platforms.unix;
  }
  #// lib.optionalAttrs (clangStdenv.hostPlatform.isDarwin) {
  // lib.optionalAttrs (stdenv.hostPlatform.isDarwin) {
    # mainProgram = "PrusaSlicer";
  };
})
